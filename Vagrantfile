#  Oracle Identity and Access Management
#  vi: set ft=ruby :

# app.vm.box_url = "https://agoracon.at/boxes/centos6min.box"
# app.vm.box_download_checksum = "bce6a99728ceaeb017f475ee734f676390cf8c49b6aed721a3247c204daa507f"
# app.vm.box_download_checksum_type = "sha256"

VAGRANTFILE_API_VERSION = "2"

$hostfile = "# hostfile generated by vagrant provisioning
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.168.20          oradb.vie.agoracon.at            oradb
192.168.168.32           web1.vie.agoracon.at             web1
192.168.168.33           web2.vie.agoracon.at             web2
192.168.168.34           oam1.vie.agoracon.at             oam1
192.168.168.35           oam2.vie.agoracon.at             oam2
192.168.168.36           oim1.vie.agoracon.at             oim1
192.168.168.37           oim2.vie.agoracon.at             oim2
192.168.168.38           oud1.vie.agoracon.at             oud1
192.168.168.39           oud2.vie.agoracon.at             oud2
192.168.168.32    oiminternal.vie.agoracon.at      oiminternal
192.168.168.32       idmadmin.vie.agoracon.at         idmadmin
192.168.168.32       oimadmin.vie.agoracon.at         oimadmin
192.168.168.32       diradmin.vie.agoracon.at         diradmin
192.168.168.32            sso.vie.agoracon.at              sso
192.168.168.38           ldap.vie.agoracon.at             ldap
192.168.1.16              nyx.vie.agoracon.at              nyx
"
 
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # ----------------------------------------------------- directory server
  config.vm.define :oud1 do |m|
    m.vm.box      = "centos6min"
    m.vm.hostname = "oud1"
    m.vm.network  :private_network, ip: "192.168.168.38"
    m.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "3072",
                    "--name", "oud1", "--cpus", "2"]
    end
    m.vm.provision :shell, inline: "echo '#{$hostfile}' > /etc/hosts" 
    m.vm.provision :shell, inline: "bash /vagrant/lib/vagrant-prov.sh"
  end
  config.vm.define :oud2 do |m|
    m.vm.box      = "centos6min"
    m.vm.hostname = "oud2"
    m.vm.network  :private_network, ip: "192.168.168.39"
    m.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "3072",
                    "--name", "oud2", "--cpus", "2"]
    end
    m.vm.provision :shell, inline: "echo '#{$hostfile}' > /etc/hosts" 
    m.vm.provision :shell, inline: "bash /vagrant/lib/vagrant-prov.sh"
  end
  # ----------------------------------------------------- access server
  config.vm.define :oam1 do |m|
    m.vm.box      = "centos6min"
    m.vm.hostname = "oam1"
    m.vm.network  :private_network, ip: "192.168.168.34"
    m.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "6144",
                    "--name", "oam1", "--cpus", "4"]
    end
    m.vm.provision :shell, inline: "echo '#{$hostfile}' > /etc/hosts" 
    m.vm.provision :shell, inline: "bash /vagrant/lib/vagrant-prov.sh"
  end
  config.vm.define :oam2 do |m|
    m.vm.box      = "centos6min"
    m.vm.hostname = "oam2"
    m.vm.network  :private_network, ip: "192.168.168.35"
    m.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "6144",
                    "--name", "oam2", "--cpus", "4"]
    end
    m.vm.provision :shell, inline: "echo '#{$hostfile}' > /etc/hosts" 
    m.vm.provision :shell, inline: "bash /vagrant/lib/vagrant-prov.sh"
  end

  # ----------------------------------------------------- identity server
  config.vm.define :oim1 do |m|
    m.vm.box      = "centos6min"
    #m.vm.hostname = "oim1"
    m.vm.network  :private_network, ip: "192.168.168.36"
    m.vm.network  :forwarded_port,  guest:  7101, host:  7101
    m.vm.network  :forwarded_port,  guest: 14000, host: 14000
    m.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "6144", "--cpus", "4"]
    end
    m.vm.provision :shell, inline: "echo '#{$hostfile}' > /etc/hosts" 
    m.vm.provision :shell, inline: "bash /vagrant/lib/vagrant-prov.sh"
  end
  config.vm.define :oim2 do |m|
    m.vm.box      = "centos6min"
    #m.vm.hostname = "oim2"
    m.vm.network  :private_network, ip: "192.168.168.37"
    m.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "6144", "--cpus", "4"]
    end
    m.vm.provision :shell, inline: "echo '#{$hostfile}' > /etc/hosts" 
    m.vm.provision :shell, inline: "bash /vagrant/lib/vagrant-prov.sh"
  end

  # ----------------------------------------------------- web server
  config.vm.define :web1 do |m|
    m.vm.box      = "centos6min"
    m.vm.hostname = "web1"
    m.vm.network  :private_network, ip: "192.168.168.32"
    m.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "3072", 
                    "--name", "web1", "--cpus", "2"]
    end
    m.vm.provision :shell, inline: "echo '#{$hostfile}' > /etc/hosts" 
    m.vm.provision :shell, inline: "bash /vagrant/lib/vagrant-prov.sh"
  end
  config.vm.define :web2 do |m|
    ip = "192.168.168.33"
    m.vm.box      = "centos6min"
    m.vm.hostname = "web2"
    m.vm.network  :private_network, ip: ip
    m.vm.network  :forwarded_port,  guest: 4443, host: 4443
    m.vm.network  :forwarded_port,  guest: 7777, host: 7777
    m.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "3072",
                    "--name", "web2", "--cpus", "2"]
    end
    m.vm.provision :shell, inline: "echo '#{$hostfile}' > /etc/hosts" 
    m.vm.provision :shell, inline: "bash /vagrant/lib/vagrant-prov.sh"
  end

end
