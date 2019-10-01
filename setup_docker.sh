#!/bin/bash

## Setup docker for centos


# Install required packages
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2


# Set up the stable repository
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo


# Install docker-ce
yum install -y docker-ce docker-ce-cli containerd.io && \
systemctl enable docker && systemctl start docker


# Setup docker-compose
curl \
-L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose && \
chmod +x /usr/local/bin/docker-compose


