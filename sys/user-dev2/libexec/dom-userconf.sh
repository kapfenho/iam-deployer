#!/bin/sh

   nmUser=admin
    nmPwd=Montag11
 domaUser=weblogic_idm
  domaPwd=Montag11
 domiUser=weblogic_idm
  domiPwd=Montag11

set -o errexit nounset

mydir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${mydir}/../env/env.sh

set -x

# copy user env
mkdir -p ${HOME}/{.env,lib,bin,.creds}
cp ${deployer}/user-config/hostenv/env/* ~/.env
cp ${deployer}/user-config/hostenv/bin/* ~/bin
cp ${deployer}/user-config/hostenv/lib/* ~/lib

echo -e '\n[ -a ${HOME}/.env/common.env ] && . ${HOME}/.env/common.env\n' >> ${HOME}/.bash_profile


. ${HOME}/.env/common.env

# oud env file  --------------
#

# oud
[ -a ${HOME}/.env/dir.env ] && . ${HOME}/.env/dir.env
[ -a ${HOME}/.env/oud.env ] && . ${HOME}/.env/oud.env

echo -n Montag11 > ${HOME}/.creds/oudadmin
cp -b ${deployer}/user-config/hostenv/tools.properties ${INST_HOME}/config/

# user key files access domain --
#
[ -a ${HOME}/.env/acc.env ] && . ${HOME}/.env/acc.env
[ -a ${HOME}/.env/oam.env ] && . ${HOME}/.env/oam.env

# copy acStdLib
cp ${deployer}/lib/wlst/acStdLib.py ${WL_HOME}/common/wlst/

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

${WL_HOME}/common/bin/wlst.sh -loadProperties ${IDM_PROP} ${deployer}/lib/access/oam-config.py


# identity domain ------------
#
[ -a ${HOME}/.env/idm.env ] && . ${HOME}/.env/idm.env
[ -a ${HOME}/.env/oim.env ] && . ${HOME}/.env/oim.env

# copy acStdLib
cp ${deployer}/lib/wlst/acStdLib.py ${WL_HOME}/common/wlst/

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

${WL_HOME}/common/bin/wlst.sh -loadProperties ${IDM_PROP} ${deployer}/lib/identity/idm-config.py

# copy rc.d files

# service must be down when calling
#${deployer}/libexec/init-logs.sh
set +x

# pspatching postinstalls

# bundle patches



