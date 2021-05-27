#!/bin/bash
until `curl --output /dev/null --silent --head --fail http://host.docker.internal:9600`; do
    printf '.'
    sleep 5
done

service metricbeat start
cd node-local-server
tmux new-session -d -s io "npm run start:io"
npm run start:monitoring