#!/bin/bash
until `curl --output /dev/null --silent --head --fail http://host.docker.internal:9600`; do
    printf '.'
    sleep 5
done
npm start