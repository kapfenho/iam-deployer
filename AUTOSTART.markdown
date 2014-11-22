RC.D Startup Scripts - IAM
==========================

Copy the scripts to

    /etc/rc.d/init.d/ 
    
Directory on each machine, adapt the local settings (machine name, user 
name, service name, etc).

    chkconfig --add <script>          # register service
    chkconfig <script> on | off       # auto start yes | no

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

