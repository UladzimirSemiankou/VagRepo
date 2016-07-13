# Troubleshooting Semenkov V.V.

###Installed VM
```
vagrant up
```

###1. Checked url from server and client sides
```
curl -IL 192.168.56.10
```
*server*
>HTTP/1.1 302 Found

>Date: Tue, 12 Jul 2016 13:56:12 GMT

>Server: Apache

>Location: http://mntlab/

- redirection works, httpd is running

>HTTP/1.1 503 Service Temporarily Unavailable

>Date: Tue, 12 Jul 2016 13:56:12 GMT

>Server: Apache

- redirection destination is unavailable

*client*
>HTTP/1.1 302 Found

>Date: Wed, 13 Jul 2016 08:14:35 GMT

>Server: Apache

>Location: http://mntlab/

>Content-Type: text/html; charset=iso-8859-1

- redirection ends at mntlab

###2. Checked redirections
*httpd.conf*
- checked pass to error and access logs and inclusion of other logs and confs
- noticed redirection to mntlab

*error_log*
- no errors

- checked other confs
*vhosts.conf*
- noticed another vhost listening to port 80
- changed bad vhost configuration
```
sed -i 's/mntlab/*/' /etc/httpd/conf.d/vhost.conf 
sed -i '/80>/a ServerName mntlab' /etc/httpd/conf.d/vhost.conf
```
- found other log files
*error.log*
- empty
*access.log*
- 1 entry
- tried server curl -IL 192.168.56.10
- entry adds to access.log
- client curl -IL 192.168.56.10
- no entry added
- no redirect happened to vhost from client, no dns record for mntlab on client, needed to remove httpd.conf redirect
```
sed -i '/^<VirtualHost/,/^<\/VirtualHost>/{d}' /etc/httpd/conf/httpd.conf
service httpd restart
curl -IL 192.168.56.10
```
>HTTP/1.1 503 Service Temporarily Unavailable

>Date: Wed, 13 Jul 2016 08:40:42 GMT

>Server: Apache

>Last-Modified: Tue, 12 Jul 2016 07:41:37 GMT

>ETag: "21bbc-88a-5376b6616d900"

>Accept-Ranges: bytes

>Content-Length: 2186

>Connection: close

>Content-Type: text/html; charset=UTF-8

- redirect happened but service is unavailable, might mean bad redirect or service unavailability
- checked further redirection with mod_jk
*modjk.log*
>[Wed Jul 13 09:40:30 2016][17021:139722724702176] [info] init_jk::mod_jk.c (3365): mod_jk/1.2.37 initialized

>[Wed Jul 13 09:40:30 2016][17022:139722724702176] [info] init_jk::mod_jk.c (3365): mod_jk/1.2.37 initialized

>[Wed Jul 13 09:40:42 2016][17024:139722724702176] [info] jk_open_socket::jk_connect.c (627): connect to 127.0.0.1:8009 failed (errno=111)

>[Wed Jul 13 09:40:42 2016][17024:139722724702176] [info] ajp_connect_to_endpoint::jk_ajp_common.c (995): Failed opening socket to (127.0.0.1:8009) (errno=111)

>[Wed Jul 13 09:40:42 2016][17024:139722724702176] [error] ajp_send_request::jk_ajp_common.c (1630): (tomcat.worker) connecting to backend failed. Tomcat is probably not started or is listening on the wrong port (errno=111)

>[Wed Jul 13 09:40:42 2016][17024:139722724702176] [info] ajp_service::jk_ajp_common.c (2623): (tomcat.worker) sending request to tomcat failed (recoverable), because of error during request sending (attempt=1)

>[Wed Jul 13 09:40:42 2016][17024:139722724702176] [info] jk_open_socket::jk_connect.c (627): connect to 127.0.0.1:8009 failed (errno=111)

>[Wed Jul 13 09:40:42 2016][17024:139722724702176] [info] ajp_connect_to_endpoint::jk_ajp_common.c (995): Failed opening socket to (127.0.0.1:8009) (errno=111)

>[Wed Jul 13 09:40:42 2016][17024:139722724702176] [error] ajp_send_request::jk_ajp_common.c (1630): (tomcat.worker) connecting to backend failed. Tomcat is probably not started or is listening on the wrong port (errno=111)

>[Wed Jul 13 09:40:42 2016][17024:139722724702176] [info] ajp_service::jk_ajp_common.c (2623): (tomcat.worker) sending request to tomcat failed (recoverable), because of error during request sending (attempt=2)

>[Wed Jul 13 09:40:42 2016][17024:139722724702176] [error] ajp_service::jk_ajp_common.c (2643): (tomcat.worker) connecting to tomcat failed.

>[Wed Jul 13 09:40:42 2016][17024:139722724702176] [info] jk_handler::mod_jk.c (2788): Service error=-3 for worker=tomcat.worker

>[Wed Jul 13 09:40:42 2016]tomcat.worker 192.168.56.10 0.101937

