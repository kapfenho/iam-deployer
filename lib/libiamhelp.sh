# help text for iam tool
#

iamhelp() {
  echo "
  Syntax: ${0} command [flags]
 
  Setup IAM environments. Run individual actions or create workflow file 
  from template, modify and run it.

  Commands:   parameter -h for command help

    create    create workflow file from template
    provision run workflow file
    ssh-key   generate and deploy ssh keypair
    rcu       create database schemas with RCU
    orainv    create central oracle inventory pointer
    lcminst   install LCM
    lcmstep   execute LCM step
    userenv   create userenv on host
    jdk       upgrade existing jdk
    rcd       deploy runlevel scripts (root permissions with sudo necessary)
    weblogic  modify wlserver installation
    identity  modify identity domain (psa, jdk7fix, movelogs, postinstall)
    access    modify access domain   (psa, jdk7fix, movelogs, postinstall)
    analytics modify analytics domain
    webtier   modify webtier instance (movelogs, postinstall)
    remove    remove installation
    help      show this help

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
  Syntax: ${0} ssh-key -a {generate|deploy|add} [-t key_dest] [-H host]

    ${0} ssh-key -a generate -t key_dest
    ${0} ssh-key -a deploy [-s source_dir] [-H hostname]
    ${0} ssh-key -a add -H hostname

  Copy the common ssh keypair and authorized_keys file to the local 
  or specified host.

  Parameter:
    -a   action to perform
         generate     generate new ssh-key (rsa 4096)
         deploy       install (common) ssh-key on host
         add          add remote host to known_hosts on this machine
    -s   source_dir   default ${DEPLOYER}/lib/templates/hostenv/ssh
    -t   target_dir   default ~/.ssh
    -H   hostname     host which to add to known_hosts file

  "
}
# ---------------------------------------------------
help_orainv() {
  echo "
  Syntax: ${0} orainv -H host

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
         identity     create schema for Identity Manager
         access       create schema for Access Manager
         bip          create schema for BI Publisher

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
  Syntax: ${0} userenv -a {env|profile} [-H host]
    ${0} userenv -a env
    ${0} userenv -a profile [-H host]

  Create user environment (bin,etc,lib,cred)
  Parameter:
    -a   action to perform
         env          create all files
         profile      modify bash user profile
    -H   hostname execute on remote host

  "
}
# ---------------------------------------------------
help_jdk() {
  echo "
  Syntax: ${0} jdk -a {install|upgrade} -H host -O oracle_home [-P part]
    ${0} jdk -a install -H iam.agoracon.at -O analytics
    ${0} jdk -a upgrade -H iam.agoracon.at -O identity -P 1

  Upgrade existing JDK (from JDK6 to JDK7). Takes place in two steps.
  Extract new JDK with different path; then move/archive old JDK and 
  sym link original path to JDK7 (used in products).

  Parameter:
    -a  action to perform
        install     install JDK7
        upgrade     upgrade to JDK7
            
    -H  host        hostname: execute on host
    -O  home        oracle_home to install|upgrade:
                       identity | accesss | analytics
    -P  part        part 1 or 2
                       1     can be done with original processes up
                       2     shall be done with no processes running
                    
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
  Syntax: ${0} rcd -H host -t target

  Deploy rc.d runlevel scripts 

  Parameter:
    -H   host         execute on host
    -t   target       service to create runlevel script for:
                        {nodemanger|identity|access|webtier|oud}

  "
}
# ---------------------------------------------------
help_weblogic() {
  echo "
  Syntax: ${0} weblogic -a { install | jdk7fix | wlstlibs } -t target_path [-H host] 
    ${0} weblogic -a jdk7fix -t product_name -H host
    ${0} weblogic -a wlstlibs -t product_name -H host
    ${0} weblogic -a install -t product_name -H host

  Modify or extend WebLogic installation

  Parameter:
    -a   action to perform
         jdk7fix     fix java parameters in commEnv.sh
         wlstlibs    add libs to wlst common directory
         install  install weblogic software
    -H   hostname: execute on remote host
    -t   target wlserver path
         target_name: (identity|access|analytics)

  "
}
# ---------------------------------------------------
help_identity() {
  echo "
  Syntax: ${0} identity -a {jdk7fix|psa|keyfile|postinstall|movelogs}
                        [-t target_path] [-H host] [-w wlst-prop-file] [-n] 
                        [-u user] [-p pwd]

    ${0} identity -a jdk7fix -H host
    ${0} identity -a psa
    ${0} identity -a keyfile -u user -p pwd [-w wlst-prop-file] [-n]
    ${0} identity -a config
    ${0} identity -a postinstall
    ${0} identity -a movelogs -H host

  Changes, fixes and user modifications for installed Idenity Manager instance

  Parameter:
    -a   action to perform
         jdk7fix      fix java parameters in commEnv.sh
         psa          run Patch Set assitant for OIM
         keyfile      create domain keyfiles for user
         config       apply custom domain config
         postinstall  access domain postinstall configuration
         movelogs     move identity domain logfiles to common location

    -H   host         execute on remote host
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
                      [-t target_path] [-H host] [-w wlst-prop-file] [-n] 
                      [-u user] [-p pwd]


    ${0} access -a jdk7fix -H host
    ${0} access -a psa
    ${0} access -a keyfile -u user -p pwd [-w wlst-prop-file] [-n]
    ${0} access -a config
    ${0} access -a movelogs -H host

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
         
    -H   hostname     execute on remote host
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
  Syntax: ${0} analytics -a { domcreate | explode | appconfig | wlsdeploy
                            | oimintegrate | domconfig } 
                         [-P single | cluster ] [-H host] [-w wlst-prop-file] 
                         [-u user] [-p pwd]


    ${0} analytics -a domcreate -H host
    ${0} analytics -a keyfile -u user -p pwd [-w wlst-prop-file]
    ${0} analytics -a domconfig -H host
    ${0} analytics -a explode -H host
    ${0} analytics -a appconfig -P single -H host
    ${0} analytics -a oimintegrate -H host
    ${0} analytics -a wlsdeploy -H host

  Changes, fixes and user modifications for installed Identity Analytics
  instance

  Parameter:
    -a   action to perform
         domcreate    create weblogic domain, managed servers and nodemanager
         keyfile      create nodemanager keyfiles for user
         domconfig    configure wls domain # setDomainEnv.sh
         explode      unpack OOB Identity Analytics archive
         appconfig    patch OIA with prepared diff patch
         oimintegrate integrate OIM and OIA products
         wlsdeploy    deploy OIA application to weblogic domain

    -H   hostname: execute on remote host
    -P   patch instance
         single   patch for single instance
         cluster  patch for cluster
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
         postinstall  # fix OUD Global ACIs
         harden       # Harden OUD connection settings (e.g. turn on TLS)
         movelogs     # Move OUD logfiles to common location

  "
}
# ---------------------------------------------------
help_webtier() {
  echo "
  Syntax: ${0} webtier -a {postinstall|movelogs} -t target_path [-H host] 
    ${0} webtier -a postinstall
    ${0} webtier -a movelogs -H host

  Changes, fixes and user modifications for installed WebTier instance

  Parameter:
    -a   action to perform
         postinstall  # Fix Webgate installation bug (oblog_config.xml)
         movelogs     # Move Webtier logfiles to common location

    -H   hostname: execute on remote host
  "
} 
# ---------------------------------------------------
help_remove() {
  echo "
  Syntax: ${0} remove [-d] [-L] [-A] 

    ${0} remove [-L]
    ${0} remove [-L] -A

  Remove IAM installation. Options to include LCM and to clean multiple
  hosts.

  Parameter:
    -L   include LCM (default is no)
    -A   remove on all hosts (default is no)
  "
} 

