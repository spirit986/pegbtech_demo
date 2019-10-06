# [pegbtech_demo] React_redux demo application with IaaS example (in 15mins or less)

This is a sample aplication utilizing Docker, Ansible and Bash to quickly provision a server and deploy a react_redux applicaiton from https://github.com/erikras/react-redux-universal-hot-example.

Since the react-redux boilerplate project is very old I forked erikras' repo into my own repo from where I am pulling the boilerplate for further deployment: https://github.com/spirit986/react-redux-universal-hot-example

## TL;DR Quick Steps for deployment
Read this if you do not wish to read the full guide
#### Demo setup:
[YOUR-LINUX-SYSTEM] -----> [TARGET-LINUX-SYSTEM][IP-ADDRESS] -----> [INTERNET]

#### PHASE1 - System Deployment | From your own system
```
## Clone the repo
$ git clone https://github.com/spirit986/pegbtech_demo.git && cd pegbtech_demo

## Update ansible_host= inside ./hosts with the IP-ADDRESS of the TARGET-LINUX-SYSTEM
$ vim ./hosts

## Execute the playbooks
$ ansible-playbook -i hosts --private-key=<PATH/TO/YOUR/PRIVATE/KEY> ./sys_prepare_playbook.yml
$ ansible-playbook -i hosts --private-key=<PATH/TO/YOUR/PRIVATE/KEY> ./docker_prepare_playbook.yml
```

#### PHASE2 - Application Deployment | From the target system
```
## SSH to the target system
$ ssh root@<TARGET-SYSTEM-IP> -i /YOUR/PRIVATE/KEY

## Clone the repo again
$ git clone https://github.com/spirit986/pegbtech_demo.git && cd pegbtech_demo

## Deploy the containers
$ docker-compose up -d

## Update ./letsencrypt-enable.sh with the desired domain
## Set DOMAINS=() with the desired domains
## Set STAGING to 1 or 0 (default is 1)
## Set EMAIL="" with your email address
vim ./letsencrypt-enable.sh

## Execute the script
./letsencrypt-enable.sh

## Test the web service by visiting:
## https://yourdomain.com
## https://yourdomain.com:5443
```

# Full deployment guide

## Technologies used
* Bash - For general scripting;
* Ansible - For the IaaS part and provisioning the host;
* Python Flask - To provision a simple API backend;
* MongoDB - For implementing a simple database;
* Docker and docker-compose
  * [pegb_app] - Where the application is packaged;
  * [pegb_web] - For the web proxy. Consists of two containers;
    * [pegb-proxy] - Nginx container for the proxy;
    * [pegb-certbot] - Certbot container for the TLS;
  * [pegb_api] - Python Flask - A simple API backend for demonstration;
  * [pegb_db] - MongoDB - A simple database for the backend to talk to;
* DockerHub - To store a prebuilt image of [pegb-app] container

## Deployment steps
In general the deployment is done in two phases. 
* **Target system provisioning** phase, where the docker server is provisioned automatically; 
* **Application deployment** phase to deploy the application. This is to ensure the applications's portability. With this approach once you have the target system ready for provisioning the entire operation is done in about 15mins out of which the applicaiton building step takes most of the time.

### Terminology
* **Own system** - Your own linux system from where you will do most of the work;
* **Target system** - A CentOS7 system which will serve as a host for the application. In this excersize its hostname is called `pegbtech-docker01`;
* To avoid confusion, keep in mind that the container project folder names are written with underscores (pegb_app, pegb_web etc..) while the container names and the service names within `docker-compose.yml` are written with dashes (pegb-app, pegb-web etc).

### Prerequisites
Make sure the prerequisites are met:
1. Fresh CentOS7 installation for the target system (currently only CentOS7 is supported);
2. A test domain name with A and CNAME (www) records pointed to your target system's public IP address. Otherwise letsencrypt will not work; 
3. Your own system with **ansible** and **git**, from where you will do the deployment;
4. The target system must have access to the internet (obviously) with ports 80, 443 and 5443 opened on the firewall. If it is behind NAT make sure that port 80 and 443 are forwarded to it otherwise letsencrypt will fail. Port 5443 should also be open for the API.
5. Once you have the **Target system** ready, make sure that you can ssh to it using public/private key authentication.

