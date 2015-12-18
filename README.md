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

This project simplifies the deployment of Oracle Identity and Access
Management. However, a knowledge of the Oracle software and the original
documentation is essential for using and installing the components! 

**This README is not a subsitiute for the Oracle installation guides!**

__Read those guides before and then continue.__


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

_It is required to use a POSIX compliant environment for using the
project - including Vagrant. As script environment the project is using
bash(8). It may be possible to run the provisioning on Microsoft Windows 
by installing 3rd party tools. However we recommend to use Unix/BSD or Linux._


### Oracle Application Versions

* Oracle Enterprise Database 11.2 or 12
* Oracle Identity and Access Management 11.1.2.2 or 11.1.2.3
* Oracle Identity Analytics 11.1.1.5

The currently supported versions of the Oracle Identity and Access
Management Suite the version specific README files:

    11.1.2.2:  doc/iam-11.1.2.2.markdown
    11.1.2.3:  doc/iam-11.1.2.3.markdown

You will find information there like how to get the software, the bundle
patches and used data check sums.


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

------------------------------------------------------------------------

# After the Deployment

You can start and stop the application service with `start-*` and
`stop-*` scripts that are already in the path - use Tab key for
auto-completion to see what's availble. `start-all` and `stop-all` are
also available.

The Oracle database is the only service with runlevel scripts activated.
You can activate to application ones as well, but as a consequence
restarting the host will take significant longer.

In case you've provisioned a VM: why not creating a snapshot now -
the waiting time is worth a backup. If you plan to do development on the
machine, a layered filesystem on top of the installation may help you to
handle the deltas.


## User Environment

When you log into the host as the application user (e.g. `fmwuser`) you
will find those directories in the home directory:

    ~/.env      shell environment and wlst properties files
    ~/.creds    weblogic user keyfiles for admin access
    ~/bin       start/stop/status scripts and other helpers
    ~/lib       common functions (deploying, etc)

On a cluster environment remember where to start the individual
services. You can also control all services from one machine, the
ssh-connectivity is available.


## Where is my User Interface

The setup uses multiple virtual hosts (in webserver language) for user
interfaces. There are different reasons for this.

In a tyical production environment, with designated VLAN and hardware
load balancers, virtual hosts help you to seperate access already on an
infrastructure layer. This approach is flexible, you can put those names
on one IP address, on seperated ones or even on seperated VLAN. You can
implement multiple application domains, without rewriting URLs, etc.

The default setup comes with this URLs:

    https://sso.iamvs.agoracon.at/identity          Identity Manager
    https://sso.iamvs.agoracon.at/rbacx             Identity Analytics
     http://iamadmin.iamvs.agoracon.at/console      IAM console
     http://iamadmin.iamvs.agoracon.at/em           IAM em
     http://oiaadmin.iamvs.agoracon.at/console      OIA console
     http://idminternal.iamvs.agoracon.at/soa       SOA interfaces

For connection to the UI from your host add something like this to your
hosts file or DNS:

    192.168.168.250              iamvs.agoracon.at  # hostname
    192.168.168.250          sso.iamvs.agoracon.at  # lb frontend
    192.168.168.250  idminternal.iamvs.agoracon.at  # lb api on backend
    192.168.168.250     iamadmin.iamvs.agoracon.at  # weblogic admin
    192.168.168.250     oiaadmin.iamvs.agoracon.at  # weblogic admin
    192.168.168.250        oradb.iamvs.agoracon.at  # database

You can change the HTTP routing in the OHS `moduleconf` files. We've
extended the Oracle setup with a modular approach where you include
sub-modules in the virtual host (access point).


## Something Left To Do?

The provisioning is done with the same credentials for many (service)
users. Before go-live you really should change this situation. Use
scripts for changing service user passwords.

You may want to force admins to use named users, that's possible
and recommended.

------------------------------------------------------------------------

# The Provisioning Process

## Overview

For provisioning an evironment you need some patience and those
artefacts:

* this project
* a complete configuration set, symlinked as `user-config`
* the software installation images from Oracle
* the target hardware or system resources


### Project

Get the project by cloning the repo:

    git clone .....

The project consists of scripts and templates, everything already under
version control. You will also add files there - your configuration
files.

To get a new environment provisioned you need to describe how
it shall look like - what are the host names, ip addresses, domain
names, etc.

------------------------------------------------------------------------

## Configuration Set: One Environment

One configuration set describes one complete environment. It consists of
several directories and files, that must not be renamed or deleted. 

