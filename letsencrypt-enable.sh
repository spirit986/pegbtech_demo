#!/bin/bash

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi


DOMAINS=(pegbtech-demo.tomspirit.me www.pegbtech-demo.tomspirit.me)
RSA_KEY_SIZE=4096
DATA_PATH="./pegb_web/pegb-certbot"
EMAIL="tome.petkovski986@gmail.com" # Adding a valid address is strongly recommended
STAGING=1 # Set to 1 if you're testing your setup to avoid hitting request limits

# Nginx and certbot service names from docker-compose
NGINX_SERVICE=pegb-proxy 
CERTBOT_SERVICE=pegb-certbot


if [ -d "$DATA_PATH" ]; then
  read -p "Existing certificate domains found for: $DOMAINS. Continue and replace existing certificates? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi


if [ ! -e "$DATA_PATH/conf/options-ssl-nginx.conf" ] || [ ! -e "$DATA_PATH/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$DATA_PATH/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/tls_configs/options-ssl-nginx.conf > "$DATA_PATH/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/ssl-dhparams.pem > "$DATA_PATH/conf/ssl-dhparams.pem"
  echo
fi

echo "### Creating dummy certificate for $DOMAINS ..."
PATH="/etc/letsencrypt/live/$DOMAINS"
mkdir -p "$DATA_PATH/conf/live/$DOMAINS"
docker-compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:1024 -days 1\
    -keyout '$PATH/privkey.pem' \
    -out '$PATH/fullchain.pem' \
    -subj '/CN=localhost'" $CERTBOT_SERVICE
echo


echo "### Starting nginx ..."
docker-compose up --force-recreate -d $NGINX_SERVICE
echo

echo "### Deleting dummy certificate for $DOMAINS ..."
docker-compose run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$DOMAINS && \
  rm -Rf /etc/letsencrypt/archive/$DOMAINS && \
  rm -Rf /etc/letsencrypt/renewal/$DOMAINS.conf" $CERTBOT_SERVICE
echo


echo "### Requesting Let's Encrypt certificate for $DOMAINS ..."
#Join $DOMAINS to -d args
domain_args=""
for domain in "${DOMAINS[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$EMAIL" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $EMAIL" ;;
esac

# Enable staging mode if needed
if [ $STAGING != "0" ]; then staging_arg="--staging"; fi

docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $RSA_KEY_SIZE \
    --agree-tos \
    --force-renewal" $CERTBOT_SERVICE
echo

echo "### Reloading nginx ..."
docker-compose exec $NGINX_SERVICE nginx -s reload
