# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "wheezy"
  config.vm.box_url = "https://labs.enovance.com/pub/wheezy.box"

  config.vm.define :mon0 do |mon0|
    mon0.vm.host_name = "ceph-mon0.test"
    mon0.vm.network :hostonly, "192.168.251.10"
    mon0.vm.provision :shell, :path => "mon.sh"
  end

  config.vm.define :mon1 do |mon1|
  mon1.vm.host_name = "ceph-mon1.test"
    mon1.vm.network :hostonly, "192.168.251.11"
    mon1.vm.provision :shell, :path => "mon.sh"
  end

  config.vm.define :mon2 do |mon2|
    mon2.vm.host_name = "ceph-mon2.test"
    mon2.vm.network :hostonly, "192.168.251.12"
    mon2.vm.provision :shell, :path => "mon.sh"
  end

  config.vm.define :osd0 do |osd0|
    osd0.vm.host_name = "osd0.test"
    osd0.vm.network :hostonly, "192.168.251.100"
    osd0.vm.provision :shell, :path => "osd.sh"
  end

  config.vm.define :osd1 do |osd1|
    osd1.vm.host_name = "osd1.test"
    osd1.vm.network :hostonly, "192.168.251.101"
    osd1.vm.provision :shell, :path => "osd.sh"
  end

  config.vm.define :osd2 do |osd2|
    osd2.vm.host_name = "osd2.test"
    osd2.vm.network :hostonly, "192.168.251.102"
    osd2.vm.provision :shell, :path => "osd.sh"
  end

end