You can create a new configuration set with the command
(see below how to set the environment for command execution):

    ./iam create -t {single|cluster}

The working directory specifier is necessary if you don't have the
project directory in your PATH (which is not required). For simplicity I
won't mention it from here on.

It may be a good idea to add the new config to the version control
system. You can keep multiple environments in the project. The project
expects the current configuration set in the subdirectory `user-config`.
This directory is excluded from _git_ (`.gitignore`). Put all your
instances in one containing directory (`instances`) and symlink your
current one to `user-config`:

    ln -s instances/my_instance user-config
    ln -s user-config/vagrant/Vagrantfile

All available config files:

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
│   └── rbacx_workflow.patch    <- OIA workflow: config as patch
```

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


### Installation Images

Please see the version specific document for what software packages to
get.

You will put thos packages on a NFS mount point reachable from all
machines. Or copy them to all machines to the same location.


### System Resources

See the Oracle System Requirements for the minimum resources required.

Fot testing purposes: all versions supported have been provisioned
successfully in a single host setup on a MacBook Pro with 16 GB RAM
using VirtualBox 4 and 5.

The core deployment consists of the following steps:

- Virtual Machine(s) Creation (optional)
- OS configuration and package installation
- Installation of Oracle Enterprise Database
- Database instance creation
- Creation of products database schema(s)
- Installation of Oracle's Lifecycle Manager (LCM)
- IAM deployment with LCM
- Oracle Analytics deployment
- IAM post installation tasks

------------------------------------------------------------------------

## Vagrant

Skip this step if you provision on already existing VM or bare metal.

For detailed configuration of virtual machines and the syntax used
please see the [Vagrant documentation](https://vagrantup.com)


### Vagrant VLAN Configuration

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


### Vagrant Provisioning

You start the provisioning process with `vagrant up`. This will trigger
all necessary steps and come back with a ready to use system. The
runtime is four to ten hours, depending on your config and scenario.

The process starts with the creation of the virtual machine(s). The OS
will be configured, system packages, user and groups are added. The
cluster setup also creates an NFS Server which hosts the necessary
shared mount points.

The database will be installed under a designated user (`oracle:dba`). A
ping-check helps making sure application provisioning on cluster
topology will be postponed until all hosts are up and running.

You can find more information on the individual steps under section
"Manual Approach".

It's important to remember that controlling the VM and the main
provisioning steps is done outside the environment with `vagrant ...`
while the `iam ...` commands are executed on the host(s).

Info: Vagrant mounts this project directory on each machine at `/vagrant`
with permissions `vagrant:vagrant`.

A necessary hardware load balancer is substituted by a simple port
forwarding in the OS kernel of the first web server:

    http:  tcp/80  -> tcp/7777
    https: tcp/443 -> tcp/4443

Getting rid of your environment is not much more effort to type with
Vagrant: `vagrant destroy`.


## Manual Approach: Provisioning on Existing Hosts

Read carefully if you plan to provision on existing hosts. The topics
here are also valid when using Vagrant, but using existing hosts
replaces the properly prepared base box with an host that for sure has a
different configuration.

Before you start to provision individual hosts, execute your setup with 
Vagrant on VMs using the basebox. This helps you to save a lot of time.
In case something fails on the individual host setup, compare the
situation to the Vagrant run. See troubleshooting below for additional
information.


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


### Access Between Hosts

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


### Creating and Removing Database Schemas

Creating the schema is part of the worklist execution. If you need to
execute it manually use

    iam rcu -a {create|remove} -t {identity|access|bip}


------------------------------------------------------------------------

## Troubleshooting

When something fails during the provisioning run, you will most likely see
immediatelly what's the cause of it.

### Errors and Restart

Usually you can resolve the problem and rerun, but not during the LCM
steps. If an LCM step fails you need to remove the deployed software
(not the database and LCM) and usually recreate the database schema. The
step `preconfigure` writes into the database, so when you fail in the
step or later recreate the database schemas with `iam rcu ...` (see
above), remove the software with `iam remove ...` and restart the
provisioning `iam provision`.

### Log Information

You can get more details from reading the log files in

    $iam_top/lcm/lcmhome/provisioning/logs/`hostname -f`/*

Listing the log files with options `-lrt` sorts them chronologically.
Opening them with `less -S` prevents wrapping long lines.

Quite often the route cause is a misconfiguration in the config set or
the host OS, or not removing the last runs files, etc.