### Clone the repo
Clone the repo on your own system:
```
git clone https://github.com/spirit986/pegbtech_demo.git && cd pegbtech_demo
```

### Target system provisioning
There are two playbooks for preparing the system: `sys_prepare_playbook.yml ` and `docker_prepare_playbook.yml` in the parrent directory. Once you confirm that you can freely login to your target system using your private key execute the two playbooks against it. The playbooks will provision the system using some reccomended applications and then install docker and docker-compose.

1. Confirm that you can login without problems using `ssh root@<IP-ADDR-OF-TARGET-SYSTEM> -i <PATH/TO/YOUR/PRIVATE/KEY>`;

2. Update the `hosts` file in the main folder. Open the file with a text editor and update the IP address of the `pegbtech-docker01` host with the IP address of your target system;
```
pegbtech-docker01 ansible_host=<SET-THE-IP-OF-YOUR-TARGET-SYSTEM-HERE> ansible_user=root
```

3. Execute `sys_prepare_playbook.yml`;
```
ansible-playbook -i hosts --private-key=<PATH/TO/YOUR/PRIVATE/KEY> ./sys_prepare_playbook.yml
```
4. Execute `docker_prepare_playbook.yml `;
```
ansible-playbook -i hosts --private-key=<PATH/TO/YOUR/PRIVATE/KEY> ./docker_prepare_playbook.yml 
```
After these steps you should have your docker server ready for the application deployment.


### Application deployment
1. Once you login to the target system confirm that docker is properly installed by running a simple hello-world container: `docker run hello-world`;
2. Clone this git repo preferably into your home folder;
```
git clone https://github.com/spirit986/pegbtech_demo.git && cd pegbtech_demo
```
3. Deploy the entire stack of containers using `docker-compose up -d`. 

#### Explanation
Because building the react-redux application [pegb-app] container consumes most deployment time, this contaienr has been prebuilt and pushed to DockerHub. This step reduces the entire deployment time from 15mins to 5min or less. After the containers are deployed proceed to step 4 to generate the certificate and the NGINX configuration file. However if you wish to build all of the containers again for some reason, you can use the alternative docker-compose file provided. Use `docker-compose -f docker-compose.build.yml build && docker-compose -f docker-compose.build.yml up -d` to build and start the application manually.

4. **Enable TLS**. Once the application is deployed if you issue a `docker ps -a` you will notice that the nginx container `pegb-proxy` will not respond to any requests. This is because nginx doesn't have any configuration file loaded. To generate the configuration file for your domains and the certificates use the `letsencrypt-enable.sh` script which will enable TLS according to Let's Encrypt best-practice. This is requred only once during the initial deployment phase after which the certbot container will renew its certificate accordingly.

#### BEFORE YOU EXECUTE THE SCRIPT
1. Edit the script using vim or nano;
2. Update the `DOMAINS=()` section with your domain. The www. domain should go second. For example: `DOMAINS=(pegtech-demo.tomspirit.me www.pegtech-demo.tomspirit.me)`;
3. **Recommended:** Set the `EMAIL=""` to a valid email of your own.
4. Set `STAGING=1` to 0 if you wish to actually generate a valid Let'sEncrypt certificate. Leave it to 1 to simply do a staging dry run. When you do a dry run the script will leave dummy self signed certificates for you to test your application.
5. Execute the script using: `./letsencrypt-enable.sh`

### Test your application
1. For a simple test simply browse http://yourdomain.com. You should be redirected to https://yourdomain.com and the application will open;
2. To test SSL browse to https://www.sslshopper.com and enter the URL of your application for which you should receive a straight A for it;
3. To test the API browse to https://yourdomain.com:5443 where you will be presented with a page with instructions. 

