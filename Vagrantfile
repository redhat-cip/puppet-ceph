# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "wheezy"
  config.vm.box_url = "https://labs.enovance.com/pub/wheezy.box"
  
  config.vm.customize ["modifyvm", :id, "--nictype1", "virtio"]
  config.vm.customize ["modifyvm", :id, "--macaddress1", "auto"]

  (0..2).each do |i|
    config.vm.define "mon#{i}" do |mon|
      mon.vm.host_name = "ceph-mon#{i}.test"
      mon.vm.network :hostonly, "192.168.251.1#{i}", { :nic_type => 'virtio' }
      mon.vm.network :hostonly, "192.168.252.1#{i}", { :nic_type => 'virtio' }
      mon.vm.provision :shell, :path => "examples/mon.sh"
    end
  end

  (0..2).each do |i|
    config.vm.define "osd#{i}" do |osd|
      osd.vm.host_name = "ceph-osd#{i}.test"
      osd.vm.network :hostonly, "192.168.251.10#{i}", { :nic_type => 'virtio' }
      osd.vm.network :hostonly, "192.168.252.10#{i}", { :nic_type => 'virtio' }
      osd.vm.provision :shell, :path => "examples/osd.sh"
      (0..1).each do |d|
        osd.vm.customize [ "createhd", "--filename", "disk-#{i}-#{d}", "--size", "5000" ]
        osd.vm.customize [ "storageattach", :id, "--storagectl", "SATA Controller", "--port", 3+d, "--device", 0, "--type", "hdd", "--medium", "disk-#{i}-#{d}.vdi" ]
      end
    end
  end

  (0..1).each do |i|
    config.vm.define "mds#{i}" do |mds|
      mds.vm.host_name = "ceph-mds#{i}.test"
      mds.vm.network :hostonly, "192.168.251.15#{i}", { :nic_type => 'virtio' }
      mds.vm.provision :shell, :path => "examples/mds.sh"
    end
  end
end
