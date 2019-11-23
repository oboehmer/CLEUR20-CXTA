# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  config.vm.define "r1" do |r1|
    r1.vm.box = "iosxe/16.09.01"

    # IOS XE 16.7+ requires virtio for the network adapters.
    r1.vm.network :private_network, virtualbox__intnet: "link1", auto_config: false, nic_type: "virtio"
    r1.vm.network :private_network, virtualbox__intnet: "link2", auto_config: false, nic_type: "virtio"
    # box already forwards 22 to 2222 (as well as 2223->830, 2224->80 and a few more)
    # we generate testbed.yaml dynamically through ./start-routers.sh
  end
  config.vm.define "r2" do |r2|
    r2.vm.box = "iosxe/16.09.01"
    r2.vm.network :private_network, virtualbox__intnet: "link1", auto_config: false, nic_type: "virtio"
    r2.vm.network :private_network, virtualbox__intnet: "link2", auto_config: false, nic_type: "virtio"
    # box already forwards 22 to 2222 (as well as 2223->830, 2224->80 and a few more)
    # we generate testbed.yaml dynamically through ./start-routers.sh
  end
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  config.vm.provider "virtualbox" do |vb|
     vb.memory = "3056"
     vb.customize ["modifyvm", :id, "--vram", "12"]
  end
end
