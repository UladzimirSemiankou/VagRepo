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
