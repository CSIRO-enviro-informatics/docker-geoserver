#!/bin/bash

docker run --name "geoserver" -p 8080:8080 -d -t csiro_env/geoserver
