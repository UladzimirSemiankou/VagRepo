# Vagrant Semenkov V.V.

######1. Install Virtualbox and Vagrant
```
wget https://releases.hashicorp.com/vagrant/1.8.4/vagrant_1.8.4_x86_64.rpm
yum install vagrant_1.8.4_x86_64.rpm
vagrant plugin install vagrant-vbguest
wget http://download.virtualbox.org/virtualbox/5.0.24/VirtualBox-5.0-5.0.24_108355_el6-1.x86_64.rpm
yum install VirtualBox-5.0-5.0.24_108355_el6-1.x86_64.rpm
```
![screenshot-root epbyminw2629 -home-student-vagrant-mntlab](https://github.com/UladzimirSemiankou/VagRepo/blob/VagTrouble/vagrant/sources/Screenshot-root@epbyminw2629:-home-Student-vagrant-mntlab.png?raw=true)
![screenshot-root epbyminw2629 -home-student-vagrant-mntlab-1](https://github.com/UladzimirSemiankou/VagRepo/blob/VagTrouble/vagrant/sources/Screenshot-root@epbyminw2629:-home-Student-vagrant-mntlab-1.png?raw=true)

######2. Initialize new Vagrant project
```
vagrant init sbeliakou-vagrant-centos-6.7-x86_64.box
```
![screenshot-root epbyminw2629 -home-student-vagrant-mntlab-2](https://github.com/UladzimirSemiankou/VagRepo/blob/VagTrouble/vagrant/sources/Screenshot-root@epbyminw2629:-home-Student-vagrant-mntlab-2.png?raw=true)

######3. Update configuration to use specific vagrant box (sbeliakou/centos-6.7-x86_64)
```
config.vm.box = "sbeliakou-vagrant-centos-6.7-x86_64.box"
```

######4. Configure multiple VM’s in single Vagrantfile (2 VM’s):
- VM1: httpd, mod_jk installed, configured as web frontend for VM2
- VM2: tomcat 8 (and all needed dependencies) installed

######Customize VMs’ settings:
- VM1: 512 MB RAM, 1 CPU
- VM2: 1 GB RAM, CPU execution cap 35%

######Mount host directories into VMs, specify ownerships

######Define shell provisioners:
- default provisioner (performs on both VMs)
- web.sh script installs and configures httpd and mod_jk (VM1)
- app.sh script installs and configures tomcat and its dependencies (VM2)

**Vagrantfile**
```
Vagrant.configure("2") do |config|
  config.vm.box = "sbeliakou-vagrant-centos-6.7-x86_64.box"
  config.vm.synced_folder "sources", "/sources",
   owner: "vagrant", group: "vagrant",
   create: true
  config.vm.provision "shell", inline: "yum install vim -y"

 config.vm.define "vm1" do |vm1|
  vm1.vm.hostname = "frontend"
  vm1.vm.network "private_network", ip: "192.168.1.11"
  vm1.vm.provider "virtualbox" do |machine|
   machine.name = "VM1-frontend"
  end
  vm1.vm.provision "shell", inline: "echo This is VM1-frontend"
  vm1.vm.provider "virtualbox" do |v1|
   v1.cpus = 1
   v1.memory = 512
  end
  vm1.vm.provision "shell", path: "./web.sh"
 end

 config.vm.define "vm2" do |vm2|
  vm2.vm.hostname = "backend"
  vm2.vm.network "private_network", ip: "192.168.1.12"
  vm2.vm.provider "virtualbox" do |machine|
   machine.name = "VM2-backend"
  end
  vm2.vm.provision "shell", inline: "echo This is VM2-backend"
  vm2.vm.provider "virtualbox" do |v2|
   v2.customize ["modifyvm", :id, "--cpuexecutioncap", "35"]
   v2.memory = 1024
  end
  vm2.vm.provision "shell", path: "./app.sh"
 end

end
```
**web.sh**
```
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
```
**app.sh**
```
#!/bin/bash
yum install java -y
wget http://archive.apache.org/dist/tomcat/tomcat-8/v8.5.3/bin/apache-tomcat-8.5.3.tar.gz
tar -xvzf apache-tomcat-8.5.3.tar.gz
cp -f /sources/tomcat-users.xml apache-tomcat-8.5.3/conf/
cp -f /sources/server.xml apache-tomcat-8.5.3/conf/
apache-tomcat-8.5.3/bin/startup.sh
```
![screenshot-root epbyminw2629 -home-student-vagrant-mntlab-4](https://github.com/UladzimirSemiankou/VagRepo/blob/VagTrouble/vagrant/sources/Screenshot-root@epbyminw2629:-home-Student-vagrant-mntlab-4.png?raw=true)
![screenshot-apache tomcat-8 5 3 - mozilla firefox private browsing](https://github.com/UladzimirSemiankou/VagRepo/blob/VagTrouble/vagrant/sources/Screenshot-Apache%20Tomcat-8.5.3%20-%20Mozilla%20Firefox%20(Private%20Browsing).png?raw=true)

