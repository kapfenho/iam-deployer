```
 _                      __      _            _                       
 (_) __ _ _ __ ___      / /   __| | ___ _ __ | | ___  _   _  ___ _ __ 
 | |/ _` | '_ ` _ \    / /   / _` |/ _ \ '_ \| |/ _ \| | | |/ _ \ '__|
 | | (_| | | | | | |  / /_  | (_| |  __/ |_) | | (_) | |_| |  __/ |   
 |_|\__,_|_| |_| |_| /_/(_)  \__,_|\___| .__/|_|\___/ \__, |\___|_|   
                                       |_|            |___/           
```
### Identity and Access Management Deployment

This project will install and configure Oracle Identity and Access
Management 11gR2 and all required components either on a local VM or on
multiple servers in your data centre.

## Auto Deployment in one VM

If you go for the local VM setup you need those applications
installed before you start. _Not needed for a production setup._

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
* Access Manager:   `http://machine:7777/oamconsole`

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


## What's in?

Database, Application and Web Server:

* Cent OS 6.5 64bit minimal
* Oracle Database 11.2.0.3.x Enterprise Edition
* JRockit 64bit (JDK 1.6.0\_51)
* WebLogic 10.3.6 (incl Coherence, without samples)
* Oracle Unified Directory 11.1.2.2
* Oracle Identity and Access Mgmt Suite 11.1.2.2


## Detailed Description

This procedure simplifies the deployment of Oracle Identity and Access
Management. However, a knowledge of the Oracle software and the original
documentation is essential for using and installing the components! 

*This README is not a subsitiute for the Oracle installation guides!*

Read those guides before and then continue.

### Download Software

Download the software packages from edelivery.oracle.com, see at the end
of this file for a complete list with checksums.


### Create Installation Image Directory

You will need the following software packages from Oracle:

Put the installation images in a directory on your local machine (when
deploying to VM on your local machine) or on a network server. This
directory will be mounted on the new servers via NFS. There is no need
to copy the files onto the new virtual machines, the installer can read
them from any mounted location.

The structure in this directory should look like

```
├── iam-11.1.2.2                # the application packages
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
├── oracle-db-ee-11.2.0.3       # the databaes packages
│   └── p10404530_112030_Linux-x86-64
│       ├── client
│       ├── database
│       ├── deinstall
│       ├── examples
│       ├── gateways
│       └── grid
├── patches                     # common location for software patches
│   ├── p6880880_112000_Linux-x86-64.zip
│   ├── 16619892
│   │   ├── ...
```

### Patch the installation images

Yes, even the installation images need patching to be installed properly.
Download from [Oracle Support](https://support.oracl.com) the following
patch and apply it to the downloaded repository:

```
# fix for wrong 32bit specs: i386 -> i686
patch 18231786
```

### Create your config files

Create your own copy of the config files with the included help-script:

```
./createconf.sh
```

Adapt the configuration files according to your needs in:

```
Vagrantfile                         # <- machine configs
├── user-config
|   ├── database.config             # <- database server
|   ├── dbs
|   │   ├── db_create.rsp           # <- database server
|   │   ├── db_install.rsp          # <- database server
|   │   └── db_netca.rsp            # <- database server
|   ├── iam
|   │   ├── provisioning.rsp        # <- other servers
|   │   ├── provisioning_data
|   │   │   └── cwallet.sso         # <- other servers
|   │   ├── psa_access.rsp          # <- other servers
|   │   └── psa_identity.rsp        # <- other servers
|   ├── iam.config                  # <- other servers
|   └── lcm
        └── lcm_install.rsp         # <- other servers
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

    # ./changeconf.sh /appl/iam /usr/iam

The location of your image folder needs to be specified in those
variables:

```
* user-config/database.config:
    s_img_db
    s_patches
    s_rcu_home
* user-config/iam/provisioning.rsp:
    INSTALL_INSTALLERS_DIR
    IL_INSTALLERDIR_LOCATION
    COMMON_FUSION_REPO_INSTALL_DIR
```


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

## Project Directories and Files

Local config files are included.

```
├── CHANGELOG
├── LICENSE
├── README.markdown
├── TODO
├── Vagrantfile
├── Vagrantfile.example
├── changeconf.sh
├── createconf.sh
├── db.sh
├── iam.sh
├── lib
│   ├── dbs
│   │   └── ocm.rsp
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
│           └── env
│               ├── acc.sh
│               ├── common.sh
│               ├── dir.sh
│               ├── idm.sh
│               └── web.sh
├── remove-iam.sh
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
│   │       ├── iam-webtier
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
    │   ├── psa_access.rsp.commented_example
    │   ├── psa_access.rsp.example
    │   ├── psa_identity.rsp
    │   ├── psa_identity.rsp.commented_example
    │   └── psa_identity.rsp.example
    ├── iam.config
    ├── iam.config.example
    └── lcm
        ├── lcm_install.rsp
        └── lcm_install.rsp.example

```


## Software Packages to Download 

You can verify the checksums online at:

```
https://edelivery.oracle.com/EPD/ViewDigest/get_form?epack_part_number=B77727&export_to_csv=1
```

```
Oracle Database 11gR2 Enterprise Edition
----------------------------------------

Download from Oracle eDelivery:
  https://support.oracle.com

p10404530_112030_Linux-x86-64_1of7.zip    1.3 GB    (1358454646 bytes)
  SHA-1    80A78DF21976A6586FA746B1B05747230B588E34
  MD5    BDBF8E263663214DC60B0FDEF5A30B0A
p10404530_112030_Linux-x86-64_2of7.zip    1.1 GB    (1142195302 bytes)
  SHA-1    A39BED06195681E31FBB0F6D7D393673BA938660
  MD5    E56B3D9C6BC54B7717E14B6C549CEF9E
p10404530_112030_Linux-x86-64_3of7.zip    933.8 MB    (979195792 bytes)
  SHA-1    D33E19BB7EC804019F7A6B62C400F90FEDC0FDDD
  MD5    695CBAD744752239C76487E324F7B1AB
p10404530_112030_Linux-x86-64_4of7.zip    628.7 MB    (659229728 bytes)
  SHA-1    ACBA25F9D1B4ADD7F2D78734C5ED67B5753AA678
  MD5    281A124E45C9DE60314478074330E92B
p10404530_112030_Linux-x86-64_5of7.zip    587.9 MB    (616473105 bytes)
  SHA-1    8C914DA9EC06B7251A9E8F09B030F6AEDAD3953D
  MD5    4C0C62B6B005FE784E5EDFAD4CAE6F87
p10404530_112030_Linux-x86-64_6of7.zip    457.7 MB    (479890040 bytes)
  SHA-1    809D9FC97A7AE455E9E04FCFF50647D30A353441
  MD5    285EDC5DCCB14C26249D8274A02F9179
p10404530_112030_Linux-x86-64_7of7.zip    108.6 MB    (113915106 bytes)
  SHA-1    B71AC759C499BBA8D55504A1F8BE62F5DF469879
  MD5    D78C75A453B57F23A01A6234A29BFD3B

Patch for OPatch
  Don't extract the downloaded zip file!
  p6880880_112000_Linux-x86-64.zip
    SHA-1    8452c5e7bc27bfa528c49294c8b5a25e9c8f63b5
    MD5    75c2adc4c5e0111153267bf55189d48c

Patch for Database to 11.2.0.3.7
  p16619892_112030_Linux-x86-64.zip
    SHA-1    F80E2D18DF8A5EA46AAF3C2CF9FDF4AA0D162959
    MD5    6E306C6BC9C12185C9F0E12E34AAEC86

Identity and Access Management
------------------------------

Download from Oracle eDelivery:
  https://edelivery.oracle.com/EPD/Download/get_form?egroup_aru_number=15364661

Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 1 of 2 (Part 1 of 4)
  MD5         A4A9CDB1B0409EC04FCC5B5C0D46E9C7
  SHA-1         4326D264BA21CC87AE724CF6B5D3B130A966579B
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 1 of 2 (Part 2 of 4)
  MD5         875971FBE7E241BD52630E908A620C23
  SHA-1         C1AC8EEA2ADD699EE6D8723445D5FCBE8603DAFF
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 1 of 2 (Part 3 of 4)
  MD5         120C4C8D23C1CD77A99EAC38B7ABA761
  SHA-1         7FB76DF9ACE7B0E54F4B8448307720DBA8635071
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 1 of 2 (Part 4 of 4)
  MD5         9B9BBCB2F77F10EF096F0D8E50557ADF
  SHA-1         B9739C4D0B3A9D704FB7356F946E049882616637
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 2 of 2 (Part 1 of 3)
  MD5         7D1EE366658DA75AB22024096F2AC5BF
  SHA-1         F96849F2781B581419A1852865C44C6E69881B21
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 2 of 2 (Part 2 of 3)
  MD5         4514EE590EDE5C78D78292418133E82A
  SHA-1         560C49239B05C4DC7DEF69B44865FF19894F0846
Oracle Identity and Access Management Deployment Repository 11.1.2.2.0, Linux x86-64, part 2 of 2 (Part 3 of 3)
  MD5         09A352A3BFC14C20DCD4FF2EB3822CC0
  SHA-1         71E1FE0A15FC54DBC7EAC279F7B6FB8E4B879CC3

p18231786_111220_Generic.zip - Patch for installation images
  MD5         14f26521bc7763baf2d03770419bf9b6
  SHA-1         72d6dc6c1e970e44736ba25f50723645ebc9bd10
```

