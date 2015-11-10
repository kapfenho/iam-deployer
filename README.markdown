```
  _                      __      _            _                       
 (_) __ _ _ __ ___      / /   __| | ___ _ __ | | ___  _   _  ___ _ __ 
 | |/ _` | '_ ` _ \    / /   / _` |/ _ \ '_ \| |/ _ \| | | |/ _ \ '__|
 | | (_| | | | | | |  / /_  | (_| |  __/ |_) | | (_) | |_| |  __/ |   
 |_|\__,_|_| |_| |_| /_/(_)  \__,_|\___| .__/|_|\___/ \__, |\___|_|   
                                       |_|            |___/           
```
### Identity and Access Management Deployer

Automagical deployments of Oracle Identity and Access Management. Don't
spend your lifetime on installations that take longer that your annual
vacation!

### Software Required

* [Vagrant](http://www.vagrantup.com) 
* A Virtualization Provider like
[VirtualBox](https://www.virtualbox.org),
[VMWare](https://www.vmware.com) or [Docker](https://www.docker.io)

Docker may be an option for the application services, but not for the
Oracle database. The project uses Vagrant for VM management, the
provisioning implementation is done with bash scrips. The bash scripts
configure and execute Oracle's LCM that does the native software
installation.


### Provisioned Software

* Oracle Enterprise Database 11.2.0.4
* Oracle Identity and Access Management 11.1.2.2
* Oracle Identity Analytics 11.1.1.5

_It is required to use a POSIX compliant environment for using the
project - including Vagrant. As script environment the project is using
bash(8). It may be possible to run the provisioning on Microsoft Windows 
by installing 3rd party tools. However we recommend to use Unix/BSD or Linux._

## Multipe Scenarios

The project can be used for different scenarious:

* create new VM (single host setup) from scratch
* create new VMs (cluster setup) in virtual network from scratch
* deploy environment on one pre-existing host (single host)
* deploy environment on multiple pre-existing hosts (cluster setup)

When you deploy on pre-exsiting hosts, you need the necessary network
connectivity already set up. This includes setting up firewall rules 
and configuration of load balancers.

In any case a multi-host setup uses one controller machine for executing
the tasks on the remote machines. In the first two approaches this is 
the virtualization host using Vagrant, in the other ones this may be one
of the existing hosts using ssh connections to the other members.

## Deployment: main blocks

The deployment consists of the following steps:

1. Virtual Machine(s) Creation (optional)
2. OS configuration and package installation
3. Installation of Oracle Enterprise Database
4. IAM deployment with Oracle's Lifecycle Manager (LCM)
5. Oracle Analytics deployment
5. IAM post installation tasks

To get a new environment provisioned you need to describe how
it shall look like - what are the host names, ip addresses, domain
names, etc.

## Configuration Set: One Environment

One configuration set describes one environment. It consists of several
directories and files, that must not be renamed or deleted. 

You can create a new configuration set with the command
(see below how to set the environment for command execution):

    iam create -t {single|cluster}

It may be a good idea to add the new config to the version control
system. You can keep multiple environments in the project. The project
expects the current configuration set in the subdirectory `user-config`.
This directory is excluded from _git_ (`.gitignore`). Put all your
instances in one containing directory (`instances`) and symlink your
current one to `user-config`:

    ln -s instances/my_instance user-config

All config files available:

```
my-instance
├── worklist.sh                 <- provisioning commands
├── database.config             <- database server
├── iam.config                  <- addition setup config
├── dbs
│   ├── db_create.rsp           <- database instance
│   ├── db_install.rsp          <- database software install
│   └── db_netca.rsp            <- database network
├── env
│   ├── root-check.sh           <- verify OS config
│   └── root-script.sh          <- configure OS
├── iam
│   ├── provisioning.rsp        <- iam configuration
│   ├── psa_access.rsp          <- patch set assistant oam (PS2)
│   └── psa_identity.rsp        <- patch set assistant oim (PS2)
├── lcm
|   └── lcm_install.rsp         <- LCM installation config
├── vagrant
│   └── Vagrantfile             <- VM config
├── oia
│   ├── create-schema.sql       <- OIA database: user and tablespace
│   ├── remove-schema.sql       <- OIA database: remove user and tbs
│   ├── createdom-single.prop   <- OIA single instance: domain config
│   ├── createdom-cluster.prop  <- OIA cluster: domain config
│   ├── rbacx_single.patch      <- OIA single instance: config as patch
│   ├── rbacx_cluster.patch     <- OIA cluster: config as patch
│   ├── rbacx_workflow.patch    <- OIA workflow: config as patch
│   └── psa_identity.rsp        <- patch set assistant oim (PS2)
```

## Vagrant

Skip this step if you provision on already existing VM or bare metal.

For detailed configuration of virtual machines and the syntax used
please see the [Vagrant documentation](https://vagrantup.com)

### VLAN Configuration

You need to prepare the network config in you virtualization software.
In VirtualBox you can condifure this in the application configuration
(not in the VM configuration). The Vagrantfile shipped use the network

    192.168.168.0/24

with static IP addresses - no DHCP necessary. The base box has this link
enabled on host adapter 1. In Vagrant each machine automatically gets a
DHCP config enabled on the first network adapter. The default route uses
that adapter. Not all Oracle products run on IPv6. A mixed use of IPv4
and IPv6 is only possible for parts of the environment. For reducing the
complexity IPv6 has been disabled completely.


You start the provisioning process with `vagrant up`. After the creation
of the machines the provisioning steps will be executed. A ping-check
helps making sure the application provisioning will be postponed until
all servers are up and running.

Info: Vagrant mounts the project directory on each machine at `/vagrant`
with permissions `vagrant:vagrant`.

A necessary hardware load balancer is substituted by a simple port
forwarding in the OS kernel of the first web server:

    http:  tcp/80  -> tcp/7777
    https: tcp/443 -> tcp/4443

## Manual Approach: Provisioning on existing hosts

Read carefully if you plan to provision on existing hosts. The topics
here are also valid when using Vagrant, but using existing hosts
replaces the properly prepared base box with an host that for sure has a
different configuration.

### Operating System Configuration and Installation Requirements

This project supports RedHat 6 and 7. In case you use related systems
(the base box is a CentOS 6) take care of the `/etc/redhat-release`).

Using Vagrant and the base box guarentee we fullfil the pre-requistes
for privisioning and using IAM. When you are using existing hosts you
need to make sure your hosts fullfil those requirements as well.

The OS configuration is done by executing the script

    user-config/env/root-script.sh

You may get a report of missing configs by running

    user-config/env/root-check.sh

Keep in mind the report may not be complete. Please check the Oracle
documentation for the installation requirements.

_Make sure `root-scripts.sh` has been run without errors on each host._

Before you do any provisioning on an existing host: verify the
configuration of the operating system and make sure no application or
files are in the way of the provisioning ($iam_top) or using the ports 
you plan to use.

You can start the provisioning on one of the existing application hosts,
it is not important which one. You can execute all steps from a remote
machine by using the option `-H hostname` on each provisioning step.

_However, it is necessary to have the project files available on all
hosts on the same path._ If you copy the files on the other machines,
don't forget to repeat this after a configuration change. A better
approach is using a network filesystem.

### Access between hosts

_Automatically done when using Vagrant_

We need to enable trusted ssh connections between the hosts, without
entering credentials. This is done by creating ssh-keys and adding
foreign ssh-keys into the `authorized_keys` file. See `ssh(8)` for more
information.

### Provisioning Environment

_Automatically done when using Vagrant_

There is one requiered environment variable for provisionings: the path
of the project directory on the application host. You can add this
variable to the profile.

    export DEPLOYER=/vagrant

### Provisioning

_Automatically done when using Vagrant_

Provisioning is executed with the command

    iam provision

This will run the `worklist.sh` script file where all provision steps of
the enviroment are listed. You can rerun the script in case of an error.
However, if the process fails within one of the LCM steps, you need to
start from scratch, after removing the already installed files.

### Removing IAM

You can remove a complete or partly installed installation by the
command

    iam remove -t all

### Creating and Removing Database Schema

Creating the schema is part of the worklist execution. If you need to
execute it manually use

    iam rcu -a {create|remove} -t {identity|access|bip}




* [Vagrant](http://www.vagrantup.com) 
* A Virtualization Provider, e.g.
[VirtualBox](https://www.virtualbox.org), [VMWare](https://www.vmware.com)
  [Docker](https://www.docker.io) support is in development and not supported yet

After checking the pre-requisites and editing you destination description
you can create the environment with:

```
    $ vagrant up
```

Start using your env:

* Identity Manager: `http://machine:7777/identity`

Remove the environment with:

```
    $ vagrant destroy
```


## Multi Server Deployment

The producion setup can be started on bare metal servers or virtual
servers. Necessary OS packages will be added during the installation.

The definition of your topology will be specified in
`user-config/iam/provisioning.rsp`. You can do this by hand or create a
new one with the _Oracle Life Cycle Management Wizard_.



## Detailed Description

This procedure simplifies the deployment of Oracle Identity and Access
Management. However, a knowledge of the Oracle software and the original
documentation is essential for using and installing the components! 

**This README is not a subsitiute for the Oracle installation guides!**

__Read those guides before and then continue.__

### Download Software

Download the software packages from
[edelivery.oracle.com](https://edelivery.oracle.com/), see at the end
of this file for a complete list with checksums.


### Create Installation Image Directory

You will need the following software packages from Oracle:

Extract the installation images in a directory on your local machine (when
deploying to VM on your local machine) or on a network server. This
directory will be mounted on the new servers via NFS. There is no need
to copy the files onto the new virtual machines, the installer can read
them from any mounted location.

The structure with the extracted images shall look like this:

```
    ├── iam-11.1.2.2                <- the application packages
    │   ├── repo
    │   │   └── installers
    │   │       ├── appdev
    │   │       ├── fmw_rcu
    │   │       ├── iamsuite
    │   │       ├── idmlcm
    │   │       ├── jdk
    │   │       ├── oud
    │   │       ├── smart_update
    │   │       ├── soa
    │   │       ├── webgate
    │   │       ├── weblogic
    │   │       └── webtier
    ├── database-ee-11.2.0.4        <- the databaes packages
    │   └── p13390677_112040_Linux-x86-64
    │       ├── client
    │       ├── database
    │       ├── deinstall
    │       ├── examples
    │       ├── gateways
    │       └── grid
    ├── patches                     <- common location for software patches
    │   │   ├── ...
```

### Patch the installation images

The installation images need patching to be installed properly.
Download from [Oracle Support](https://support.oracl.com) the following
patch and apply it to the downloaded repository:

```
# fix for wrong 32bit specs: i386 -> i686
patch 18231786
```

You can apply this patch to all products: exchange the old `refhost.xml`
with the new version:

```
./appdev/Disk1/stage/prereq/linux64/refhost.xml
./iamsuite/Disk1/stage/prereq/linux64/refhost.xml
./idmlcm/Disk1/stage/prereq/linux64/refhost.xml
./oud/Disk1/stage/prereq/linux64/refhost.xml
./soa/Disk1/stage/prereq/linux64/refhost.xml
./webgate/Disk1/stage/prereq/linux64/refhost.xml
./webtier/Disk1/stage/prereq/linux64/refhost.xml
```

### Create your config files

Create your own copy of the config files with the included help-script:

```
./createconf.sh
```

Adapt the configuration files according to your needs in:

```
    Vagrantfile                         <- machine configs
    ├── user-config
    |   ├── database.config             <- database server
    |   ├── dbs
    |   │   ├── db_create.rsp           <- database server
    |   │   ├── db_install.rsp          <- database server
    |   │   └── db_netca.rsp            <- database server
    |   ├── iam
    |   │   ├── provisioning.rsp        <- other servers
    |   │   ├── provisioning_data
    |   │   │   └── cwallet.sso         <- other servers
    |   │   ├── psa_access.rsp          <- other servers
    |   │   └── psa_identity.rsp        <- other servers
    |   ├── iam.config                  <- other servers
    |   └── lcm
            └── lcm_install.rsp         <- other servers
```

See below for using configuration management.

There is an additional script you can use for changing values that are
spread over multiple config files: `changeconf.sh`. Calling this script 
with one paramter will search that value in all your config files, a
second parameter is used for changing those occurences. Changing the 
hostname is simple using the script:

    # check occurences
    ./changeconf.sh iam2.agoracon.at

    # check result, then change with:
    ./changeconf.sh iam2.agoracon.at iam3.example.com
    
Changing the installation path:

    ./changeconf.sh /appl/iam /usr/iam


### Start Installation


The virtual machine is created with `vagrant up`, configuration and
trigger points for software installation is inside Vagrantfile.

System configuration: the script "sys.sh" produces a script that needs
to be executed as root. This root-script will also create the
application users and groups.

The application installation scripts can then be run as the appropriate
application user.

If you want to execute those scripts on your own, just remove the call
in Vagrantfile.



## Configuration Management

It is crucial to save your configurations for deploying and staging in later
phases.

The \*.rsp files are standard Oracle response files, used typically in server
installations. Whatever you configure you should keep your configuration and
add it to your configuration management. With Git you would now branch the
project and add those files (beside the shipped example files that you've used
as templates), eg. with:

```
    $ git checkout -b mydevboxbranch
    $ git add .
    $ git commit -m "initial version of mydevbox config"
```
You can add your own git server with

```
    $ git remote add mygit ssh://git@git.srv.priv/myrepo.git
    $ git push mygit mydevboxbranch
```



## Software Packages to Download 

You can verify the checksums online at:

```
https://edelivery.oracle.com/EPD/ViewDigest/get_form?epack_part_number=B77727&export_to_csv=1
```

```
Enterprise Database 11.2.0.4 p13390677
--------------------------------------

Download from Oracle eDelivery:
  https://support.oracle.com

0b399a6593804c04b4bd65f61e73575341a49f8a273acaba0dcda2dfec4979e0  p13390677_112040_Linux-x86-64_1of7.zip
73e04957ee0bf6f3b3e6cfcf659bdf647800fe52a377fb8521ba7e3105ccc8dd  p13390677_112040_Linux-x86-64_2of7.zip
09c08ad3e1ee03db1707f01c6221c7e3e75ec295316d0046cc5d82a65c7b928c  p13390677_112040_Linux-x86-64_3of7.zip
88b4a4abb57f7e94941fe21fa99f8481868badf2e1e0749522bba53450f880c2  p13390677_112040_Linux-x86-64_4of7.zip
f9c9d077549efa10689804b3b07e3efd56c655a4aba51ec307114b46b8eafc5f  p13390677_112040_Linux-x86-64_5of7.zip
b2e08f605d7a4f8ece2a15636a65c922933c7ef29f7ad8b8f71b23fe1ecbaca8  p13390677_112040_Linux-x86-64_6of7.zip
1cb47b7c0b437d7d25d497ed49719167a9fb8f97a434e93e4663cfa07590e2ba  p13390677_112040_Linux-x86-64_7of7.zip


Identity and Access Management
------------------------------

Download from Oracle eDelivery:
  https://edelivery.oracle.com/EPD/Download/get_form?egroup_aru_number=15364661

Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 1 of 2 (Part 1 of 4)
  SHA-1         4326D264BA21CC87AE724CF6B5D3B130A966579B
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 1 of 2 (Part 2 of 4)
  SHA-1         C1AC8EEA2ADD699EE6D8723445D5FCBE8603DAFF
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 1 of 2 (Part 3 of 4)
  SHA-1         7FB76DF9ACE7B0E54F4B8448307720DBA8635071
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 1 of 2 (Part 4 of 4)
  SHA-1         B9739C4D0B3A9D704FB7356F946E049882616637
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 2 of 2 (Part 1 of 3)
  SHA-1         F96849F2781B581419A1852865C44C6E69881B21
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 2 of 2 (Part 2 of 3)
  SHA-1         560C49239B05C4DC7DEF69B44865FF19894F0846
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 2 of 2 (Part 3 of 3)
  SHA-1         71E1FE0A15FC54DBC7EAC279F7B6FB8E4B879CC3

p18231786_111220_Generic.zip - Patch for installation images
  SHA-1         72d6dc6c1e970e44736ba25f50723645ebc9bd10
```