- worker configuration was bad
*worker.properties*
- unknown worker worker-jk@ppname and ip
```
sed -i 's/worker-jk@ppname/tomcat.worker/' /etc/httpd/conf.d/workers.properties 
sed -i 's/192.168.56.100/192.168.56.10/' /etc/httpd/conf.d/workers.properties 
service httpd restart
curl -IL 192.168.56.10
```
>HTTP/1.1 503 Service Temporarily Unavailable

>Date: Wed, 13 Jul 2016 08:51:57 GMT

>Server: Apache

>Last-Modified: Tue, 12 Jul 2016 07:41:37 GMT

>ETag: "21bbc-88a-5376b6616d900"

>Accept-Ranges: bytes

>Content-Length: 2186

>Connection: close

>Content-Type: text/html; charset=UTF-8

- service still unavailable

###3. Checked if tomcat is running
```
ps aux | grep tomcat
```
- tomcat not working
- tried starting tomcat
```
service tomcat start
```
- tomcat not working
- checked init.d script
*/etc/init.d/tomcat*
- discovered the elimination of output from commands
```
sed -i 's/success//' /etc/init.d/tomcat
sed -i 's/ > \/dev\/null//' /etc/init.d/tomcat
```
- made commands giv output
```
service tomcat start
```
>Starting tomcatCannot find /tmp/bin/setclasspath.sh

>This file is needed to run this program

- checked startup.sh for setclasspath.sh reference
- no reference found
- found EXECUTABLE=catalina.sh
- checked catalina.sh
- found $CATALINA_HOME"/bin/setclasspath.sh
- checking how CATALINA_HOME is defined for tomcat user
```
su - tomcat
echo $CATALINA_HOME
```
>/tmp

- path was wrong
- checked bash profile
- no CATALINA_HOME defined
- found inclusion of .bashrc
- found CATALINA_HOME and JAVA_HOME defined in .bashrc, removed
```
sed -i '/export/d' /home/tomcat/.bashrc
service tomcat start
```
>touch: cannot touch `/opt/apache/tomcat/current/logs/catalina.out': Permission denied

>/opt/apache/tomcat//current/bin/catalina.sh: line 387: /opt/apache/tomcat/current/logs/catalina.out: Permission denied

- had no access to logs directory
- checked if directory existed and what permissions it had
```
ll /opt/apache/tomcat/current/
```
- existed, owner was root
- changed owner
```
chown tomcat:tomcat /opt/apache/tomcat/current/logs/
service tomcat start
```
>Starting tomcatUsing CATALINA_BASE:   /opt/apache/tomcat/current

>Using CATALINA_HOME:   /opt/apache/tomcat/current

>Using CATALINA_TMPDIR: /opt/apache/tomcat/current/temp

>Using JRE_HOME:        /usr

>Using CLASSPATH:       /opt/apache/tomcat/current/bin/bootstrap.jar:/opt/apache/tomcat/current/bin/tomcat-juli.jar

>Tomcat started.

```
ps aux | grep tomcat
```
- didn't start
- found logs
```
less /opt/apache/tomcat/7.0.62/bin/catalina.sh | grep catalina.out
```
*catalina.out*
>/opt/apache/tomcat/7.0.62/bin/catalina.sh: /usr/bin/java: /lib/ld-linux.so.2: bad ELF interpreter: No such file or directory
- bad java version
```
arch
```
- checked architecture
```
alternatives --config java
```
- checked all intalled java picked one for x64
```
service tomcat start 
ps aux | grep tomcat
```
- tomcat started
```
curl -IL 192.168.56.10
```
>HTTP/1.1 200 OK

- tomcat was working fine
###4. Checked error redirections
```
curl -sL -w "%{http_code}" 192.168.56.10/123
```
- didn't work
- added use_server_errors to support error redirections
```
sed -i 's/JkMount \/\* tomcat.worker/JkMount \/\* tomcat.worker;use_server_errors=404,500,503,504/' /etc/httpd/conf.d/vhost.conf
service httpd restart
curl -sL -w "%{http_code}" 192.168.56.10/123
```
- redirection worked
###5. Checked iptables
```
iptables -L -n
```
- service didn't work
```
service iptables start
```
- service didn't start
```
less /etc/sysconfig/iptables 
```
- found errors, 80 port not included, no ESTABLISHED entry
- tried to modify
- permission was denied
```
lsattr /etc/sysconfig/iptables 
```
- found "i" attribute
```
chattr -i /etc/sysconfig/iptables 
```
- removed attribute
- modified iptables file successfully
```
sed -i '/22 -j ACCEPT/a -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT' /etc/sysconfig/iptables
sed -i 's/RELATED/RELATED,ESTABLISHED/' /etc/sysconfig/iptables
service iptables start
```
- success
###6. Added httpd and tomcat to autostart
```
chkconfig httpd on
chkconfig tomcat on
```
