#!/bin/bash
###
## General preparation of the system 
###

SYS_HOSTNAME=pegbtech-web

## Set the hostname
hostnamectl set-hostname $SYS_HOSTNAME
SYS_HOSTNAME=$(hostnamectl | grep hostname | awk '{print $3}')
echo "127.0.0.1 $SYS_HOSTNAME" >>/etc/hosts

yum update -y --exclude=grub*

# Disable SELINUX and reboot
sed 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config



