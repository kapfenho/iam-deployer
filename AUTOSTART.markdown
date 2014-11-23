RC.D Startup Scripts for RedHat and CentOS
==========================================

Redhat versions below 7 supports SysV and LSB scripts and maintains them
in /etc/rc.d/init.d

This project comes with several scripts and config files. In the
following table you can find all services, ordered by type and
technology, and the dependencies.

```
Description                 Name            Depends On
--------------------------  --------------  -----------------------------
Oracle Access Manager (OAM), WebLogic Domain

AdminServer                 iama-admin      iam-node,iam-dir,iama-oam,db
Access managed server       iama-oam        iam-node,iam-dir,db

Oracle Identity Manager (OIM), WebLogic Domain

AdminServer                 iami-admin      iam-node,iam-dir,iama-oam,db
SOA Services                iami-soa        iam-node,iam-dir,db
IDM Services                iami-oim        iam-node,iam-dir,iama-oam,db

WebLogic Nodemanager
Nodemanager                 iam-node

Web Services
OHS with Webgate            iam-web

Directory Services
Oracle Unified Directory    iam-dir
```


## Installation

Copy the scripts to

    /etc/rc.d/init.d/ 

directory on each machine. Adapt the local settings:

* machine name
* user name
* service name
* log directory

In case you change the name of a service, don't forget to change it's
occurence in the dependency lists of the other services.

The WebLogic services take additional parameters from two config files -
one per domain. You need to adapt those as well.

All 

    chkconfig --add <script>          # register service
    chkconfig <script> on | off       # auto start yes | no

```
$ chkconfig
...
iamdir          0:off   1:off   2:on    3:on    4:on    5:on    6:off
iamnm           0:off   1:off   2:on    3:on    4:on    5:on    6:off
iamoamadm       0:off   1:off   2:on    3:on    4:on    5:on    6:off
iamoamoam       0:off   1:off   2:on    3:on    4:on    5:on    6:off
iamoimadm       0:off   1:off   2:on    3:on    4:on    5:on    6:off
iamoimoim       0:off   1:off   2:on    3:on    4:on    5:on    6:off
iamoimsoa       0:off   1:off   2:on    3:on    4:on    5:on    6:off
iamweb          0:off   1:off   2:on    3:on    4:on    5:on    6:off
...
```

Now you can use

    service <script> start | stop | restart | status
    
To check if service is running use `service ... status`.  It is not 
recommended implementing you own mechanisms - identifying WebLogic 
services can be tricky.


```
server oim1
-----------
  iamnm           nodemanager
  iamadmin        weblogic admin
  iamsoa          soa services wls_soa_1
  iamoim          identity manager wls_oim1
    wls_identity  domain settings
    funtions-wls  functions


server oim2
-----------
  iamnm           nodemanager
  iamsoa          soa services wls_soa2
  iamoim          identity manager wls_oim2
    wls_identity  domain settings
    de
    funtions-wls  functions


server oam1
-----------
  iamnm           nodemanager
  iamadmin        weblogic admin
  iamoam          access manager wls_oam1
    wls_access    domain settings
    funtions-wls  functions


server oam2
-----------
  iamnm           nodemanager
  iamoam          access manager wls_oam2
    wls_access    domain settings
    funtions-wls  functions


server oud1
-----------
  iamdir          unified directory oud1


server oud2
-----------
  iamdir          unified directory oud2


server web1
-----------
  iamweb          web services, policy enforcement


server web2
-----------
  iamweb          web services, policy enforcement
```

