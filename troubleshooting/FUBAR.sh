#!/bin/bash
#making vhost listen to 0.0.0.0
sed -i 's/mntlab/*/' /etc/httpd/conf.d/vhost.conf 
#setting server name
sed -i '/80>/a ServerName mntlab' /etc/httpd/conf.d/vhost.conf 
#deleting unnecessary vhost from httpd.conf
sed -i '/^<VirtualHost/,/^<\/VirtualHost>/{d}' /etc/httpd/conf/httpd.conf
#setting httpd default server name
sed -i '1 i\ServerName 127.0.0.1' /etc/httpd/conf/httpd.conf
#fixing workers file to work with the listed worker
sed -i 's/worker-jk@ppname/tomcat.worker/' /etc/httpd/conf.d/workers.properties 
#fixing worker ip address
sed -i 's/192.168.56.100/192.168.56.10/' /etc/httpd/conf.d/workers.properties 
#fixing init.d tomcat file to give output
sed -i 's/success//' /etc/init.d/tomcat
sed -i 's/ > \/dev\/null//' /etc/init.d/tomcat
#removing wrong variable definitions from tomcat user's bashrc file
sed -i '/export/d' /home/tomcat/.bashrc
#making tomcat user and group the owners of logs directory
chown tomcat:tomcat /opt/apache/tomcat/current/logs/
#switching java version to x64
alternatives --set java /opt/oracle/java/x64//jdk1.7.0_79/bin/java
#adding error redirect support to vhost
sed -i 's/JkMount \/\* tomcat.worker/JkMount \/\* tomcat.worker;use_server_errors=404,500,503,504/' /etc/httpd/conf.d/vhost.conf
#starting tomcat
service tomcat start
#restarting httpd
service httpd restart
#removing "i" attribute from iptables file
chattr -i /etc/sysconfig/iptables
#enabling 80 port, and adding ESTABLISHED line
sed -i '/22 -j ACCEPT/a -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT' /etc/sysconfig/iptables
sed -i 's/RELATED/RELATED,ESTABLISHED/' /etc/sysconfig/iptables
#magical workaround to enable iptables starting with the script
sed -i '/COMMIT/a\ \' /etc/sysconfig/iptables
sed -i '14 d' /etc/sysconfig/iptables
#starting iptables
service iptables start
#adding httpd and tomcat to autostart
chkconfig httpd on
chkconfig tomcat on
