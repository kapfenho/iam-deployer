IAM Deployment Steps
====================

# Deploy Platform

Otherwise the envs will bring errors.


## Move Log Directories to Log Disk

## Hostenv

    user-config/libexec/dom-userconf.sh
    
    * $HOME/.env
    * $HOME/bin
    * $HOME/lib

## Post Installation Tasks

    user-config/libexec/post-install.sh


## Deploy WLST Library

Copy the custom functions to both domains.

    cp acStdLib.py /opt/fmw/products/{identity,access}/wlserver_10.3/common/wlst/


## Configure Access Domain

    wlst access-config.py


## Configure Identity Domain

    wlst identity-config.py


## TODO:
* nodemanager configs
* nm_host problem


## OIM Scheduler Clustering

The scheduler will only run in one of the managed OIM servers. In the other one
set "scheduler.disabled=false" in the console in "configure -> server start"
and restart the server.

This setting will only be effective when started by node manager.


Deploy Imint
============

* Set startup parameters in OIM managed servers
* Create deployment directory structure
* Put config and plan files there and adapt adjust them
* Deploy with deploy script


WebTier
=======

## Deploy Web Config Files

```
# user-config call
lib/copy-webtier.sh user-config/webtier /opt/local/instances/ohs1/config/OHS/ohs1
```


# Deploy Certificates

## HTTPS Certificates

TODO

## Access Manager Domain

TODO

## Identity Manager Domain

TODO


## URLs of OIM Integration

Manually change them in `OIM_DOMAIN/config/fmwconfig/oam-config.xml`


```
https://sso.dwpbank.net/identity/faces/forgotpassword
https://sso.dwpbank.net/identity/faces/register
https://sso.dwpbank.net/identity/faces/trackregistration
```



## TLS Settings

### OUD

CVE-2014-3566 Instructions to Mitigate the SSL v3.0 Vulnerability (aka
"Poodle Attack") in Oracle Unified Directory (Doc ID 1950331.1)

Implementation:

```
* lib/liboud.sh
* user-config/libexec/oud-post.sh

# LDAPS
#
dsconfig set-connection-handler-prop \
  --handler-name LDAPS\ Connection\ Handler \
  --add ssl-protocol:TLSv1 \
  --add ssl-protocol:TLSv1.1 \
  --add ssl-protocol:TLSv1.2 \
  --trustAll \
  --no-prompt
    
# StartTLS
#
dsconfig set-connection-handler-prop \
  --handler-name LDAP\ Connection\ Handler \
  --add ssl-protocol:TLSv1 \
  --add ssl-protocol:TLSv1.1 \
  --add ssl-protocol:TLSv1.2 \
  --trustAll \
  --no-prompt
    
# Replication
#
dsconfig set-crypto-manager-prop \
  --add ssl-protocol:TLSv1 \
  --add ssl-protocol:TLSv1.1 \
  --add ssl-protocol:TLSv1.2 \
  --trustAll \
  --no-prompt 
```

