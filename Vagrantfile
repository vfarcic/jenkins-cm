# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.synced_folder ".", "/vagrant"
  if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    config.vm.synced_folder ".", "/vagrant", mount_options: ["dmode=700,fmode=600"]
  else
    config.vm.synced_folder ".", "/vagrant"
  end
  config.vm.define "ha-centos" do |d|
    d.vm.box = "aviture/centos7"
    d.vm.hostname = "ha-centos"
    d.vm.network "private_network", ip: "10.100.199.200"
    d.vm.provider "virtualbox" do |v|
      v.memory = 1024
    end
  end
  (1..2).each do |i|
    config.vm.define "cjoc-centos-#{i}" do |d|
      d.vm.box = "aviture/centos7"
      d.vm.hostname = "cjoc-centos-#{i}"
      d.vm.network "private_network", ip: "10.100.199.20#{i}"
      d.vm.provider "virtualbox" do |v|
        v.memory = 1024
      end
    end
  end
  (1..2).each do |i|
    config.vm.define "cje-centos-#{i}" do |d|
      d.vm.box = "aviture/centos7"
      d.vm.hostname = "cje-centos-#{i}"
      d.vm.network "private_network", ip: "10.100.198.20#{i}"
      d.vm.provider "virtualbox" do |v|
        v.memory = 1024
      end
    end
  end
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
end