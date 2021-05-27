#!/bin/bash

rm ../packages/node-local-server*
rm -rf ../node-local-server/node_modules
cd ../
tar -zcvf packages/node-local-server.tar.gz node-local-server
TIMESTAMP=`date +"%Y-%m-%d.%H:%M:%S"`
cp packages/node-local-server.tar.gz packages/node-local-server.$TIMESTAMP.tar.gz
cp metricbeat.yml packages/metricbeat.yml