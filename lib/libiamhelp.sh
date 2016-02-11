# help text for iam tool
#

iamhelp() {
  echo "
  Syntax: ${0} command [flags] [-h] [-H host] [-A]
 
  Setup IAM environments. Run individual actions or create workflow file 
  from template, modify and run it.

  Commands
    create    create workflow file from template
    provision run workflow file
    ssh-key   generate and deploy ssh keypair
    rcu       create database schemas with RCU
    orainv    create central oracle inventory pointer
    lcminst   install LCM
    lcmstep   execute LCM step
    userenv   create userenv on host
    jdk       upgrade existing jdk
    rcd       deploy runlevel scripts (root)
    weblogic  modify wlserver installation
    identity  modify identity domain (psa, jdk7fix, movelogs, postinstall)
    access    modify access domain   (psa, jdk7fix, movelogs, postinstall)
    analytics modify analytics domain
    webtier   modify webtier instance (movelogs, postinstall)
    remove    remove installation
    help      show this help

  Generell Parameters
    -A        All (execute on all hosts)
    -h        help
    -H host   execute on host

  Parameters
    -O Oracle home
    -P        Pack or unpack a domain
    -a action action
    -n        nodemanager (keyfiles)
    -p password
    -q        quiet mode (suppress detailed output)
    -s source
    -t target
    -T topology (single or cluster)
    -f filename
    -u username
    -w        wlst property file

"
  echo
}
# ---------------------------------------------------
help_create() {
  echo "
  Syntax: ${0} create [-T topology] [-f target_file]

    ${0} create -T single  -f user-config/workflow
    ${0} create -T cluster -f user-config/workflow

  Create new workflow definition by template.

  Parameter:
    -T   topology     single, enterprise
    -f   target_file  Output saved to file, default: user-config/workflow

  "
}
# ---------------------------------------------------
help_provision() {
  echo "
  Syntax: ${0} provision [-f workflow_file]

  Run full provisioning defined in workflow file.

  Parameter:
    -f   workflow_file  Defaults: user-config/workflow

  "
}
# ---------------------------------------------------
help_ssh_key() {
  echo "
  Syntax: ${0} ssh-key -a {generate|deploy} [-t key_dest]

    ${0} ssh-key -a generate -t key_dest
    ${0} ssh-key -a deploy [-s source_dir]

  Copy the common ssh keypair and authorized_keys file to the local 
  or specified host.

  Parameter:
    -a   action to perform
         generate     generate new ssh-key (rsa 4096)
         deploy       install (common) ssh-key on host
         add          add remote host to known_hosts on this machine
    -s   source_dir   default ${DEPLOYER}/lib/templates/hostenv/ssh
    -t   target_dir   default ~/.ssh

  "
}
# ---------------------------------------------------
help_orainv() {
  echo "
  Syntax: ${0} orainv

  Create Oracle inventory pointer file on specified host

  Configuration:
    pointer location:    ${iam_orainv_ptr}
    inventory location:  ${iam_orainv}
    install group:       ${iam_orainv_grp}

"
}
# ---------------------------------------------------
help_lcminst() {
  echo "
  Syntax: ${0} lcminst

  Install LCM (Life Cycle Manager) software

  PS3 patches included:
      21761480  Health check patch
      21197325  LCM patch

  Configuration:
    LCM Binaries:        ${iam_lcm}
    LCM instance config: ${iam_lcmhome}

  "
}
# ---------------------------------------------------
help_lcmprovmod() {
  echo "
  Syntax: ${0} lcmprovmod

  Modify PS3 provisioning profiles of LCM (Life Cycle Manager):

  * Remove health-checks and some pre-install-checks

  Configuration:
    LCM Binaries:        ${iam_lcm}
    LCM instance config: ${iam_lcmhome}

  "
}
#----------------------------------------------------
help_rcu()
{
  echo "
  Syntax: ${0} rcu -a {create|remove} -t product_name

    ${0} rcu -a create -t product_name
    ${0} rcu -a remove -t product_name
  
  Create database schemas for IAM products with RCU

  Parameter:
    -a   action to perform:
         create       create Database schema
         remove       remove Database schema
         
    -t   target product:
         identity     Identity Manager
         access       Access Manager
         bip          BI Publisher
         analytics    Identity Analytics

  Schemas and Usernames:

  Identity:     MDS, OPSS, SOAINFRA, ORASDPM, OIM 
                Prefix: variable iam_oim_prefix

  Access:       MDS, OPSS, IAU, OAM 
                Prefix: variable iam_oam_prefix

  BI-Publisher: MDS, BIPLATFORM
                Prefix: variable iam_bip_prefix

  Analytics:    Defined by variable iam_oia_dbuser
  
  Variables are defined in file iam.config

  "
}
# ---------------------------------------------------
help_lcmstep() {
  echo "
  Syntax: ${0} lcmstep -a step

  Execute an LCM provisioning step on all hosts in the defined order.
  
  Parameter:
    -a   step         provisioning step: {preverify|install|unblock|
                         preconfigure|configure|configure-secondary|
                         postconfigure|startup|validate}

  "
}
# ---------------------------------------------------
help_userenv() {
  echo "
  Syntax: ${0} userenv -a {env|profile}
    ${0} userenv -a env
    ${0} userenv -a profile

  Create user environment (bin,etc,lib,cred)
  Parameter:
    -a   action to perform
         env          create all files
         profile      modify bash user profile

  "
}
# ---------------------------------------------------
help_jdk() {
  echo "
  Syntax: ${0} jdk -a {install7|move6} -O oracle_home
    ${0} jdk -a install7 -O analytics
    ${0} jdk -a move6 -O identity

  Upgrade existing JDK (from JDK6 to JDK7). This takes place in two 
  steps: first install JDK7 (-a install7) then move the original one 
  and replace it by a softlink to the new one (used in products).

  Parameter:
    -a  action to perform
        install7    install JDK7
        move6       move and replace JDK6 by symlink
    -O  home        oracle_home to install|upgrade:
                       identity | access | analytics
                    
  Before exection:
    ORACLE_HOME/jdk6         shipped JDK

  After execution:
    ORACLE_HOME/jdk/current  link to new JDK
    ORACLE_HOME/jdk/jdkXXXX  new JDK
    ORACLE_HOME/jdk/jdk6     original JDK
    ORACLE_HOME/jdk6         link to new JDK

  "
}
# ---------------------------------------------------
help_rcd() {
  echo "
  Syntax: ${0} rcd -t target

  Deploy rc.d runlevel scripts 

  Parameter:
    -t   target       service to create runlevel script for:
                        {nodemanger|identity|access|webtier|oud}

  "
}
# ---------------------------------------------------
help_weblogic() {
  echo "
  Syntax: ${0} weblogic -a {install|jdk7fix|wlstlibs} -t target_path
    ${0} weblogic -a jdk7fix -t product_name
    ${0} weblogic -a wlstlibs -t product_name
    ${0} weblogic -a install -t product_name

  Modify or extend WebLogic installation

  Parameter:
    -a   action to perform
         jdk7fix     fix java parameters in commEnv.sh
         wlstlibs    add libs to wlst common directory
         install     install weblogic software
    -t   target wlserver path
         target_name: (identity|access|analytics)

  "
}
# ---------------------------------------------------
help_identity() {
  echo "
  Syntax: ${0} identity -a {jdk7fix|psa|keyfile|postinstall|movelogs}
                      [-t target_path] [-w wlst-prop-file] [-n] 
                      [-u user] [-p pwd]

    ${0} identity -a jdk7fix
    ${0} identity -a psa
    ${0} identity -a keyfile -u user -p pwd [-w wlst-prop-file] [-n]
    ${0} identity -a config
    ${0} identity -a postinstall
    ${0} identity -a movelogs

  Changes, fixes and user modifications for installed Idenity Manager instance

  Parameter:
    -a   action to perform
         jdk7fix      fix java parameters in commEnv.sh
         psa          run Patch Set assitant for OIM
         keyfile      create domain keyfiles for user
         config       apply custom domain config
         postinstall  access domain postinstall configuration
         movelogs     move identity domain logfiles to common location

    -t   target       wls server path
    -u   user         user to create keyfile for
    -p   password     password of user
    -w   path         path of WLST properties file to use
                        default: ~/.env/identity.prop
    -n                keyfile: create nodemanager keyfile (without: domain)

  "
}
# ---------------------------------------------------
help_access() {
  echo "
  Syntax: ${0} access -a {jdk7fix|psa|keyfile|movelogs}
                      [-t target_path] [-w wlst-prop-file] [-n] 
                      [-u user] [-p pwd]


    ${0} access -a jdk7fix
    ${0} access -a psa
    ${0} access -a keyfile -u user -p pwd [-w wlst-prop-file] [-n]
    ${0} access -a config
    ${0} access -a movelogs

  Changes, fixes and user modifications for installed Access Manager
  instance

  Parameter:
    -a   action to perform
         jdk7fix      fix java parameters in commEnv.sh
         psa          run Patch Set assitant for OAM
         keyfile      create domain keyfiles for user
         config       apply custom domain config
         postinstall  Access Domain postinstall configuration
         movelogs     Move Access Domain logfiles to common location
         
    -t   target       wls server path
    -u   user         user to create keyfile for
    -p   password     password of user
    -w   path         path of WLST properties file to use
                      default: ~/.env/access.prop
    -n                keyfile: create nodemanager keyfiles

  "
}
# ---------------------------------------------------
help_analytics() {
  echo "
  Syntax: ${0} analytics -a {domcreate|explode|appconfig|wlsdeploy|
                             oimintegrate|domconfig} 
                         [-P {pack|unpack}]
                         [-T {single|cluster}]
                         [-w wlst-prop-file] 
                         [-u user] [-p pwd] 

    ${0} analytics -a domcreate -T {single|cluster}
    ${0} analytics -a keyfile -u user -p pwd [-w wlst-prop-file]
    ${0} analytics -a domconfig
    ${0} analytics -a rdeploy -P pack
    ${0} analytics -a rdeploy -P unpack
    ${0} analytics -a explode
    ${0} analytics -a appconfig -T {single|cluster}
    ${0} analytics -a oimintegrate
    ${0} analytics -a wlsdeploy

  Changes, fixes and user modifications for installed Identity Analytics
  instance

  Parameter:
    -a   action to perform
         domcreate    create weblogic domain, managed servers and nodemanager
         keyfile      create nodemanager keyfiles for user
         domconfig    configure wls domain env (setCustDomainEnv.sh)
         rdeploy      deploy additional WebLogic node 
         explode      extract OIA webapp archive
         appconfig    adapt OIA webapp config files
         oimintegrate integrate OIM and OIA
         wlsdeploy    deploy OIA application to weblogic domain

    -P   pack mode
         pack         pack the OIA domain on current host
         unpack       unpack the OIA domain jar file (new host)
    -T   topology
         single       single host topology
         cluster      cluster topology (multihost)
    -w   path         path of WLST properties file to use
                      default: ~/.env/analytics.prop

  "
}
# ---------------------------------------------------
help_directory() {
  echo "
  Syntax: ${0} directory -a {postinstall|harden} [-H host]
    ${0} directory -a postinstall
    ${0} directory -a harden
    ${0} directory -a movelogs -H host

  Changes, fixes and user modifications for installed OUD instance

  Parameter:
    -a   action to perform
         postinstall  fix OUD Global ACIs
         harden       Harden OUD connection settings (e.g. turn on TLS)
         movelogs     Move OUD logfiles to common location

  "
}
# ---------------------------------------------------
help_webtier() {
  echo "
  Syntax: ${0} webtier -a {postinstall|config|movelogs}
    ${0} webtier -a postinstall
    ${0} webtier -a config
    ${0} webtier -a movelogs

  Changes, fixes and user modifications for installed WebTier instance

  Parameter:
    -a   action to perform
         postinstall  Fix Webgate installation bug (oblog_config.xml)
         config       remove the shipped httpd config and install an
                      improved and modular version
         movelogs     move Webtier logfiles to common location
  "
} 
# ---------------------------------------------------
help_remove() {
  echo "
  Syntax: ${0} remove -t {identity,analytics,lcm,env,all}

  Remove parts or all of the IAM installation.

  Attention: database schemas are remove by command 'rcu'

  Parameter:
    -t target         product to remove (instances and binaries)
  "
} 

