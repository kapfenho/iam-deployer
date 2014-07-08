Identity and Access Management Deployment
=========================================

## Auto Deployment in one VM

Create the infrastructure from scratch (check prereqs first):

    $ vagrant up

Remove the environment with

    $ vagrant destroy

Shell provisioning needs to be started manually (see Setup).


## Prerequisites

* [Vagrant](http://www.vagrantup.com) 
* Virtualization Provider, e.g. [VirtualBox](https://www.virtualbox.org)
* Oracle installation files
* Minimum RAM: 8 GB
* Disk space: 30 GB

## What's in?

Database VM:
* Cent OS 6.5 64bit minimal
* Oracle Database 11.2.0.3.x EE

Application and Web Server:
* Cent OS 6.5 64bit minimal
* JRockit 64bit (JDK 1.6.0\_51)
* WebLogic 10.3.6 (incl Coherence, without samples)


## Detailed Description

You can customize and modify the procedure after reading this README.

### Procedure

The virtual machine is created with ´vagrant up´, configuration and
trigger points for software installation is inside Vagrantfile.

System configuration: the script "1. XXX" produces a script that needs
to be executed as root. This root-ocript will also create the
application users and groups.

The application installation scripts can then be run as the appropriate
application user.

If you want to execute those scripts on your own, just remove the call
in Vagrantfile.

### Configure Installation

You need to have two configuration files, samples for those are
delivered with:

    cp config/resources.config.sample config/resources.config
    cp config/mysystem.config.sample config/mysystem.config

Now modify them according your needs.

* resources.config: location of installation resources
* mysystem.config:  how your new system will look like


### Run Installation

Mount the install directory
* `mkdir /mnt/install`
* `mount -t nfs -o proto=tcp,port=2049 kapfenho-dev.at-work.local:/export/install /mnt/install/`

Run scripts in following order:

* `s1-config-sys.sh`
* `s2-install-db.sh`
* `s0-rcu.sh IDM`
* `s3-install-idm.sh`
* `s0-rcu.sh IAM`
* `s4-install-iam.sh`


Configure the host system

* `configure-system.sh`

Produces a script the system admin needs to run on the server (root).

* `install-dbs.sh`

The script will install the database system, create the database
instance, and all necessary services like listeners, etc.

* `install-idm.sh`

Installation of software into a new Oracle home directory and creation
of a new instance with Oracle Internet Directory, Oracle Virtual
Directory, Directory Integration Platform, Directory Service
Manager, and the Enterprise Manager of this software suite.

* `install-iam.sh`

Installation of software into a new Oracle home directory and creation
of a new instance with Oracle Access Manager, Oracle Identity Manager,
Oracle Identity Analytics and the Enterprise Manager of this software 
suite.


## Remarks

Installation of software suites are separated to install them under
seperate user accounts.

## Directories and Files

* app:      application specific stuff
* config:   all configuration 
* doc:      documentation
* lib:      installation libs, templates, etc.
* sys:      system depended stuff

