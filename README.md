docker-geoserver
================

Docker deployment of Geoserver. Currently this includes:
* Postgres 9.3 / Postgis 2.1
* Tomcat 7.0.55
* Geoserver 2.5.3 with App Schema plugin
* sshd

Note: The docker container produced is not secured for production deployment.

Quick-start
----------
Build:
   sudo ./build.sh


Run:
   sudo ./run.sh

Clean-up:
   sudo ./clean-up.sh

Inspect using `docker ps`.

Ssh is available with username 'root' and password 'siss'. Container sets up a Postgres/PostGIS DB user docker:docker. 
Inspect the docker container for the port number to connect using ssh or to the postgresdb.



Installation
------------
See https://github.com/CSIRO-enviro-informatics/docker-geoserver/wiki/Installation


