# [pegbtech_demo] React_redux demo application with IaaS example

This is a sample aplication utilizing Docker, Ansible and Bash to deploy a react_redux applicaiton from https://github.com/erikras/react-redux-universal-hot-example

## Technologies used
* Bash - For general scripting
* Ansible - For the IaaS part and provisioning the host 
* Docker and docker-compose
  * [pegb_app] - Where the application is packaged
  * [pegb_web] - For the web proxy. Consists of two containers
    * Nginx container for the proxy
    * Certbpt container for the TLS

## Deployment steps

### Terminology
* **Own system** - Your own linux system from where you will do most of the work;
* **Target system** - The system which will serve as a host for the application. In this excersize it is called pegbtech-docker01.

### Prerequisites
Make sure the prerequisites are met:
1. Fresh CentOS7 installation for the target system (currently only CentOS7 is supported);

2. Public/private key authentication with the target system;
   * It is a good idea to update your `~/.ssh/config` file with the private key for your target system. This will allow dockercli to be used remotely during the deployment phase.
```
Host 172.16.0.108
  IdentityFile ~/.ssh/<YOUR-PRIVATE-KEY>
```

3. Your own system with **ansible**, **git**, **docker** and **docker-compose** from where you will do the deployment. Docker and docker-compose are not mandatory for your system. However they are highly reccomended for the deployment phase. If you don't want to install docker on your system then for the deployment phase you will have to ssh into the target system and clone the repo there.

4. The target system must have access to the internet (obviously). If it is behind NAT make sure that port 80 and 443 are forwarded to it otherwise letsencrypt will fail.
```
## Install Ansible on your own system
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
     python get-pip.py && \
	 pip install ansible --upgrade
```

### Clone the repo
Clone the repo on your own system:
```
git clone https://github.com/spirit986/pegbtech_demo.git && cd pegbtech_demo
```

### Prepare the target system system
There are two playbooks for preparing the system: `sys_prepare_playbook.yml ` and `docker_prepare_playbook.yml` in the parrent directory. Once you confirm that you can freely login to your target system using your private key execute the two playbooks against it. The playbooks will provision the system using some reccomended applications and then install docker and docker-compose.

1. Confirm that you can login without problems using `ssh root@<IP-ADDR-OF-TARGET-SYSTEM> -i <PATH/TO/YOUR/PRIVATE/KEY>`
2. Execute `sys_prepare_playbook.yml`
```
ansible-playbook -i hosts --private-key=<PATH/TO/YOUR/PRIVATE/KEY> ./sys_prepare_playbook.yml
```
3. Execute `docker_prepare_playbook.yml `
```
ansible-playbook -i hosts --private-key=<PATH/TO/YOUR/PRIVATE/KEY> ./docker_prepare_playbook.yml 
```
After these steps you should have your docker server ready for deployment. To veryfy the installation is successfull simply run from your own system:
```
docker -H ssh://root@<IP-ADDR-OF-TARGET-SYSTEM> run hello-world
```
