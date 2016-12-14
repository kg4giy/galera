127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.31.10 node1 node1.localdomain
192.168.32.10 node2 node2.localdomain
192.168.33.10 node3 node3.localdomain
192.168.31.15 puppetserver puppetserver.localdomain
192.168.31.20 node4 node4.localdomain
192.168.31.25 node5 node5.localdomain



yum install -y https://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm


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

  config.vm.define :puppet do |puppet|
    puppet.vm.box = "bento/centos-6.7"
    puppet.vm.network :private_network, ip: "192.168.31.15"
    puppet.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
    end  
  end


  config.vm.define :node4 do |node4|
    node4.vm.box = "bento/centos-6.7"
    node4.vm.network :private_network, ip: "192.168.31.20"
  end

  config.vm.define :node5 do |node5|
    node5.vm.box = "bento/centos-6.7"
    node5.vm.network :private_network, ip: "192.168.31.25"
  end