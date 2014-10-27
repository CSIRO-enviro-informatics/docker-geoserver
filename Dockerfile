FROM ubuntu:14.04


RUN apt-get -y update


#-------------Pre-requisites ----------------------------------------------------
RUN apt-get install -y --no-install-recommends unzip openjdk-7-jre-headless openjdk-7-jre vim git python-software-properties wget
ADD resources /tmp/resources


#-------------- TOMCAT  ----------------------------
RUN apt-get install -y --no-install-recommends tomcat7 tomcat7-admin


#-------------- POSTGRES/POSTGIS----------------------------
#RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
#RUN sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" >> /etc/apt/sources.list.d/postgresql.list'
#RUN sudo apt-get -y update
#RUN apt-get install -y --no-recommends postgresql-9.3 postgresql-9.3-postgis-2.1

RUN apt-get install -y --no-install-recommends postgresql postgresql-contrib postgis postgresql-9.3-postgis-2.1

#------------- Geoserver ----------------------------------------------------
RUN if [ ! -f /tmp/resources/geoserver.war.zip ]; then \
wget -c http://sourceforge.net/projects/geoserver/files/GeoServer/2.5.3/geoserver-2.5.3-war.zip -O /tmp/resources/geoserver.war.zip; \
fi; \
unzip /tmp/resources/geoserver.war.zip -d /var/lib/tomcat7/webapps 


EXPOSE 8080
CMD service tomcat7 start && tail -f /var/lib/tomcat7/logs/catalina.out
