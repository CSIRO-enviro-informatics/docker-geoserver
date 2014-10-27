docker-geoserver
================

Docker deployment of geoserver

Quick-start
----------
Build:
   sudo docker build -t csiro-env:geoserver .


Run:
   sudo docker run --privileged=true  -p 8080:8080 -d -t csiro-env:geoserver
