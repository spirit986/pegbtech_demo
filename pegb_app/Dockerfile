## pegb-app
## Setup pegbtech-demo app container

FROM centos:centos7

ENV HOST=0.0.0.0

RUN yum install -y --nogpgcheck bzip2 wget git curl epel-release && \
    mkdir -p /opt/pegbtech-demo

RUN curl --silent --location https://rpm.nodesource.com/setup_6.x | bash -

RUN yum install -y --nogpgcheck nodejs gcc-c++ make 

RUN git clone https://github.com/erikras/react-redux-universal-hot-example.git /opt/pegbtech-demo

WORKDIR /opt/pegbtech-demo

RUN npm install && \
    npm run build

CMD ["/usr/bin/npm", "run", "start"]

EXPOSE 8080 3030

