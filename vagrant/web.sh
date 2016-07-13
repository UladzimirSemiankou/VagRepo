#!/bin/bash
yum install autoconf -y
yum install libtool -y
yum install httpd-devel -y
yum install httpd -y
wget http://archive.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.41-src.tar.gz
tar -xvzf tomcat-connectors-1.2.41-src.tar.gz 
cd tomcat-connectors-1.2.41-src/native/
./buildconf.sh 
./configure --with-apxs=/usr/sbin/apxs 
make
cp apache-2.0/mod_jk.so /etc/httpd/modules/
cp -f /sources/httpd.conf /etc/httpd/conf/
cp -f /sources/workers.properties /etc/httpd/conf/
service httpd start
chkconfig httpd on
