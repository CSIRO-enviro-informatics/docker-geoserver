/bin/bash

docker kill geoserver
docker rm geoserver


docker build -t csiro_env/geoserver .

