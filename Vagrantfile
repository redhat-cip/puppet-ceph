# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "wheezy64"
  config.vm.box_url = "http://os.enocloud.com:8080/v1/AUTH_fc47c4103c9b4aaf9271c581776a268f/public/wheezy64.box"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
    vb.customize ["modifyvm", :id, "--nictype3", "virtio"]
  end

  (0..2).each do |i|
    config.vm.define "mon#{i}" do |mon|
      mon.vm.hostname = "ceph-mon#{i}.test"
      mon.vm.network :private_network, ip: "192.168.251.1#{i}"
      mon.vm.network :private_network, ip: "192.168.252.1#{i}"
      mon.vm.provision :shell, :path => "examples/mon.sh"
    end
  end

  (0..2).each do |i|
    config.vm.define "osd#{i}" do |osd|
      osd.vm.hostname = "ceph-osd#{i}.test"
      osd.vm.network :private_network, ip: "192.168.251.10#{i}"
      osd.vm.network :private_network, ip: "192.168.252.10#{i}"
      osd.vm.provision :shell, :path => "examples/osd.sh"
      (0..1).each do |d|
        osd.vm.provider :virtualbox do |vb|
          vb.customize [ "createhd", "--filename", "disk-#{i}-#{d}", "--size", "5000" ]
          vb.customize [ "storageattach", :id, "--storagectl", "SATA Controller", "--port", 3+d, "--device", 0, "--type", "hdd", "--medium", "disk-#{i}-#{d}.vdi" ]
        end
      end
    end
  end

  (0..1).each do |i|
    config.vm.define "mds#{i}" do |mds|
      mds.vm.hostname = "ceph-mds#{i}.test"
      mds.vm.network :private_network, ip: "192.168.251.15#{i}"
      mds.vm.provision :shell, :path => "examples/mds.sh"
    end
  end
end
