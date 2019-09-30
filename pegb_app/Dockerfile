---
## pegb_app
## Setup pegbtech-demo app

FROM centos:centos7

ENV HOST=0.0.0.0

RUN yum install -y bzip2 npm wget git curl && \
    mkdir -p /opt/pegbtech-demo

WORKDIR /opt/pegbtech-demo

RUN git clone https://github.com/erikras/react-redux-universal-hot-example.git && \
    npm install && \
    npm run build

CMD ["/usr/bin/npm", "run", "start"]

EXPOSE 8080 3030
...