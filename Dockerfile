FROM ubuntu:14.04

RUN apt-get -y update

#-------------Pre-requisites ----------------------------------------------------
RUN apt-get install -y --no-install-recommends unzip openjdk-7-jre-headless openjdk-7-jre vim git python-software-properties wget pwgen ca-certificates
ADD resources /tmp/resources


#-------------- TOMCAT  ----------------------------
#commenting out apt-get install tomcat7
#RUN apt-get install -y --no-install-recommends tomcat7 tomcat7-admin

#manual install of tomcat7
ENV TOMCAT_MAJOR_VERSION 7
ENV TOMCAT_MINOR_VERSION 7.0.55
ENV CATALINA_HOME /opt/tomcat7

RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
wget -qO- https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
   tar zxf apache-tomcat-*.tar.gz && \
   rm apache-tomcat-*.tar.gz && \
   mv apache-tomcat* ${CATALINA_HOME}

ADD create_tomcat_admin_user.sh /create_tomcat_admin_user.sh
ADD tomcat_run.sh /tomcat_run.sh
RUN chmod +x /*.sh

#-------------- POSTGRES/POSTGIS----------------------------
#RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
#RUN sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" >> /etc/apt/sources.list.d/postgresql.list'
#RUN sudo apt-get -y update
#RUN apt-get install -y --no-recommends postgresql-9.3 postgresql-9.3-postgis-2.1

RUN apt-get install -y --no-install-recommends postgresql postgresql-contrib postgis postgresql-9.3-postgis-2.1

#------------- Geoserver ----------------------------------------------------
ENV GEOSERVER_VERSION 2.5.3
RUN if [ ! -f /tmp/resources/geoserver.war.zip ]; then \
      wget -c http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-war.zip -O /tmp/resources/geoserver.war.zip; \
   fi; \
   unzip /tmp/resources/geoserver.war.zip -d /tmp/resources/geoserver && \
   mkdir /tmp/webapps && \
   unzip /tmp/resources/geoserver/geoserver.war -d /tmp/webapps/geoserver 

#add plugins
RUN wget -c http://sourceforge.net/projects/geoserver/files/GeoServer/2.5.3/extensions/geoserver-2.5.3-app-schema-plugin.zip -O /tmp/resources/geoserver-app-schema-plugin.zip && \
   unzip /tmp/resources/geoserver-app-schema-plugin.zip -d /tmp/webapps/geoserver/WEB-INF/lib

#move geoserver to webapps
RUN mv /tmp/webapps/geoserver ${CATALINA_HOME}/webapps 

ENV GEOSERVER_DATA_DIR  /opt/geoserver_data

ADD geoserver_data  ${GEOSERVER_DATA_DIR}


EXPOSE 8080
#CMD service tomcat7 start && tail -f /var/lib/tomcat7/logs/catalina.out
CMD ["/tomcat_run.sh"]
