#!/bin/bash

rm -rf metrics-server*
mkdir -p metrics-server
cp -r src index.js package.json yarn.lock metrics-server
tar -zcvf metrics-server.tar.gz metrics-server
TIMESTAMP=`date +"%Y-%m-%d.%H:%M:%S"`
cp metrics-server.tar.gz metrics-server.$TIMESTAMP.tar.gz
rm -rf metrics-server