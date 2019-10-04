#!/bin/bash
###
## Applicaion provisioning steps
## Use this script only to provision the applicaiton manually for testing
###

yum install -y bzip2 npm wget git
git clone https://github.com/spirit986/react-redux-universal-hot-example.git pegbtech-demo

cd pegbtech-demo && \
npm install && \
npm run build && \
HOST=0.0.0.0 npm run start
