#!/bin/bash -x

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

export iam_hostenv iam_top iam_log DO_IDM DO_ACC DO_WEB DO_OUD DO_BIP

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

eval $(grep INSTALL_IDENTITY        ${cfg_prov})
eval $(grep INSTALL_ACCESS          ${cfg_prov})
eval $(grep INSTALL_WEBTIER         ${cfg_prov})
eval $(grep INSTALL_SUITE_COMPLETE  ${cfg_prov})
INSTALL_DIRECTORY=${INSTALL_SUITE_COMPLETE}

set -o nounset errexit

# copy user env --------------------------------------
#
if ! [ -a ${iam_hostenv}/env ] ; then
  ${DEPLOYER}/libexec/init-userenv.sh
fi

. ${HOSTENV}/env/common.env

# additional oud files
if [ "${DO_OUD}" == "yes" -o "${DO_OUD}" == "YES" ] ; then
  (
    . ${HOSTENV}/env/dir.env
    echo -n ${oudPwd} > ${HOSTENV}/.creds/oudadmin
    cp -b ${HOSTENV}/env/tools.properties ${INST_HOME}/config/
  )
fi

# acStdLib for wlst -------------------------------
#
if [ "${DO_ACC}" == "yes" -o "${DO_ACC}" == "YES" ] ; then
  cp -f ${DEPLOYER}/lib/wlst/common/* ${iam_top}/products/access/wlserver_10.3/common/wlst
fi
if [ "${DO_IDM}" == "yes" -o "${DO_IDM}" == "YES" ] ; then
  cp -f ${DEPLOYER}/lib/wlst/common/* ${iam_top}/products/identity/wlserver_10.3/common/wlst
fi

# install jdk7 --------------------
#
for d in access identity dir web ; do
  dest=${INSTALL_APPHOME_DIR}/products/${d}
  [ -a ${dest} ] || continue
  mkdir -p ${dest}/jdk
  tar xzf ${s_jdk} -C ${dest}/jdk
  ln -s ${dest}/jdk/${jdkname} ${dest}/jdk/current
  jdk_patch_config ${dest}/jdk/${jdkname}
done

# user key files access domain ----------------------------------
#
if [ "${DO_ACC}" == "yes" -o "${DO_ACC}" == "YES" ] ; then
  . ${HOSTENV}/env/acc.env

  ${ORACLE_HOME}/bin/psa \
    -response ${DEPLOYER}/user-config/iam/psa_access.rsp \
    -logLevel WARNING \
    -logDir /tmp

  if ! [ -a ${HOSTENV}/.creds/nm.key ] ; then
    ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOSTENV}/env/access.prop <<-EOF
nmConnect(username='${nmUser}', password='${nmPwd}',host=hostname,
 port=nmPort, domainName=domName, domainDir=domDir, nmType='ssl')
storeUserConfig(userConfigFile=nmUC,userKeyFile=nmUK,nm='true')
y
exit()
EOF
  fi

  if ! [ -a ${HOSTENV}/.creds/${IDMPROV_ACCESS_DOMAIN}.key ] ; then
    ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOSTENV}/env/access.prop <<-EOF
connect(username="${domaUser}", password="${domaPwd}", url=domUrl)
storeUserConfig(userConfigFile=domUC,userKeyFile=domUK,nm="false")
y
exit()
EOF
  fi

  ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOSTENV}/env/access.prop \
    ${DEPLOYER}/lib/access/oam-config.py
fi

# identity domain ---------------------------------------------
#
if [ "${DO_IDM}" == "yes" -o "${DO_IDM}" == "YES" ] ; then
  . ${HOSTENV}/env/idm.env

  ${ORACLE_HOME}/bin/psa \
    -response ${DEPLOYER}/user-config/iam/psa_identity.rsp \
    -logLevel WARNING \
    -logDir /tmp

  if ! [ -a ${HOSTENV}/.creds/nm.key ] ; then
    ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOSTENV}/env/identity.prop <<-EOF
nmConnect(username='${nmUser}', password='${nmPwd}',host=hostname,
 port=nmPort, domainName=domName, domainDir=domDir, nmType='ssl')
storeUserConfig(userConfigFile=nmUC,userKeyFile=nmUK,nm='true')
y
exit()
EOF
  fi

  if ! [ -a ${HOSTENV}/.creds/${IDMPROV_IDENTITY_DOMAIN}.key ] ; then
    ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOSTENV}/env/identity.prop <<-EOF
connect(username="${domiUser}", password="${domiPwd}", url=domUrl)
storeUserConfig(userConfigFile=domUC,userKeyFile=domUK,nm="false")
y
exit()
EOF
  fi

  ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOSTENV}/env/identity.prop \
    ${DEPLOYER}/lib/identity/idm-config.py
fi

# copy rc.d files ----------------------------------------------

# pspatching postinstalls


if [ "${DO_OUD}" == "yes" -o "${DO_OUD}" == "YES" ] ; then
  . ${HOSTENV}/env/dir.env
  patch_oud_post_inst
  apply_oud_tls_settings
fi

# postinstalls done

${HOSTENV}/bin/stop-identity
${HOSTENV}/bin/stop-access
${HOSTENV}/bin/stop-dir
${HOSTENV}/bin/stop-webtier
${HOSTENV}/bin/stop-nodemanager

# log file setting
#
if [ ! -a ${iam_log}/nodemanager ] ; then
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
. ${HOSTENV}/env/acc.env
${DEPLOYER}/libexec/patch-wls-domain.sh ${DEPLOYER}/lib/access
. ${HOSTENV}/env/idm.env
${DEPLOYER}/libexec/patch-wls-domain.sh ${DEPLOYER}/lib/identity

_webg=${iam_top}/products/web/webgate/webgate/ohs/config

if [ -a ${_webg}/oblog_config_wg.xml -a ! -a ${_webg}/oblog_config.xml ] ; then
  cp ${_webg}/oblog_config_wg.xml ${_webg}/oblog_config.xml
fi

exit 0

# web config
#
_webd1=/opt/local/fmw/instances/ohs1/config/OHS/ohs1
_webd2=/opt/local/instances/ohs1/config/OHS/ohs1
_webd3=/opt/local/fmw/instances/ohs2/config/OHS/ohs2
_webd4=/opt/local/instances/ohs2/config/OHS/ohs2
[ -a ${_webd1} ] && webd=${_webd1}
[ -a ${_webd2} ] && webd=${_webd2}
[ -a ${_webd3} ] && webd=${_webd3}
[ -a ${_webd4} ] && webd=${_webd4}

if [ -n ${webd} ] ; then
  generate_httpd_config ${webd} $(hostname -f)
fi

# bundle patches

# ${HOME}/bin/start-all


exit 0

