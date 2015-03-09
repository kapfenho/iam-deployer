# Environment Setup

## post install steps

* set user environment
* psa identity
* psa access
* oud changes ACL
* oim changes
* oam changes





### set user environments

Scripts to execute:

    libexec/init-userenv.sh

Output files:

    ~/.bash_profile                 [all]        One line added
    ~/.env/common.env               [all]        Local env (individual)
    ~/.env/identity.prop            [oim]        WLST properties
    ~/.env/access.prop              [oam]        WLST properties
    ~/.env/tools.properties.prop    [dir]        LDAP tools properties

### create user-config and key files

Scripts to execute:

    /vagrant/libexec/init-wls-access.sh
    /vagrant/libexec/init-wls-identity.sh

Output files:

    ~/.cred/nm.{usr,key}            [oim, oam]  Nodemanager access files
    ~/.cred/identity_test.{usr,key} [oim]       Domain access files
    ~/.cred/access_test.{usr,key}   [oam]       Domain access files
    
### rc.d scripts

    /etc/rc.d/init.d/iamnm          [oim,oam]   Node Manager
    /etc/rc.d/init.d/iamadmin       [oim1,oam1] Admin Server
    /etc/rc.d/init.d/iamoim         [oim]       Identity Manager
    /etc/rc.d/init.d/iamsoa         [oim]       SOA
    /etc/rc.d/init.d/iamoam         [oam]       Access Manager
    /etc/rc.d/init.d/iamdir         [oud]       Unified Directory
    /etc/rc.d/init.d/iamweb         [web]       WebTier
    /etc/rc.d/init.d/functions-wls  [oim,oam]   LSB functions

    /etc/rc.d/init.d/wls-identity   [oim]       Domain Settings Idenity Manager
    /etc/rc.d/init.d/wls-access     [oam]       Domain Settings Access Manager

### change log directories

Scripts to execute:

    /vagrant/libexec/init-logs.sh

Log file directories created:

    /var/log/fmw/identity_test
    /var/log/fmw/access_test
    /var/log/fmw/oud1
    /var/log/fmw/oud2
    /var/log/fmw/ohs1
    /var/log/fmw/ohs2





