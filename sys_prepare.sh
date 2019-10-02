#!/bin/bash
###
## General preparation of the system 
###

SYS_HOSTNAME=pegbtech-docker01
SELF=$(basename "$0")

logger "$(date "+%FT%T") - $SELF - $(who) - This script will set the system hostname to $SYS_HOSTNAME, and disable SELinux"

## Set the hostname
hostnamectl set-hostname $SYS_HOSTNAME
SYS_HOSTNAME=$(hostnamectl | grep hostname | awk '{print $3}') && \
echo "127.0.0.1 $SYS_HOSTNAME" >>/etc/hosts

# Disable SELINUX and reboot
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config && \
/sbin/setenforce 0
#systemctl reboot

echo "sys_prepare.sh has been executed" >> /root/executed-sys_prepare.sh.txt

