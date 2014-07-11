Identity and Access Management Deployment
=========================================

## Auto Deployment in one VM

After checking the pre-requisites and editing you destination desription
you can create the environment with:

    $ vagrant up

Remove the environment with:

    $ vagrant destroy

Start using your env:

* Identity Manager: http://machine:14000/identity
* Access Manager:   http://machine:7001/oamconsole


## Prerequisites

* [Vagrant](http://www.vagrantup.com) 
* A Virtualization Provider, e.g.
[VirtualBox](https://www.virtualbox.org), [VMWare](https://www.vmware.com)
  [Docker](https://www.docker.io) support is in development and not supported yet
* Oracle installation files
* Minimum RAM: 10 GB, better 12 GB

## What's in?

Database VM:
* Oracle Database 11.2.0.3.x EE
* a database instance with schemas for IAM

Application and Web Server:
* Cent OS 6.5 64bit minimal
* JRockit 64bit (JDK 1.6.0\_51)
* WebLogic 10.3.6 (incl Coherence, without samples)
* Oracle Unified Directory 11.1.2.2
* Oracle Identity and Access Mgmt Suite 11.1.2.2


## Detailed Description

You can customize and modify the procedure after reading this README.

### Procedure

Put the installation images in a directory on your local machine (when
deploying to VM on your local machine) or on a network server. This
directory will be mounted on the new servers via NFS. There is no need
to copy the files onto the new virtual machines.

Adapt the configuration files according to your needs in:

    Vagrantfile                         # <- machine configs
    ├── user-config
        ├── database.config             # <- database server
        ├── dbs
        │   ├── db_create.rsp           # <- database server
        │   ├── db_install.rsp          # <- database server
        │   └── db_netca.rsp            # <- database server
        ├── iam
        │   ├── provisioning.rsp        # <- other servers
        │   ├── provisioning_data
        │   │   └── cwallet.sso         # <- other servers
        │   ├── psa_access.rsp          # <- other servers
        │   └── psa_identity.rsp        # <- other servers
        ├── iam.config                  # <- other servers
        └── lcm
            └── lcm_install.rsp         # <- other servers

See below for using configuration management.



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



## Configuration Management

It is crucial to save your configurations for deploying and staging in later
phases.

The \*.rsp files are standard Oracle response files, used typically in server
installations. Whatever you configure you should keep your configuration and
add it to your configuration management. With Git you would now branch the
project and add those files (beside the shipped example files that you've used
as templates), eg. with:

    $ git checkout -b mydevboxbranch
    $ git add .
    $ git commit -m "initial version of mydevbox config"

You can add your own git server with

    $ git remote add mygit ssh://git@git.srv.priv/myrepo.git
    $ git push mygit mydevboxbranch


## Directories and Files
.
├── CHANGELOG
├── LICENSE.txt
├── README.markdown
├── Vagrantfile
├── db.sh
├── iam.sh
├── lib
│   ├── dbs
│   │   └── ocm.rsp
│   ├── files.sh
│   ├── libcommon.sh
│   ├── libdb.sh
│   ├── libiam.sh
│   ├── libjdk.sh
│   ├── librcu.sh
│   ├── libsys.sh
│   ├── libsysprint.sh
│   ├── libwlst.sh
│   └── templates
│       ├── dbs
│       │   ├── bash_profile
│       │   └── bashrc
│       └── iam
│           ├── env
│           │   ├── acc.sh
│           │   ├── common.sh
│           │   ├── dir.sh
│           │   ├── idm.sh
│           │   └── web.sh
├── remove-iam.sh
├── results
│   └── certs
│       ├── oud.crt
│       └── oud.txt
├── sys
│   ├── redhat
│   │   ├── centos6
│   │   │   └── idm-common-preverify-build.xml.patch
│   │   ├── epel-release-6-8.noarch.rpm
│   │   └── rc.d
│   │       ├── iam-access
│   │       ├── iam-dir
│   │       ├── iam-identity
│   │       ├── iam-nodemanager
│   │       └── oracle
│   └── vim
│       ├── bundle.tar.gz
│       ├── pathogen.vim
│       └── vimrc
├── sys.sh
└── user-config
    ├── database.config
    ├── database.config.example
    ├── dbs
    │   ├── db_create.rsp
    │   ├── db_create.rsp.example
    │   ├── db_install.rsp
    │   ├── db_install.rsp.example
    │   ├── db_netca.rsp
    │   └── db_netca.rsp.example
    ├── iam
    │   ├── provisioning.rsp
    │   ├── provisioning.rsp.example
    │   ├── provisioning_data
    │   │   └── cwallet.sso
    │   ├── provisioning_templ.rsp
    │   ├── provisioning_used.rsp
    │   ├── psa_access.rsp
    │   ├── psa_access.rsp.example
    │   ├── psa_access_commented.rsp.example
    │   ├── psa_identity.rsp
    │   ├── psa_identity.rsp.example
    │   └── psa_identity_commented.rsp.example
    ├── iam.config
    ├── iam.config.example
    └── lcm
        ├── lcm_install.rsp
        └── lcm_install.rsp.example

36 directories, 116 files

