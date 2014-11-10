## user environments

    ~/.env/common.env
    ~/.bash_profile

## create user-config and key files

    /vagrant/lib/init-wls-access.sh
    /vagrant/lib/init-wls-identity.sh
    
## rc.d scripts

    /etc/rc.d/init.d/iamnm          Node Manager
    /etc/rc.d/init.d/iamadmin       Admin Server
    /etc/rc.d/init.d/iamoim         Identity Manager
    /etc/rc.d/init.d/iamsoa         SOA
    /etc/rc.d/init.d/iamoam         Access Manager
    /etc/rc.d/init.d/iamdir         Unified Directory
    /etc/rc.d/init.d/iamweb         WebTier
    /etc/rc.d/init.d/functions-wls  LSB functions

    /etc/rc.d/init.d/wls-identity   Domain Settings Idenity Manager
    /etc/rc.d/init.d/wls-access     Domain Settings Access Manager

## change log directories

    /vagrant/lib/init-logs.sh


## post steps

* psa identity
* psa access
* oud changes ACL
* oim changes
* oam changes




