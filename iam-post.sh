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
. ${DEPLOYER}/user-config/iam.config
. ${DEPLOYER}/lib/libcommon2.sh
. ${DEPLOYER}/lib/libweb.sh
. ${DEPLOYER}/lib/liboud.sh
. ${DEPLOYER}/lib/libjdk.sh

cfg_prov=${DEPLOYER}/user-config/iam/provisioning.rsp
# INSTALL_APPHOME_DIR=/opt/fmw
eval $(grep INSTALL_APPHOME_DIR     ${cfg_prov}) ; export INSTALL_APPHOME_DIR
# INSTALL_LOCALCONFIG_DIR=/opt/local
eval $(grep INSTALL_LOCALCONFIG_DIR ${cfg_prov}) ; export INSTALL_LOCALCONFIG_DIR
# IDMPROV_ACCESS_DOMAIN=access_dev
eval $(grep IDMPROV_ACCESS_DOMAIN   ${cfg_prov}) ; export IDMPROV_ACCESS_DOMAIN
# IDMPROV_IDENTITY_DOMAIN=identity_dev
eval $(grep IDMPROV_IDENTITY_DOMAIN ${cfg_prov}) ; export IDMPROV_IDENTITY_DOMAIN
# OHS_INSTANCENAME=ohs1
eval $(grep OHS_INSTANCENAME        ${cfg_prov}) ; export OHS_INSTANCENAME

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
  . ${HOME}/.env/dir.env
  echo -n ${oudPwd} > ${HOME}/.creds/oudadmin
  cp -b ${HOME}/.env/tools.properties ${INST_HOME}/config/
)

# install jdk7 --------------------
#
for d in access identity dir web ; do
  dest=${INSTALL_APPHOME_DIR}/products/${d}
  [ -a ${dest} ] && continue
  mkdir -p ${dest}/jdk
  tar xzf ${s_jdk} -C ${dest}/jdk
  ln -s ${dest}/jdk/${jdkname} ${dest}/jdk/current
  jdk_patch_config ${dest}/jdk/${jdkname}
done

# user key files access domain ----------------------------------
#
. ${HOME}/.env/acc.env

${ORACLE_HOME}/bin/psa \
    -response ${DEPLOYER}/user-config/iam/psa_access.rsp \
    -logLevel WARNING \
    -logDir /tmp

if ! [ -a ${HOME}/.creds/nm.key ] ; then
  ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOME}/.env/access.prop <<-EOF
nmConnect(username='${nmUser}', password='${nmPwd}',host=hostname,
 port=nmPort, domainName=domName, domainDir=domDir, nmType='ssl')
storeUserConfig(userConfigFile=nmUC,userKeyFile=nmUK,nm='true')
y
exit()
EOF
fi

if ! [ -a ${HOME}/.creds/${IDMPROV_ACCESS_DOMAIN}.key ] ; then
  ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOME}/.env/access.prop <<-EOF
connect(username="${domaUser}", password="${domaPwd}", url=domUrl)
storeUserConfig(userConfigFile=domUC,userKeyFile=domUK,nm="false")
y
exit()
EOF
fi

# identity domain ---------------------------------------------
#
. ${HOME}/.env/idm.env

${ORACLE_HOME}/bin/psa \
    -response ${DEPLOYER}/user-config/iam/psa_identity.rsp \
    -logLevel WARNING \
    -logDir /tmp

if ! [ -a ~/.creds/nm.key ] ; then
  ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOME}/.env/identity.prop <<-EOF
nmConnect(username='${nmUser}', password='${nmPwd}',host=hostname,
 port=nmPort, domainName=domName, domainDir=domDir, nmType='ssl')
storeUserConfig(userConfigFile=nmUC,userKeyFile=nmUK,nm='true')
y
exit()
EOF
fi

if ! [ -a ${HOME}/.creds/${IDMPROV_IDENTITY_DOMAIN}.key ] ; then
  ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOME}/.env/identity.prop <<-EOF
connect(username="${domiUser}", password="${domiPwd}", url=domUrl)
storeUserConfig(userConfigFile=domUC,userKeyFile=domUK,nm="false")
y
exit()
EOF
fi

# copy rc.d files ----------------------------------------------

# pspatching postinstalls

. ~/.env/dir.env
patch_oud_post_inst
apply_oud_tls_settings

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
  [ -h ${dest}/jdk6 ] && continue
  mv ${dest}/jdk6 ${dest}/jdk/
  ln -s ${dest}/jdk/${jdkname} ${dest}/jdk6
done

# patch domains and wl_home for jdk7
#
. ~/.env/acc.env
${DEPLOYER}/libexec/patch-wls-domain.sh ${DEPLOYER}/lib/access
. ~/.env/idm.env
${DEPLOYER}/libexec/patch-wls-domain.sh ${DEPLOYER}/lib/identity

_webg=/opt/fmw/products/web/webgate/webgate/ohs/config

if [ -a ${_webg}/oblog_config_wg.xml -a ! -a ${_webg}/oblog_config.xml ] ; then
  cp ${_webg}/oblog_config_wg.xml ${_webg}/oblog_config.xml
fi

# web config
#
generate_httpd_config /tmp $(hostname -f)

# bundle patches

# ${HOME}/bin/start-all


exit 0

