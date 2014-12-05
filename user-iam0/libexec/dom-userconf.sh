#!/bin/sh

   nmUser=admin
    nmPwd=Montag11
 domaUser=weblogic_idm
  domaPwd=Montag11
 domiUser=weblogic_idm
  domiPwd=Montag11

set -o errexit nounset

. /vagrant/user-config/env/env.sh

set -x

# copy user env
mkdir -p ${HOME}/{.env,lib,bin,.creds}
cp ${deployer}/user-config/hostenv/env/* ~/.env
cp ${deployer}/user-config/hostenv/bin/* ~/bin
cp ${deployer}/user-config/hostenv/lib/* ~/lib

echo -e '\n[ -a ${HOME}/.env/common.sh ] && . ${HOME}/.env/common.sh\n' >> ${HOME}/.bash_profile

. ${HOME}/.env/common.sh

# oud env file  --------------
#

# oud
[ -a ${HOME}/.env/dir.sh ] && . ${HOME}/.env/dir.sh
[ -a ${HOME}/.env/oud.sh ] && . ${HOME}/.env/oud.sh

echo -n Montag11 > ${HOME}/.creds/oudadmin
cp -b ${deployer}/user-config/hostenv/tools.properties ${INST_HOME}/config/

# user key files access domain --
#
[ -a ${HOME}/.env/acc.sh ] && . ${HOME}/.env/acc.sh
[ -a ${HOME}/.env/oam.sh ] && . ${HOME}/.env/oam.sh

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

# identity domain ------------
#
[ -a ${HOME}/.env/idm.sh ] && . ${HOME}/.env/idm.sh
[ -a ${HOME}/.env/oim.sh ] && . ${HOME}/.env/oim.sh

# ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOME}/.env/identity.prop <<-EOF
# nmConnect(username='${nmUser}', password='${nmPwd}',host=hostname,
#  port=nmPort, domainName=domName, domainDir=domDir, nmType='ssl')
# storeUserConfig(userConfigFile=nmUC,userKeyFile=nmUK,nm='true')
# y
# exit()
# EOF


${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOME}/.env/identity.prop <<-EOF
connect(username="${domiUser}", password="${domiPwd}", url=domUrl)
storeUserConfig(userConfigFile=domUC,userKeyFile=domUK,nm="false")
y
exit()
EOF

# copy rc.d files

# service must be down when calling
#${deployer}/libexec/init-logs.sh
set +x

# pspatching postinstalls

# bundle patches



