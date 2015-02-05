#!/bin/sh


   nmUser=admin
    nmPwd=Montag11
 domaUser=weblogic_idm
  domaPwd=Montag11
 domiUser=weblogic_idm
  domiPwd=Montag11
   oudPwd=Montag11

# jdk7 extracted - or change...
srcjdk=/appexec/fmw/products/access/jdk
jdkname=jdk1.7.0_60

. ${DEPLOYER}/user-config/env/env.sh
. ${DEPLOYER}/lib/libweb.sh
. ${DEPLOYER}/lib/liboud.sh

# INSTALL_APPHOME_DIR=/opt/fmw
eval $(grep INSTALL_APPHOME_DIR     ${DEPLOYER}/user-config/iam/provisioning.rsp)
# INSTALL_LOCALCONFIG_DIR=/opt/local
eval $(grep INSTALL_LOCALCONFIG_DIR ${DEPLOYER}/user-config/iam/provisioning.rsp)
# IDMPROV_ACCESS_DOMAIN=access_dev
eval $(grep IDMPROV_ACCESS_DOMAIN   ${DEPLOYER}/user-config/iam/provisioning.rsp)
# IDMPROV_IDENTITY_DOMAIN=identity_dev
eval $(grep IDMPROV_IDENTITY_DOMAIN ${DEPLOYER}/user-config/iam/provisioning.rsp)

set -o errexit nounset

set -x

# copy user env
mkdir -p ${HOME}/{.env,lib,bin,.creds}
cp ${deployer}/user-config/hostenv/env/* ~/.env
cp ${deployer}/user-config/hostenv/bin/* ~/bin
cp ${deployer}/user-config/hostenv/lib/* ~/lib

cp /opt/fmw/products/web/webgate/webgate/ohs/config/oblog_config_wg.xml \
   /opt/fmw/products/web/webgate/webgate/ohs/config/oblog_config.xml

echo -e '\n[ -a ${HOME}/.env/common.sh ] && . ${HOME}/.env/common.sh\n' >> ${HOME}/.bash_profile

. ${HOME}/.env/common.sh

# oud env file  --------------
#

# oud
[ -a ${HOME}/.env/dir.sh ] && . ${HOME}/.env/dir.sh
[ -a ${HOME}/.env/oud.sh ] && . ${HOME}/.env/oud.sh

echo -n ${oudPwd} > ${HOME}/.creds/oudadmin
cp -b ${deployer}/user-config/hostenv/tools.properties ${INST_HOME}/config/

# user key files access domain --
#
[ -a ${HOME}/.env/acc.sh ] && . ${HOME}/.env/acc.sh
[ -a ${HOME}/.env/oam.sh ] && . ${HOME}/.env/oam.sh

${ORACLE_HOME}/bin/psa \
    -response ${DEPLOYER}/user-config/iam/psa_access.rsp \
    -logLevel WARNING \
    -logDir /tmp

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

${ORACLE_HOME}/bin/psa \
    -response ${DEPLOYER}/user-config/iam/psa_identity.rsp \
    -logLevel WARNING \
    -logDir /tmp

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

# last postinstall
patch_oud_post_inst
# postinstalls done

${HOME}/bin/stop-identity
${HOME}/bin/stop-access
${HOME}/bin/stop-dir
${HOME}/bin/stop-webtier
${HOME}/bin/stop-nodemanager


# install jdk7 --------------------
#
# srcjdk=/appexec/fmw/products/access/jdk
# jdkname=jdk1.7.0_60

for d in access identity dir web 
do
  dest=${INSTALL_APPHOME_DIR}/products/$d

  mkdir -p $dest/jdk
  mv $dest/jdk6 $dest/jdk/
  cp -Rp $srcjdk/$jdkname $dest/jdk/
  ln -s $dest/jdk/$jdkname $dest/jdk/current
  ln -s $dest/jdk/$jdkname $dest/jdk6
done

# --------------------------------------
# patch domains and wl_home for jdk7

set -o errexit nounset

deployer=${DEPLOYER}

if [ -z "${deployer}" ] 
then
  echo "ERROR: Environment variable DEPLOYER not set!"
  echo
  exit 77
fi
 
# access
#
(
source ${HOME}/.env/acc.env
set -x
if grep jdk6 ${DOMAIN_HOME}/bin/setDomainEnv.sh >/dev/null
then
  echo "Patching Access Domain"
  patch -b ${WL_HOME}/common/bin/commEnv.sh   <${deployer}/lib/access/wl_home/commEnv.sh.patch

  patch -b ${DOMAIN_HOME}/bin/setDomainEnv.sh <${deployer}/lib/access/domain/setDomainEnv.sh.patch
  cp ${deployer}/user-config/access/setCustDomainEnv.sh ${DOMAIN_HOME}/bin/

  patch -b ${WRK_HOME}/bin/setDomainEnv.sh    <${deployer}/lib/access/domain/setDomainEnv.sh.patch
  cp ${deployer}/user-config/access/setCustDomainEnv.sh ${WRK_HOME}/bin/
else
  echo "Access Domain already patched!"
fi
set +x
)
# TODO: 2nd domain dir

# identity
#
(
source ${HOME}/.env/idm.env
set -x
if grep jdk6 ${DOMAIN_HOME}/bin/setDomainEnv.sh >/dev/null
then
  echo "Patching Identity Domain"
  patch -b ${WL_HOME}/common/bin/commEnv.sh   <${deployer}/lib/identity/wl_home/commEnv.sh.patch

  patch -b ${ADMIN_HOME}/bin/setDomainEnv.sh  <${deployer}/lib/identity/domain/setDomainEnv.sh.patch
  cp ${deployer}/user-config/access/setCustDomainEnv.sh ${ADMIN_HOME}/bin/

  patch -b ${DOMAIN_HOME}/bin/setDomainEnv.sh <${deployer}/lib/identity/domain/setDomainEnv.sh.patch
  cp ${deployer}/user-config/access/setCustDomainEnv.sh ${DOMAIN_HOME}/bin/
else
  echo "Identity Domain already patched!"
fi
set +x
)
# TODO: 2nd domain dir

# ------------------------------------------------

# logs
move_logs_onehost

${HOME}/bin/start-all

# bundle patches


# web config
#

generate_httpd_config /tmp iam0.dwpbank.net

exit 0


