#!/bin/sh

   nmUser=admin
    nmPwd=Montag11
 domaUser=weblogic
  domaPwd=Montag11
 domiUser=weblogic
  domiPwd=Montag11

set -o errexit nounset

. /opt/fmw/iam-deployer/user-config/env/env.sh

set -x

# copy user env
# mkdir -p ${HOME}/{.env,lib,bin,.creds}
# cp ${deployer}/user-config/hostenv/bin/* ~/bin
# cp ${deployer}/user-config/hostenv/lib/* ~/lib

# echo -e '\n[ -a ${HOME}/.env/common.sh ] && . ${HOME}/.env/common.sh' >> ${HOME}/.bash_profile

# . ${HOME}/.env/common.sh

case "$(hostname -s)" in
*oud*)
  # oud env file  ---------------------------------------------
  #
  mkdir -p ${HOME}/{.env,lib,bin,.creds}
  cp ${deployer}/user-config/hostenv/dir/bin/ ~/bin
  cp ${deployer}/user-config/hostenv/dir/lib/* ~/lib
  cp ${deployer}/user-config/hostenv/dir/env/* ~/.env/
  cp -b ${deployer}/user-config/hostenv/dir/bash_profile ~/.bash_profile

  cp -b ${HOME}/.env/tools.properties ${INST_HOME}/config/
  
  echo -n Montag11 > ${HOME}/.creds/oudadmin
  ;; 
*oam*)
  # user key files access domain --------------------------------
  #
  # cp ${deployer}/user-config/hostenv/oam/env/* ~/.env/

  ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOME}/.env/access.prop <<-EOF
nmConnect(username='${nmUser}', password='${nmPwd}',host=hostname,
 port=nmPort, domainName=domName, domainDir=domDir, nmType='ssl')
storeUserConfig(userConfigFile=nmUC,userKeyFile=nmUK,nm='true')
y
exit()
EOF
  
  
  ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOME}/.env/access.prop <<-EOF
connect(username="${domaUser}", password="${domaPwd}", url=domUrl)
storeUserConfig(userConfigFile=domUC,userKeyFile=domUK,nm="false")
y
exit()
EOF
  ;;
*oim*)
  # identity domain ------------
  #
  # cp ${deployer}/user-config/hostenv/oim/env/* ~/.env/

  ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOME}/.env/identity.prop <<-EOF
nmConnect(username='${nmUser}', password='${nmPwd}',host=hostname,
port=nmPort, domainName=domName, domainDir=locDir, nmType='ssl');
storeUserConfig(userConfigFile=nmUC,userKeyFile=nmUK,nm='true');
y
exit()
EOF
  
  
#   ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOME}/.env/identity.prop <<-EOF
# connect(username="${domiUser}", password="${domiPwd}", url=domUrl);
# storeUserConfig(userConfigFile=domUC,userKeyFile=domUK,nm="false");
# y
# exit()
# EOF
  ;;
esac


# service must be down when calling
#${deployer}/libexec/init-logs.sh
set +x

# pspatching postinstalls

# bundle patches



