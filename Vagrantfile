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
      osd.vm.host_name = "ceph-osd#{i}.test"
      osd.vm.network :hostonly, "192.168.251.10#{i}", { :nic_type => 'virtio' }
      osd.vm.provision :shell, :path => "examples/osd.sh"
      (0..1).each do |d|
        osd.vm.customize [ "createhd", "--filename", "disk-"+:id.to_s+"-#{d}", "--size", "5000" ]
        osd.vm.customize [ "storageattach", :id, "--storagectl", "SATA Controller", "--port", 3+d, "--device", 0, "--type", "hdd", "--medium", "disk-"+:id.to_s+"-#{d}.vdi" ]
      end
    end
  end

  config.vm.define "disk" do |vm|
    vm.vm.host_name = "vm.test"
    vm.vm.provision :puppet, :manifest_file => "disk.pp"
    (0..1).each do |d|
      vm.vm.customize [ "createhd", "--filename", "disk-"+:id.to_s+"-#{d}", "--size", "5000" ]
      vm.vm.customize [ "storageattach", :id, "--storagectl", "SATA Controller", "--port", 3+d, "--device", 0, "--type", "hdd", "--medium", "disk-"+:id.to_s+"-#{d}.vdi" ]
    end
  end

end
