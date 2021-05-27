#!/bin/bash

cd ~/app
wget "https://storage.yandexcloud.net/solar-monitoring/packages/node-local-server.tar.gz"
tar xfvz node-local-server.tar.gz
rm *.tar*
cd node-local-server
npm install
echo `date` > .version
cd ~/app