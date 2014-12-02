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

On a single host installation this looks like:

```
$ chkconfig
...
iam-dir          0:off   1:off   2:off   3:on    4:on    5:on    6:off
iam-node         0:off   1:off   2:off   3:on    4:on    5:on    6:off
iama-admin       0:off   1:off   2:off   3:on    4:on    5:on    6:off
iama-oam         0:off   1:off   2:off   3:on    4:on    5:on    6:off
iami-admin       0:off   1:off   2:off   3:on    4:on    5:on    6:off
iami-oim         0:off   1:off   2:off   3:on    4:on    5:on    6:off
iami-soa         0:off   1:off   2:off   3:on    4:on    5:on    6:off
iam-web          0:off   1:off   2:off   3:on    4:on    5:on    6:off
...
```

_See below for the output on the mulit-node setup._

Now you can use

    service <script> start | stop | restart | status
    
To check if service is running use `service ... status`.  It is not 
recommended implementing you own mechanisms - identifying WebLogic 
services can be tricky.


```
server oim1
-----------
/etc/rc.d/init.d/iam-node        nodemanager
/etc/rc.d/init.d/iami-admin      weblogic admin
/etc/rc.d/init.d/iami-soa        soa services wls_soa_1
/etc/rc.d/init.d/iami-oim        identity manager wls_oim1
/etc/rc.d/init.d/funtions-wls    functions
/etc/weblogic/wls-identity       domain settings


server oim2
-----------
/etc/rc.d/init.d/iam-node        nodemanager
                                 iami-admin only on oim1
/etc/rc.d/init.d/iami-soa        soa services wls_soa_1
/etc/rc.d/init.d/iami-oim        identity manager wls_oim1
/etc/rc.d/init.d/funtions-wls    functions
/etc/weblogic/wls-identity       domain settings


server oam1
-----------
/etc/rc.d/init.d/iam-node        nodemanager
/etc/rc.d/init.d/iama-admin      weblogic admin
/etc/rc.d/init.d/iama-oam        access manager services wls_oam1
/etc/rc.d/init.d/funtions-wls    functions
/etc/weblogic/wls-access         domain settings


server oam2
-----------
/etc/rc.d/init.d/iam-node        nodemanager
                                 admin only on node1
/etc/rc.d/init.d/iama-oam        access manager services wls_oam1
/etc/rc.d/init.d/funtions-wls    functions
/etc/weblogic/wls-access         domain settings


server oud1
-----------
/etc/rc.d/init.d/iam-dir         directory service


server oud2
-----------
/etc/rc.d/init.d/iam-dir         directory service


server web1
-----------
/etc/rc.d/init.d/iam-web         webtier services


server web2
-----------
/etc/rc.d/init.d/iam-web         webtier services
```


```
###  dwptidw1  ### 
iam-web         0:off   1:off   2:off   3:on    4:on    5:on    6:off 

###  dwptidw2  ### 
iam-web         0:off   1:off   2:off   3:on    4:on    5:on    6:off 

###  dwptoam1  ### 
iam-node        0:off   1:off   2:off   3:on    4:on    5:on    6:off 
iama-admin      0:off   1:off   2:off   3:on    4:on    5:on    6:off 
iama-oam        0:off   1:off   2:off   3:on    4:on    5:on    6:off 

###  dwptoam2  ### 
iam-node        0:off   1:off   2:off   3:on    4:on    5:on    6:off 
iama-oam        0:off   1:off   2:off   3:on    4:on    5:on    6:off 

###  dwptoim1  ### 
iam-node        0:off   1:off   2:off   3:on    4:on    5:on    6:off 
iami-admin      0:off   1:off   2:off   3:on    4:on    5:on    6:off 
iami-oim        0:off   1:off   2:off   3:on    4:on    5:on    6:off 
iami-soa        0:off   1:off   2:off   3:on    4:on    5:on    6:off 

###  dwptoim2  ### 
iam-node        0:off   1:off   2:off   3:on    4:on    5:on    6:off 
iami-oim        0:off   1:off   2:off   3:on    4:on    5:on    6:off 
iami-soa        0:off   1:off   2:off   3:on    4:on    5:on    6:off 

###  dwptoud1  ### 
iam-dir         0:off   1:off   2:off   3:on    4:on    5:on    6:off 

###  dwptoud2  ### 
iam-dir         0:off   1:off   2:off   3:on    4:on    5:on    6:off 


###  dwptidw1  ### 
-rwxr-xr-x 1 root root 2142 Nov 28 14:33 /etc/rc.d/init.d/iam-web 

###  dwptidw2  ### 
-rwxr-xr-x 1 root root 2142 Nov 28 14:33 /etc/rc.d/init.d/iam-web 

###  dwptoam1  ### 
-rw-r--r-- 1 root root 1630 Nov 28 14:38 /etc/rc.d/init.d/functions-wls 
-rwxr-xr-x 1 root root 3098 Nov 28 17:00 /etc/rc.d/init.d/iam-node 
-rwxr-xr-x 1 root root  738 Nov 28 14:34 /etc/rc.d/init.d/iama-admin 
-rwxr-xr-x 1 root root  715 Nov 28 14:34 /etc/rc.d/init.d/iama-oam 
-rw-r--r-- 1 root root  431 Nov 28 14:34 /etc/rc.d/init.d/wls-access 

###  dwptoam2  ### 
-rw-r--r-- 1 root root 1630 Nov 28 14:38 /etc/rc.d/init.d/functions-wls 
-rwxr-xr-x 1 root root 3098 Nov 28 17:00 /etc/rc.d/init.d/iam-node 
-rwxr-xr-x 1 root root  715 Nov 28 14:35 /etc/rc.d/init.d/iama-oam 
-rw-r--r-- 1 root root  431 Nov 28 14:35 /etc/rc.d/init.d/wls-access 

###  dwptoim1  ### 
-rw-r--r-- 1 root root 1630 Nov 28 14:37 /etc/rc.d/init.d/functions-wls 
-rwxr-xr-x 1 root root 3098 Nov 28 17:00 /etc/rc.d/init.d/iam-node 
-rwxr-xr-x 1 root root  758 Nov 28 14:35 /etc/rc.d/init.d/iami-admin 
-rwxr-xr-x 1 root root  739 Nov 28 14:35 /etc/rc.d/init.d/iami-oim 
-rwxr-xr-x 1 root root  737 Nov 28 14:35 /etc/rc.d/init.d/iami-soa 
-rw-r--r-- 1 root root  425 Nov 28 14:35 /etc/rc.d/init.d/wls-identity 

###  dwptoim2  ### 
-rw-r--r-- 1 root root 1630 Nov 28 14:37 /etc/rc.d/init.d/functions-wls 
-rwxr-xr-x 1 root root 3098 Nov 28 17:00 /etc/rc.d/init.d/iam-node 
-rwxr-xr-x 1 root root  739 Nov 28 14:35 /etc/rc.d/init.d/iami-oim 
-rwxr-xr-x 1 root root  737 Nov 28 14:35 /etc/rc.d/init.d/iami-soa 
-rw-r--r-- 1 root root  425 Nov 28 14:35 /etc/rc.d/init.d/wls-identity 

###  dwptoud1  ### 
-rwxr-xr-x 1 root root 2744 Nov 28 14:35 /etc/rc.d/init.d/iam-dir 

###  dwptoud2  ### 
-rwxr-xr-x 1 root root 2744 Nov 28 14:36 /etc/rc.d/init.d/iam-dir 
```


