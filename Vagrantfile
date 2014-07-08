# Oracle Identity and Access Management
# CentOS 6.5 amd64
# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
app_name                = "iam2.dev.vm"
app_name_short          = "iam2"
app_ip                  = "192.168.168.41"
app_box                 = "centos6-fusion"
app_box_url             = "https://agoracon.at/boxes/centos6-fusion.box"

hostfile = "
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
#{app_ip} #{app_name} #{app_name_short}
"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define :app, primary: true do |app|
    app.vm.box      = app_box
    app.vm.hostname = app_name
    app.vm.box_url  = app_box_url

    app.vm.network :private_network, ip: app_ip

    app.vm.synced_folder "/Users/horst/Downloads/Software/oracle.com", "/mnt/orainst", nfs: true

    app.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id,
                    # "--memory", "10240",
                    "--memory", "12288",
                    "--name", app_name,
                    "--cpus", "4"]
    end
    app.vm.provision :shell, :inline => "echo provisioning /etc/hosts"
    app.vm.provision :shell, :inline => "echo '#{hostfile}' > /etc/hosts" 
  end

end

