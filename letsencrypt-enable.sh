#!/bin/bash

## The www subdomain should go second
DOMAINS=(subdomain.domain.com www.subdomain.domain.com)
NGINX_CONFIG_FILE="${DOMAINS[0]}.conf" ## The NGINX config file will be named based on this value

RSA_KEY_SIZE=4096
DATA_PATH="./pegb_web/pegb-certbot"
NGINX_PATH="./pegb_web/pegb-proxy/nginx" # NGINX configuration will be generated here

EMAIL="" ## Setting a valid email is reccomended
STAGING=1 ## Set to 1 if you're testing your setup to avoid hitting request limits
ASK=0 ## Setting this to 0 makes the script non-interactive

## BUG FIX: 2019-11-06 | Set this to 1 in order to empty the config directory set into $NGINX_PATH. 
## Usefull if you are generating a configuration for another domain.
## ONLY CHECK THIS IF YOU KNOW WHAT YOU ARE DOING
CLEAN_CONFIG=0

## Nginx and certbot service names from docker-compose
NGINX_SERVICE=pegb-proxy 
CERTBOT_SERVICE=pegb-certbot


## Ask the user to confirm if he wishes to delete the current certificates in $DATA_PATH
if [[ $ASK -ne 0 ]]
then
	if [ -d "$DATA_PATH" ]
	then
		read -p "By proceeding and answering Y the script will replace any existing certificates for $DOMAINS. Continue and replace existing certificates? (y/N) " decision
	
		if [ "$decision" != "Y" ] && [ "$decision" != "y" ]
		then
			exit
		fi
	fi
else
	echo "Non-interactive mode has been enabled. The script will resume on its own in 5 secs. Press CTRL+C to cancel!"
	sleep 5
fi


## Download reccomended TLS parameters as per the Let's Encrypt reccomendations
if [ ! -e "$DATA_PATH/conf/options-ssl-nginx.conf" ] || [ ! -e "$DATA_PATH/conf/ssl-dhparams.pem" ]
then
	echo "### Downloading recommended TLS parameters ..."
	mkdir -p "$DATA_PATH/conf"
	curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/tls_configs/options-ssl-nginx.conf > "$DATA_PATH/conf/options-ssl-nginx.conf"
	curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/ssl-dhparams.pem > "$DATA_PATH/conf/ssl-dhparams.pem"
	echo
fi


## Creating dummy certificate to allow nginx to start
echo "### Creating dummy certificate for $DOMAINS ..."
KEY_PATH="/etc/letsencrypt/live/$DOMAINS"
mkdir -p "$DATA_PATH/conf/live/$DOMAINS"
/usr/local/bin/docker-compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:1024 -days 365\
    -keyout '$KEY_PATH/privkey.pem' \
    -out '$KEY_PATH/fullchain.pem' \
    -subj '/CN=localhost'" $CERTBOT_SERVICE
echo


## Generate the new NGINX Config
echo "### Generating NGINX config for $DOMAINS"
echo
if [[ $CLEAN_CONFIG -ne 0 ]]
then
	echo "# CLEAN_CONFIG set to 1"
	echo "# Existing NGINX Configuration will be deleted and replaced with new in 5 seconds. Press CTRL+C to abort ..."
	sleep 5
	echo "# Cleaning up the config directory $NGINX_PATH"
	rm -f $NGINX_PATH/*.conf
	echo
fi

cat >"$NGINX_PATH/$NGINX_CONFIG_FILE" <<EOF
upstream pegb-app {
    server pegb-app:8080;
}

upstream pegb-api {
    server pegb-api:5000;
}

server {
    listen 80;
    server_name ${DOMAINS[0]} ${DOMAINS[1]};

    location /.well-known/acme-challenge/ {
        allow all;
        root /var/www/certbot;
    }

    location / {
        allow all;
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name ${DOMAINS[0]} ${DOMAINS[1]};

    # Letsencrypt
    ssl_certificate /etc/letsencrypt/live/${DOMAINS[0]}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAINS[0]}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        allow all;
        proxy_pass http://pegb-app;
    }
}

server {
    listen 5443 ssl;
    server_name ${DOMAINS[0]};

    # Letsencrypt
    ssl_certificate /etc/letsencrypt/live/${DOMAINS[0]}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAINS[0]}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        allow all;
        proxy_pass http://pegb-api;
    }
}
EOF
echo


echo "### Starting nginx ..."
/usr/local/bin/docker-compose up --force-recreate -d $NGINX_SERVICE
echo


## If staging is set to other than 0 the dummy certificates created previously will not be deleted
if [[ $STAGING -eq 0 ]]
then
	echo "### Deleting dummy certificate for $DOMAINS ..."
	/usr/local/bin/docker-compose run --rm --entrypoint "\
  	rm -Rf /etc/letsencrypt/live/$DOMAINS && \
  	rm -Rf /etc/letsencrypt/archive/$DOMAINS && \
  	rm -Rf /etc/letsencrypt/renewal/$DOMAINS.conf" $CERTBOT_SERVICE
	echo
else
	echo "### STAGING mode has been enabled, the dummy certificates will not be removed, moving on ..."
	echo
fi


## Request the certificate
echo "### Requesting Let's Encrypt certificate for $DOMAINS ..."
## Join $DOMAINS to -d args
domain_args=""
for domain in "${DOMAINS[@]}"
do
	domain_args="$domain_args -d $domain"
done


## Select appropriate email arg
case "$EMAIL" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $EMAIL" ;;
esac


## Enable staging mode if needed
if [ $STAGING != "0" ]; then staging_arg="--staging"; fi

/usr/local/bin/docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --non-interactive \
    --rsa-key-size $RSA_KEY_SIZE \
    --agree-tos \
    --force-renewal" $CERTBOT_SERVICE
echo


echo "### Reloading nginx ..."
/usr/local/bin/docker-compose exec $NGINX_SERVICE nginx -s reload
echo

sleep 3

echo "### All done! Browse to https://${DOMAINS[0]} to see your website!"
echo

