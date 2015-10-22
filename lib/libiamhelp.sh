# help text for iam tool
#

iamhelp() {
  echo "
  Syntax: ${0} command [flags]
  
  Commands:   parameter -h for command help
    help      show this help
    ssh-key   generate and deploy ssh keypair
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

    TODO: 
          movelogs:
              - change oud and ohs instance names 
                from static to dynamic
"
  echo
  exit $ERROR_SYNTAX_ERROR
}
# ---------------------------------------------------
help_ssh_key() {
  echo "
  Syntax: ${0} ssh-keys -a {generate|deploy|add} [-t key_dest] [-H host]

    ${0} ssh-keys -a generate -t key_dest
    ${0} ssh-keys -a deploy -s source_dir -H hostname
    ${0} ssh-keys -a add -H hostname

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
# ---------------------------------------------------
help_prov() {
  echo "
  Syntax: ${0} prov

  Execute all LCM provisioning steps on all hosts

  "
  exit $ERROR_SYNTAX_ERROR
}
# ---------------------------------------------------
help_userenv() {
  echo "
  Syntax: ${0} userenv -a {env|profile} [-H host]
    ${0} userenv -a env
    ${0} userenv -a profile -H host

  Create user environment (bin,etc,lib,cred)
  Parameter:
    -a   action to perform
         env:         create all files
         profile:     modify bash user profile
    -H   hostname execute on remote host

  "
  exit $ERROR_SYNTAX_ERROR
}
# ---------------------------------------------------
help_jdk() {
  echo "
  Syntax: ${0} jdk -H host -O oracle_home
  Syntax Example: ${0} jdk -H iam.agoracon.at -O identity -P 1

  Upgrade existing JDK (from JDK6 to JDK7)

  Parameter:
    -H host       hostname: execute on host
    -O home       oracle_home to upgrade:
                    identity | accesss
    -P part       part 1 or 2
                    1     can be done with original processes up
                    2     shall be done with no processes running
                    
   Before exection:
     oracle_home/jdk6         shipped JDK

   After execution:
     oracle_home/jdk/current  link to new JDK
     oracle_home/jdk/jdkXXXX  new JDK
     oracle_home/jdk/jdk6     original JDK
     oracle_home/jdk6         link to new JDK

  "
  exit $ERROR_SYNTAX_ERROR

}
# ---------------------------------------------------
help_rcd() {
  echo "
  Syntax: ${0} rcd -H host -t target

  Deploy rc.d runlevel scripts 

  Parameter:
    -H   hostname: execute on host
    -t   target component:
         nodemanger
         identity
         access
         webtier
         oud

  "
  exit $ERROR_SYNTAX_ERROR

}
# ---------------------------------------------------
help_weblogic() {
  echo "
  Syntax: ${0} weblogic -a { jdk7fix | wlstlibs } -t target_path [-H host] 
    ${0} weblogic -a jdk7fix -t product_name -H host
    ${0} weblogic -a wlstlibs -t product_name -H host

  Modify or extend WebLogic installation

  Parameter:
    -a   action to perform
         jdk7fix     fix java parameters in commEnv.sh
         wlstlibs    add libs to wlst common directory
    -H   hostname: execute on remote host
    -t   target wlserver path
         target_name: (identity|access)

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

    -H   hostname     execute on remote host
    -t   target       wls server path
    -u   user         user to create keyfile for
    -p   password     password of user
    -w   path         path of WLST properties file to use
                      default: ~/.env/identity.prop
    -n                keyfile: create nodemanager keyfiles

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

    -H   hostname: execute on remote host
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
    -t   target wlserver path

  "
  exit $ERROR_SYNTAX_ERROR
} 
# ---------------------------------------------------
