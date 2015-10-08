# help text for iam tool
#

help() {
  echo <<EOS
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
EOS
  echo
}

# ---------------------------------------------------
help_orainv() {
  echo <<EOS
  Syntax: ${0} orainv -H host

  Create Oracle Inventory Pointer file on specified host

  Configuration:
    pointer location:    ${iam_orainv_ptr}
    inventory location:  ${iam_orainv}
    install group:       ${iam_orainv_grp}

EOS
}
# ---------------------------------------------------
help_lcm() {
  echo <<EOS
  Syntax: ${0} lcm

  Install LCM (Life Cycle Manager)

  Configuration:
    LCM Binaries:        ${iam_lcm}
    LCM instance config: ${iam_lcmhome}

EOS
}
# ---------------------------------------------------
help_prov() {
  echo <<EOS
  Syntax: ${0} prov

  Execute all LCM provisioning steps on all hosts

EOS
}
# ---------------------------------------------------
help_userenv() {
  echo <<EOS
  Syntax: ${0} userenv -a {env|profile} [-H host]

  Create user environment (bin,etc,lib,cred)
  Parameter:
    -a   action to perform
         env:     create all files
         profile: modify bash user profile
    -H   hostname: execute on remote host

EOS
}
# ---------------------------------------------------
help_keyfile() {
  echo <<EOS
  Syntax: ${0} keyfile -t {nodemanger|domain} [-H host] [-D domain]
    ${0} keyfile -t nodemanager -H host
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

EOS
}
# ---------------------------------------------------
help_jdk() {
  echo <<EOS
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

EOS
}
# ---------------------------------------------------
help_rcd() {
  echo <<EOS
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

EOS
}
# ---------------------------------------------------
help_weblogic() {
  echo <<EOS
  Syntax: ${0} weblogic -a { jdk7fix | wlstlibs } -t target_path [-H host] 

  Modify or extend WebLogic installation

  Parameter:
    -a   action to perform
         jdk7fix     fix java parameters in commEnv.sh
         wlstlibs    add libs to wlst common directory
    -H   hostname: execute on remote host
    -t   target wlserver path

EOS
}
# ---------------------------------------------------
help_identity() {
  echo <<EOS
  Syntax: ${0} identity -a { jdk7fix | psa | postinstall | movelogs } -t target_path [-H host] 
    ${0} identity -a jdk7fix -t domain_home -H host
    ${0} identity -a psa
    ${0} identity -a postinstall  # TODO: what to to do?
    ${0} identity -a movelogs -t domain_home

  Changes, fixes and user modifications for installed Idenity Manager instance

  Parameter:
    -a   action to perform
         ...
    -H   hostname: execute on remote host
    -t   target wlserver path

EOS
}
# ---------------------------------------------------
help_access() {
  echo <<EOS
  Syntax: ${0} access -a { jdk7fix | psa | postinstall | movelogs } -t target_path [-H host] 
    ${0} access -a jdk7fix -t domain_home -H host
    ${0} access -a psa
    ${0} access -a postinstall  # TODO: what to to do?
    ${0} access -a movelogs -t domain_home

  Changes, fixes and user modifications for installed Access Manager instance

  Parameter:
    -a   action to perform
         ...
    -H   hostname: execute on remote host
    -t   target wlserver path

EOS
}
# ---------------------------------------------------
help_analytics() {
  echo <<EOS
  Syntax: ${0} analytics -a { ... } -t target_path [-H host] 
    ${0} analytics -a psa

  Changes, fixes and user modifications for installed Identity Analytics instance

  Parameter:
    -a   action to perform
         ...
    -H   hostname: execute on remote host
    -t   target wlserver path

EOS
}
# ---------------------------------------------------
help_webtier() {
  echo <<EOS
  Syntax: ${0} webtier -a { postinstall | movelogs } -t target_path [-H host] 
    ${0} webtier -a postinstall  # TODO: what to to do?
    ${0} webtier -a movelogs -t domain_home

  Changes, fixes and user modifications for installed WebTier instance

  Parameter:
    -a   action to perform
         ...
    -H   hostname: execute on remote host
    -t   target wlserver path

EOS
}
# ---------------------------------------------------
