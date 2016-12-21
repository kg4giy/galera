# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  # config.vm.provision "puppet" do |puppet|
  # end
  
  config.vm.define :node1 do |node1|
    node1.vm.box = "bento/centos-6.7"
    node1.vm.network :private_network, ip: "192.168.31.10"
  end
  
  config.vm.define :node2 do |node2|
    node2.vm.box = "bento/centos-6.7"
    node2.vm.network :private_network, ip: "192.168.32.10"
  end
  
  config.vm.define :node3 do |node3|
    node3.vm.box = "bento/centos-6.7"
    node3.vm.network :private_network, ip: "192.168.33.10"
  end

  config.vm.define :node4 do |node4|
    node4.vm.box = "bento/centos-6.7"
    node4.vm.network :private_network, ip: "192.168.31.20"
  end

  config.vm.define :node5 do |node5|
    node5.vm.box = "bento/centos-6.7"
    node5.vm.network :private_network, ip: "192.168.31.25"
  end

  config.vm.define :node6 do |node6|
    node6.vm.box = "bento/centos-6.7"
    node6.vm.network :private_network, ip: "192.168.32.20"
  end

  config.vm.define :chef do |chef|
    chef.vm.box = "bento/centos-6.7"
    chef.vm.network :private_network, ip: "192.168.32.25"
  end

  config.vm.define :puppet do |puppet|
    puppet.vm.box = "bento/centos-6.7"
    puppet.vm.network :private_network, ip: "192.168.31.15"
    puppet.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
    end  
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # config.vm.network "forwarded_port", guest: 4444, host: 14444, protocol: "tcp"
  # config.vm.network "forwarded_port", guest: 4567, host: 14567, protocol: "tcp"
  # config.vm.network "forwarded_port", guest: 4567, host: 14567, protocol: "udp"
  # config.vm.network "forwarded_port", guest: 4568, host: 14568, protocol: "tcp"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "private_network", ip: "192.168.31.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
