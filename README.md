# [pegbtech_demo] React_redux demo application with IaaS example (in 15mins or less)

This is a sample aplication utilizing Docker, Ansible and Bash to quickly provision a server and deploy a react_redux applicaiton from https://github.com/erikras/react-redux-universal-hot-example

## Technologies used
* Bash - For general scripting
* Ansible - For the IaaS part and provisioning the host 
* Docker and docker-compose
  * [pegb_app] - Where the application is packaged
  * [pegb_web] - For the web proxy. Consists of two containers
    * [pegb-proxy] - Nginx container for the proxy
    * [pegb-certbot] - Certbot container for the TLS

## Deployment steps
In general the deployment is done in two phases. 
* **Target system provisioning** phase, where the docker server is provisioned automatically; 
* **Application deployment** phase to deploy the application. This is to ensure the applications's portability. With this approach once you have the target system ready for provisioning the entire operation is done in about 15mins out of which the applicaiton building step takes most of the time.

### Terminology
* **Own system** - Your own linux system from where you will do most of the work;
* **Target system** - The system which will serve as a host for the application. In this excersize it is called pegbtech-docker01.

### Prerequisites
Make sure the prerequisites are met:
1. Fresh CentOS7 installation for the target system (currently only CentOS7 is supported);
2. A test domain name with A and CNAME (www) records pointed to your target system's public IP address. Otherwise letsencrypt will not work; 
3. Your own system with **ansible** and **git**, from where you will do the deployment.
4. The target system must have access to the internet (obviously). If it is behind NAT make sure that port 80 and 443 are forwarded to it otherwise letsencrypt will fail.

### Clone the repo
Clone the repo on your own system:
```
git clone https://github.com/spirit986/pegbtech_demo.git && cd pegbtech_demo
```

### Target system provisioning
There are two playbooks for preparing the system: `sys_prepare_playbook.yml ` and `docker_prepare_playbook.yml` in the parrent directory. Once you confirm that you can freely login to your target system using your private key execute the two playbooks against it. The playbooks will provision the system using some reccomended applications and then install docker and docker-compose.

1. Confirm that you can login without problems using `ssh root@<IP-ADDR-OF-TARGET-SYSTEM> -i <PATH/TO/YOUR/PRIVATE/KEY>`

2. Update the `hosts` file in the main folder. Open the file with a text editor and update the IP address of the `pegbtech-docker01` host with the IP address of your target system.
```
pegbtech-docker01 ansible_host=<SET-THE-IP-OF-YOUR-TARGET-SYSTEM-HERE> ansible_user=root
```

3. Execute `sys_prepare_playbook.yml`
```
ansible-playbook -i hosts --private-key=<PATH/TO/YOUR/PRIVATE/KEY> ./sys_prepare_playbook.yml
```
4. Execute `docker_prepare_playbook.yml `
```
ansible-playbook -i hosts --private-key=<PATH/TO/YOUR/PRIVATE/KEY> ./docker_prepare_playbook.yml 
```
After these steps you should have your docker server ready for the application deployment.


### Application deployment
1. Once you login to the target system confirm that docker is properly installed by running a simple hello-world container: `docker run hello-world`;
2. Clone this git repo preferably into your home folder.
```
git clone https://github.com/spirit986/pegbtech_demo.git && cd pegbtech_demo
```
3. Deploy the application:
```
## Build the containers
docker-compose build

##Deploy the containers
docker-compose up -d
```
4. **Enable TLS**. Once the application is deployed if you issue a `docker ps -a` you will notice that the nginx container `pegb-proxy` is down. This is because nginx is missing the required certificates. To generate the certificates use the `letsencrypt-enable.sh` script which will enable TLS according to Let's Encrypt best-practice. This is requred only once after which the certbot container will renew its certificate accordingly.
     * **BEFORE YOU EXECUTE THE SCRIPT** - If you simply wish to test the TLS and skip the real certificate generation simply edit the `letsencrypt-enable.sh` script and set the `STAGING=1`. This way the certificate generation will be tested, but Let's Encrypt will not issue a real certificate.
     * Edit the script and set the EMAIL variable to your email;
     * Optionally set the STAGING=1 to just test against Let's Encrypt and skip the actual certificate generation;
     * Execute the script using `./letsencrypt-enable.sh`;
 5. Test your application 
     * For a simple test simply browse http://yourdomain.com. You should be redirected to https://yourdomain.com and the application will open.
     * To test SSL browse to https://www.sslshopper.com and enter the URL of your application for which you should receive a straight A for it.
