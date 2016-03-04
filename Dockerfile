FROM ubuntu:14.04

#RUN echo "deb http://archive.ubuntu.com/ubuntu/ precise universe" >> /etc/apt/sources.list
RUN apt-get -y update

#-------------Pre-requisites ----------------------------------------------------
RUN apt-get install -y --no-install-recommends unzip openjdk-7-jre-headless openjdk-7-jre vim git python-software-properties wget pwgen software-properties-common 
RUN sudo add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable
RUN sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt trusty-pgdg main" >> /etc/apt/sources.list'
RUN sudo wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
RUN apt-get -y update
#ca-certificates
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


#------------- Geoserver ----------------------------------------------------
ENV GEOSERVER_VERSION 2.6.2
RUN if [ ! -f /tmp/resources/geoserver.war.zip ]; then \
      wget -c http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-war.zip -O /tmp/resources/geoserver.war.zip; \
   fi; \
   unzip /tmp/resources/geoserver.war.zip -d /tmp/resources/geoserver && \
   mkdir /tmp/webapps && \
   unzip /tmp/resources/geoserver/geoserver.war -d /tmp/webapps/geoserver 

#add plugins
RUN wget -c http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-app-schema-plugin.zip -O /tmp/resources/geoserver-app-schema-plugin.zip && \
   unzip /tmp/resources/geoserver-app-schema-plugin.zip -d /tmp/webapps/geoserver/WEB-INF/lib

#move geoserver to webapps
RUN mv /tmp/webapps/geoserver ${CATALINA_HOME}/webapps 

ENV GEOSERVER_DATA_DIR  /opt/geoserver_data

ADD geoserver_data  ${GEOSERVER_DATA_DIR}

#CMD service tomcat7 start && tail -f /var/lib/tomcat7/logs/catalina.out




#-------------- POSTGRES/POSTGIS----------------------------
#RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
#RUN sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" >> /etc/apt/sources.list.d/postgresql.list'
#RUN sudo apt-get -y update
#RUN apt-get install -y --no-recommends postgresql-9.3 postgresql-9.3-postgis-2.1
RUN apt-get install -y --no-install-recommends postgresql postgresql-contrib postgis postgresql-9.5-postgis-2.1
#RUN service postgresql start && /bin/su postgres -c "createuser -d -s -r -l docker" && /bin/su postgres -c "psql postgres -c \"ALTER USER docker WITH ENCRYPTED PASSWORD 'docker'\"" && service postgresql stop

USER postgres
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    createdb -O docker docker

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible. 
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.5/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.5/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf

USER root

ADD postgis_run.sh /postgis_run.sh



#---- Locales
RUN apt-get  install -y language-pack-en-base

#supervisord
RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chmod +x /*.sh



EXPOSE 8080 5432
CMD ["/usr/bin/supervisord"]
#CMD ["/usr/sbin/sshd", "-D"]
#CMD /usr/sbin/sshd -D & /tomcat_run.sh & /postgis_run.sh
