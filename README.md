docker-geoserver
================

Docker deployment of geoserver

Quick-start
----------
Build:
   sudo docker build -t csiro_env/geoserver .


Run:
   sudo docker run --name "geoserver" -p 8080:8080 -d -t csiro_env/geoserver
