#!/bin/sh

   nmUser=admin
    nmPwd=Montag11
 domaUser=weblogic_idm
  domaPwd=Montag11
 domiUser=weblogic_idm
  domiPwd=Montag11
   oudPwd=Montag11

if [ -z ${DEPLOYER} ] ; then
  error "ERROR: Environment variable DEPLOYER is not set"
  exit 80
fi

deployer=${DEPLOYER}
#. ${DEPLOYER}/user-config/env/env.sh
. ${DEPLOYER}/user-config/iam.config
. ${DEPLOYER}/lib/libcommon2.sh
. ${DEPLOYER}/lib/libweb.sh
. ${DEPLOYER}/lib/liboud.sh

cfg_prov=${DEPLOYER}/user-config/iam/provisioning.rsp
# INSTALL_APPHOME_DIR=/opt/fmw
eval $(grep INSTALL_APPHOME_DIR     ${cfg_prov})
# INSTALL_LOCALCONFIG_DIR=/opt/local
eval $(grep INSTALL_LOCALCONFIG_DIR ${cfg_prov})
# IDMPROV_ACCESS_DOMAIN=access_dev
eval $(grep IDMPROV_ACCESS_DOMAIN   ${cfg_prov})
# IDMPROV_IDENTITY_DOMAIN=identity_dev
eval $(grep IDMPROV_IDENTITY_DOMAIN ${cfg_prov})
# OHS_INSTANCENAME=ohs1
eval $(grep OHS_INSTANCENAME        ${cfg_prov})

set -o errexit nounset
set -x

# copy user env --------------------------------------
#
if ! [ -a ${HOME}/.env ] ; then
  ${DEPLOYER}/libexec/init-userenv.sh
fi

. ${HOME}/.env/common.env

# additional oud files
(
  . ${HOME}/.env/dir.sh
  echo -n ${oudPwd} > ${HOME}/.creds/oudadmin
  cp -b ${deployer}/user-config/hostenv/tools.properties ${INST_HOME}/config/
)

# user key files access domain ----------------------------------
#
. ${HOME}/.env/acc.env

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

# identity domain ---------------------------------------------
#
. ${HOME}/.env/idm.env

${ORACLE_HOME}/bin/psa \
    -response ${DEPLOYER}/user-config/iam/psa_identity.rsp \
    -logLevel WARNING \
    -logDir /tmp

if [ ! -a ~/.creds/nm.key ] ; then
  ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOME}/.env/identity.prop <<-EOF
nmConnect(username='${nmUser}', password='${nmPwd}',host=hostname,
 port=nmPort, domainName=domName, domainDir=domDir, nmType='ssl')
storeUserConfig(userConfigFile=nmUC,userKeyFile=nmUK,nm='true')
y
exit()
EOF
fi

${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOME}/.env/identity.prop <<-EOF
connect(username="${domiUser}", password="${domiPwd}", url=domUrl)
storeUserConfig(userConfigFile=domUC,userKeyFile=domUK,nm="false")
y
exit()
EOF

# copy rc.d files ----------------------------------------------

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

# log file setting
#
if [ ! -a /var/log/fmw/nodemanager ] ; then
  ${DEPLOYER}/libexec/init-logs.sh
fi

# install jdk7 --------------------
#

for d in access identity dir web ; do
  dest=${INSTALL_APPHOME_DIR}/products/${d}
  mkdir -p ${dest}/jdk
  tar xzf ${s_jdk} -C ${dest}/jdk
  local jdkname=$(ls ${dest}/jdk)
  mv ${dest}/jdk6 ${dest}/jdk/
  ln -s ${dest}/jdk/${jdkname} ${dest}/jdk/current
  ln -s ${dest}/jdk/${jdkname} ${dest}/jdk6
done

# patch domains and wl_home for jdk7
#
. ~/.env/acc.env
${DEPLOYER}/libexec/patch-wls-domain.sh ${DEPLOYER}/lib/access
. ~/.env/idm.env
${DEPLOYER}/libexec/patch-wls-domain.sh ${DEPLOYER}/lib/identity

local _webg=/opt/fmw/products/web/webgate/webgate/ohs/config

if [ -a ${_webg}/oblog_config_wg.xml -a ! -a ${_webg}/oblog_config.xml ] ; then
  cp ${_webg}/oblog_config_wg.xml ${_webg}/oblog_config.xml
fi

# web config
#

generate_httpd_config /tmp iam0.dwpbank.net

# bundle patches

${HOME}/bin/start-all


exit 0

