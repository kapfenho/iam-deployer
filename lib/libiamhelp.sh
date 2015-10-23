# help text for iam tool
#

iamhelp() {
  echo "
  Syntax: ${0} command [flags]
  
  Commands:   parameter -h for command help

    help      show this help
    ssh-key   generate and deploy ssh keypair
    rcu       create database schemas with RCU
    orainv    create central oracle inventory pointer
    lcm       install LCM
    prov      provision with LCM
    userenv   create userenv on host
    jdk       upgrade existing jdk
    rcd       deploy runlevel scripts (root permissions with sudo necessary)
    weblogic  modify wlserver installation
    identity  modify identity domain (psa, jdk7fix, movelogs, postinstall)
    access    modify access domain   (psa, jdk7fix, movelogs, postinstall)
    analytics modify analytics domain
    webtier   modify webtier instance (movelogs, postinstall)
    remove    remove installation

"
  echo
  exit $ERROR_SYNTAX_ERROR
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
  exit $ERROR_SYNTAX_ERROR
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
  exit $ERROR_SYNTAX_ERROR
}
# ---------------------------------------------------
help_lcm() {
  echo "
  Syntax: ${0} lcm

  Install LCM (Life Cycle Manager) software

  Configuration:
    LCM Binaries:        ${iam_lcm}
    LCM instance config: ${iam_lcmhome}

  "
  exit $ERROR_SYNTAX_ERROR
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
  exit $ERROR_SYNTAX_ERROR
}
# ---------------------------------------------------
help_prov() {
  echo "
  Syntax: ${0} prov -a step

  Execute an LCM provisioning step on all hosts in the defined order.
  
  Parameter:
    -a   step         provisioning step: {preverify|install|unblock|
                         preconfigure|configure|configure-secondary|
                         postconfigure|startup|validate}

  "
  exit $ERROR_SYNTAX_ERROR
}
# ---------------------------------------------------
help_userenv() {
  echo "
  Syntax: ${0} userenv -a {env|profile} [-H host]
    ${0} userenv -a env
    ${0} userenv -a profile [-H host]

  Create user environment (bin,etc,lib,cred)
  Parameter:
    -a   action to perform:
         env          create all files
         profile      modify bash user profile
    -H   hostname     execute on remote host

  "
  exit $ERROR_SYNTAX_ERROR
}
# ---------------------------------------------------
help_jdk() {
  echo "
  Syntax: ${0} jdk [-H host] -t product -P part
    ${0} jdk -H iam.agoracon.at -t identity -P 1

  Upgrade existing JDK (from JDK6 to JDK7). Takes place in two steps.
  Extract new JDK with different path; then move/archive old JDK and 
  sym link original path to JDK7 (used in products).

  Parameter:
    -H   host       execute on host
    -t   product    product with JDK to upgrade: {identity|access}
    -P   number     part to execute: {1|2}
                    1  can be done with original processes up
                    2  shall be done with no processes running
                    
  Before exection:
    ORACLE_HOME/jdk6         shipped JDK

  After execution:
    ORACLE_HOME/jdk/current  link to new JDK
    ORACLE_HOME/jdk/jdkXXXX  new JDK
    ORACLE_HOME/jdk/jdk6     original JDK
    ORACLE_HOME/jdk6         link to new JDK

  "
  exit $ERROR_SYNTAX_ERROR

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
  exit $ERROR_SYNTAX_ERROR

}
# ---------------------------------------------------
help_weblogic() {
  echo "
  Syntax: ${0} weblogic -a {jdk7fix|wlstlibs} -t product [-H host] 
    ${0} weblogic -a jdk7fix  -t product -H host
    ${0} weblogic -a wlstlibs -t product -H host

  Modify or extend WebLogic installation

  Parameter:
    -a   action       possible actions: {jdk7fix|wlstlibs}
                      jdk7fix     fix java parameters in commEnv.sh
                      wlstlibs    add libs to wlst common directory
    -H   host         execute on host
    -t   product      product name: {identity|access}

  "
  exit $ERROR_SYNTAX_ERROR
}
# ---------------------------------------------------
help_identity() {
  echo "
  Syntax: ${0} identity -a {jdk7fix|psa|keyfile|postinstall|movelogs}
                        [-t target_path] [-H host] 

    ${0} identity -a jdk7fix -t domain_home -H host
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
  exit $ERROR_SYNTAX_ERROR
}
# ---------------------------------------------------
help_access() {
  echo "
  Syntax: ${0} access -a {jdk7fix|psa|keyfile|movelogs}
                      [-t target_path] [-H host] 

    ${0} access -a jdk7fix -t domain_home -H host
    ${0} access -a psa
    ${0} access -a keyfile -u user -p pwd [-w wlst-prop-file]
    ${0} access -a config
    ${0} access -a movelogs -H host

  Changes, fixes and user modifications for installed Access Manager
  instance

  Parameter:
    -a   action to perform
         jdk7fix      fix java parameters in commEnv.sh
         psa          run Patch Set assitant for OAM
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
  exit $ERROR_SYNTAX_ERROR
}
# ---------------------------------------------------
help_analytics() {
  echo "
  Syntax: ${0} analytics -a { ... } -t target_path [-H host] 

  Changes, fixes and user modifications for installed Identity Analytics
  instance

  Parameter:
    -a   action to perform
         unpack       unpack OOB Identity Analytics archive
         patch        patch OIA with prepared diff patch
         domprov      install and configure weblogic domain for OIA
                      and deploy OIA application to weblogic domain

    -H   host         execute on remote host
    -t   target wlserver path

  "
  exit $ERROR_SYNTAX_ERROR
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
  exit $ERROR_SYNTAX_ERROR
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
  exit $ERROR_SYNTAX_ERROR
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
  exit $ERROR_SYNTAX_ERROR
} 

