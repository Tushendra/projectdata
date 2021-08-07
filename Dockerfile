FROM tomcat
RUN rm -fr /usr/local/tomcat/webapps/ROOT
COPY target/pro1.war /usr/local/tomcat/webapps/ROOT.war