#!/bin/bash
yum install java -y
wget http://archive.apache.org/dist/tomcat/tomcat-8/v8.5.3/bin/apache-tomcat-8.5.3.tar.gz
tar -xvzf apache-tomcat-8.5.3.tar.gz 
cp -f /sources/tomcat-users.xml apache-tomcat-8.5.3/conf/
cp -f /sources/server.xml apache-tomcat-8.5.3/conf/
apache-tomcat-8.5.3/bin/startup.sh
