# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "wheezy"
  config.vm.box_url = "https://labs.enovance.com/pub/wheezy.box"
  
  config.vm.customize ["modifyvm", :id, "--nictype1", "virtio"]

  (0..2).each do |i|
    config.vm.define "mon#{i}" do |mon|
      mon.vm.host_name = "ceph-mon#{i}.test"
      mon.vm.network :hostonly, "192.168.251.1#{i}", { :nic_type => 'virtio' }
      mon.vm.provision :shell, :path => "examples/mon.sh"
    end
  end

  (0..2).each do |i|
    config.vm.define "osd#{i}" do |osd|
      osd.vm.host_name = "osd#{i}.test"
      osd.vm.network :hostonly, "192.168.251.10#{i}", { :nic_type => 'virtio' }
      osd.vm.provision :shell, :path => "examples/osd.sh"
    end
  end

end
