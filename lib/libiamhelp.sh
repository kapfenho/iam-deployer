# help text for iam tool
#

iamhelp() {
  echo "
  Syntax: ${0} command [flags]
  
  Commands:   parameter -h for command help
    help      show this help
    orainv    create central oracle inventory pointer
    lcm       install LCM
    prov      provision with LCM
    userenv   create userenv on host
    keyfile   create weblogic access keyfiles
    jdk       upgrade existing jdk
    rcd       deploy runlevel scripts (root permissions with sudo necessary)
    weblogic  modify wlserver installation
    identity  modify identity domain # psa, jdk7fix, movelogs, postinstall
    access    modify access domain   # psa, jdk7fix, movelogs, postinstall
    analytics modify analytics domain
    webtier   modify webtier instance # movelogs, postinstall

    TODO: modify start-all and stop-all scripts ***

    TODO: 
          keyfile:
              - start corrent wlst instance for each domain!
          movelogs:
              - change oud and ohs instance names 
                from static to dynamic
"
  echo
  exit $ERROR_SYNTAX_ERROR
}

# ---------------------------------------------------
help_orainv() {
  echo "
  Syntax: ${0} orainv -H host

  Create Oracle Inventory Pointer file on specified host

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

  Install LCM (Life Cycle Manager)

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
         env:     create all files
         profile: modify bash user profile
    -H   hostname: execute on remote host

  "
  exit $ERROR_SYNTAX_ERROR
}
# ---------------------------------------------------
help_keyfile() {
  echo "
  Syntax: ${0} keyfile -t {nodemanger|domain} [-H host] [-D domain]
    ${0} keyfile -t nodemanager -H host -D domain_name
    ${0} keyfile -t domain -D domain_name

  Create access keyfiles

  Parameter:
    -t   target to operate on
         nodemanger: create keyfiles for access to nodemanager
         domain:     create keyfiles for access to domain
    -D   weblogic domain name
    -H   hostname: execute on remote host

  Configuration:
    Destination location
      ${iam_hostenv}/.cred/hostname.{key,user}
      ${iam_hostenv}/.cred/domain.{key,user}

  "
  exit $ERROR_SYNTAX_ERROR
}
# ---------------------------------------------------
help_jdk() {
  echo "
  Syntax: ${0} jdk -H host -O oracle_home

  Upgrade existing JDK (from JDK6 to JDK7)

  Parameter:
    -H   hostname: execute on host
    -O   oracle_home to upgrade

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
    ${0} weblogic -a jdk7fix -t domain_home -H host
    ${0} weblogic -a wlstlibs -H host

  Modify or extend WebLogic installation

  Parameter:
    -a   action to perform
         jdk7fix     fix java parameters in commEnv.sh
         wlstlibs    add libs to wlst common directory
    -H   hostname: execute on remote host
    -t   target wlserver path

  "
  exit $ERROR_SYNTAX_ERROR
}
# ---------------------------------------------------
help_identity() {
  echo "
  Syntax: ${0} identity -a { jdk7fix | psa | postinstall | movelogs } -t target_path [-H host] 
    ${0} identity -a jdk7fix -t domain_home -H host
    ${0} identity -a psa
    ${0} identity -a postinstall  # TODO: what to to do?
    ${0} access -a movelogs -t target_name -H host


  Changes, fixes and user modifications for installed Idenity Manager instance

  Parameter:
    -a   action to perform
         ...
    -H   hostname: execute on remote host
    -t   target wlserver path

  "
  exit $ERROR_SYNTAX_ERROR
}
# ---------------------------------------------------
help_access() {
  echo "
  Syntax: ${0} access -a { jdk7fix | psa | postinstall | movelogs } -t target_path [-H host] 
    ${0} access -a jdk7fix -t domain_home -H host
    ${0} access -a psa
    ${0} access -a postinstall  # TODO: what to to do?
    ${0} access -a movelogs -H host


  Changes, fixes and user modifications for installed Access Manager instance

  Parameter:
    -a   action to perform
         ...
    -H   hostname: execute on remote host
    -t   target wlserver path

  "
  exit $ERROR_SYNTAX_ERROR
}
# ---------------------------------------------------
help_analytics() {
  echo "
  Syntax: ${0} analytics -a { ... } -t target_path [-H host] 

  Changes, fixes and user modifications for installed Identity Analytics instance

  Parameter:
    -a   action to perform
         unpack     # unpack OOB Identity Analytics archive
         patch      # patch OIA with prepared diff patch
         domprov    # install and configure weblogic domain for OIA
                      and deploy OIA application to weblogic domain

    -H   hostname: execute on remote host
    -t   target wlserver path

  "
  exit $ERROR_SYNTAX_ERROR
}
# ---------------------------------------------------
help_directory() {
  echo "
  Syntax: ${0} directory -a { postinstall | harden } [-H host]
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
  Syntax: ${0} webtier -a { postinstall | movelogs } -t target_path [-H host] 
    ${0} webtier -a postinstall  # TODO: what to to do?
    ${0} webtier -a movelogs -t domain_home -H host

  Changes, fixes and user modifications for installed WebTier instance

  Parameter:
    -a   action to perform
         movelogs     # Move Webtier logfiles to common location
         ...
    -H   hostname: execute on remote host
    -t   target wlserver path

  "
  exit $ERROR_SYNTAX_ERROR
} 
# ---------------------------------------------------
