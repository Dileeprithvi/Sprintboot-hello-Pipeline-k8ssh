# Pull base image 
#From tomcat:8-jre8 

#COPY ./webapp.war /usr/local/tomcat/webapps
#RUN cp -R /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps


#FROM tomcat:latest

#COPY ./webapp.war /usr/local/tomcat/webapps


FROM tomcat:latest
ADD target/*.war /usr/local/tomcat/webapps/
RUN value=`cat conf/server.xml` && echo "${value//8080/8050}" >| conf/server.xml
CMD ["catalina.sh", "run"]