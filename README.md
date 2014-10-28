docker-geoserver
================

Docker deployment of Geoserver. Currently this includes:
* Postgres 9.3 / Postgis 2.1
* Tomcat 7.0.55
* Geoserver 2.5.3 with App Schema plugin

Quick-start
----------
Build:
   sudo docker build -t csiro_env/geoserver .


Run:
   sudo docker run --name "geoserver" -p 8080:8080 -d -t csiro_env/geoserver
