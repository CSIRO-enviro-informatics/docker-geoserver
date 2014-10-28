#!/bin/bash

docker kill geoserver
docker rm geoserver


docker build -t csiro_env/geoserver .
docker run --name "geoserver" -p 8080:8080 -d -t csiro_env/geoserver


