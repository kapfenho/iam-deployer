#!/bin/bash

#  -----------------------------------------------------------------
#  post install steps
#  call without parameter
#
#   - environment settings
#   - start, stop scripts
#   - runlevel scripts
#   - move log files to log partitions
#   - weblogic domain config
#   - create keyfiles for domains
#   - jdk7 upgrade
#   - webgate fix
#   - webgate/pep config
#   - httpd server config, http routing
#   - ssl/tls config
#

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
. ${DEPLOYER}/lib/liblog.sh

# export parameters fmor iam.config
export iam_hostenv iam_top iam_log DO_IDM DO_ACC DO_WEB DO_OUD DO_BIP

#  ----------------------------------------------------------------------
#  get some parameters from LCM config
# 
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

# eval $(grep INSTALL_IDENTITY        ${cfg_prov})
# eval $(grep INSTALL_ACCESS          ${cfg_prov})
# eval $(grep INSTALL_WEBTIER         ${cfg_prov})
# eval $(grep INSTALL_SUITE_COMPLETE  ${cfg_prov})
# INSTALL_DIRECTORY=${INSTALL_SUITE_COMPLETE}

set -o nounset errexit

#  ----------------------------------------------------------------------
#  where are we? what is running here?
#  set flags for futher processing
# 
acchost="no" ; idmhost="no" ; oudhost="no" ; webhost="no"

if [ "${DO_ACC}" == "yes" -o "${DO_ACC}" == "YES" ] ; then
  if [ -a ${iam_top}/services/domains/${IDMPROV_ACCESS_DOMAIN} ] ; then
    acchost="yes"
    if ! pgrep -f ${IDMPROV_ACCESS_DOMAIN} >/dev/null ; then
      error "Access domain is not running, please start services"
      exit 80
    fi
  fi
fi
if [ "${DO_IDM}" == "yes" -o "${DO_IDM}" == "YES" ] ; then
  if [ -a ${iam_top}/services/domains/${IDMPROV_IDENTITY_DOMAIN} ] ; then
    idmhost="yes"
    if ! pgrep -f ${IDMPROV_IDENTITY_DOMAIN} >/dev/null ; then
      error "Identity domain is not running, please start services"
      exit 80
    fi
  fi
fi
if [ "${DO_OUD}" == "yes" -o "${DO_OUD}" == "YES" ] ; then
  if [ -a ${iam_top}/services/instances/oud1 ] ; then
    oudhost="yes"
    if ! pgrep -f oud >/dev/null ; then
      error "OUD is not running, please start service"
      exit 80
    fi
  fi
fi
if [ "${DO_WEB}" == "yes" -o "${DO_WEB}" == "YES" ] ; then
  if [ -a ${iam_top}/services/instances/ohs1 ] ; then
    webhost="yes"
    if ! pgrep -f ohs >/dev/null ; then
      error "Webtier is not running, please start service"
      exit 80
    fi
  fi
fi
export oudhost webhost idmhost acchost

log ""
log "Provisioning tasks on host $(hostname -f)"
log "-----------------------------------------------"
log "  Identity:    ${idmhost}"
log "  Access:      ${acchost}"
log "  Directory:   ${oudhost}"
log "  Webtier:     ${webhost}"
log ""

#  ----------------------------------------------------------------------
#  copy environment files and source common env
#
if ! [ -a ${iam_hostenv}/env ] ; then
  ${DEPLOYER}/libexec/init-userenv.sh
fi

. ${HOSTENV}/env/common.env

#  ----------------------------------------------------------------------
#  copy environment files for OUD
#
if [ "${oudhost}" == "yes" ] ; then
  (
    . ${HOSTENV}/env/dir.env
    echo -n ${oudPwd} > ${HOSTENV}/.creds/oudadmin
    cp -b ${HOSTENV}/env/tools.properties ${INST_HOME}/config/
  )
fi

#  ----------------------------------------------------------------------
#  deploy standard lib acStdLib for wlst
#
if [ "${acchost}" == "yes" ] ; then
  cp -f ${DEPLOYER}/lib/wlst/common/* ${iam_top}/products/access/wlserver_10.3/common/wlst
fi
if [ "${idmhost}" == "yes" ] ; then
  cp -f ${DEPLOYER}/lib/wlst/common/* ${iam_top}/products/identity/wlserver_10.3/common/wlst
fi

#  ----------------------------------------------------------------------
#  JDK7 upgrade - part 1
#
log "Upgrading to JDK7 - part 1"
for d in access identity dir web ; do
  dest=${INSTALL_APPHOME_DIR}/products/${d}
  # when oracle_home dir does not exists: skip
  [ -a ${dest} ] || continue
  # when new jdk already exists: skip
  if [ -a ${dest}/jdk/current ] ; then
    warning "Skipping - found JDK in ${dest}"
    continue
  fi
  log "upgrading JDK in product dir ${dest}"
  mkdir -p ${dest}/jdk
  tar xzf ${s_jdk} -C ${dest}/jdk
  log "Creating soft link..."
  ln -s ${dest}/jdk/${jdkname} ${dest}/jdk/current
  log "Patching JDK...."
  jdk_patch_config ${dest}/jdk/${jdkname}
  log "Finished JDK upgrade part 1 in ${dest}"
done

#  ----------------------------------------------------------------------
#  access domain
#
if [ "${acchost}" == "yes" ] ; then

  . ${HOSTENV}/env/acc.env

  log "Access Domain: running PSA (Patch Set Assistant) for OAM..."

  ${ORACLE_HOME}/bin/psa \
    -response ${DEPLOYER}/user-config/iam/psa_access.rsp \
    -logLevel WARNING \
    -logDir /tmp

  log "Access Domain: creating nodemanager keyfiles..."

  if ! [ -a ${HOSTENV}/.creds/nm.key ] ; then
    ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOSTENV}/env/access.prop <<-EOF
nmConnect(username='${nmUser}', password='${nmPwd}',host=hostname,
 port=nmPort, domainName=domName, domainDir=domDir, nmType='ssl')
storeUserConfig(userConfigFile=nmUC,userKeyFile=nmUK,nm='true')
y
exit()
EOF
  fi

  log "Access Domain: creating keyfiles for domain..."

  if ! [ -a ${HOSTENV}/.creds/${IDMPROV_ACCESS_DOMAIN}.key ] ; then
    ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOSTENV}/env/access.prop <<-EOF
connect(username="${domaUser}", password="${domaPwd}", url=domUrl)
storeUserConfig(userConfigFile=domUC,userKeyFile=domUK,nm="false")
y
exit()
EOF
  fi

  log "Access Domain: configuring access domain..."

  ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOSTENV}/env/access.prop \
    ${DEPLOYER}/lib/access/oam-config.py
  
  log "Access Domain: configuration steps done"
fi

#  ----------------------------------------------------------------------
#  identity domain
#
if [ "${idmhost}" == "yes" ] ; then
  . ${HOSTENV}/env/idm.env

  log "Identity Domain: Running PSA (Patch Set Assistant) for IDM..."

  ${ORACLE_HOME}/bin/psa \
    -response ${DEPLOYER}/user-config/iam/psa_identity.rsp \
    -logLevel WARNING \
    -logDir /tmp

  log "Identity Domain: creating nodemanager keyfiles..."

  if ! [ -a ${HOSTENV}/.creds/nm.key ] ; then
    ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOSTENV}/env/identity.prop <<-EOF
nmConnect(username='${nmUser}', password='${nmPwd}',host=hostname,
 port=nmPort, domainName=domName, domainDir=domDir, nmType='ssl')
storeUserConfig(userConfigFile=nmUC,userKeyFile=nmUK,nm='true')
y
exit()
EOF
  fi

  log "Identity Domain: creating keyfiles for domain..."

  if ! [ -a ${HOSTENV}/.creds/${IDMPROV_IDENTITY_DOMAIN}.key ] ; then
    ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOSTENV}/env/identity.prop <<-EOF
connect(username="${domiUser}", password="${domiPwd}", url=domUrl)
storeUserConfig(userConfigFile=domUC,userKeyFile=domUK,nm="false")
y
exit()
EOF
  fi

  log "Identity Domain: configuring domain..."

  ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOSTENV}/env/identity.prop \
    ${DEPLOYER}/lib/identity/idm-config.py
  log "Identity Domain: configuration steps done."
fi

# ----------------------------------------------------------------------
# TODO: install runlevel scripts
#
warning "TODO: install runlevel scripts"


# ----------------------------------------------------------------------
#  OUD postinstalls, patching
#
if [ "${oudhost}" == "yes" ] ; then
  log "Post install steps for OUD..."
  . ${HOSTENV}/env/dir.env
  patch_oud_post_inst
  log "Hardening OUD..."
  apply_oud_tls_settings
  log "Hardening done"
fi

# ----------------------------------------------------------------------
# postinstalls done - restarting...
#
log "Stopping all services now..."

[ "${idmhost}" == "yes" ] && ${HOSTENV}/bin/stop-identity
[ "${acchost}" == "yes" ] && ${HOSTENV}/bin/stop-access
[ "${oudhost}" == "yes" ] && ${HOSTENV}/bin/stop-dir
[ "${webhost}" == "yes" ] && ${HOSTENV}/bin/stop-webtier
[ "${idmhost}" == "yes" -o "${acchost}" == "yes" ] && ${HOSTENV}/bin/stop-nodemanager

log "Services stopped"

# ----------------------------------------------------------------------
# log file setting 
#
log "Log files: check for open move tasks..."
move_logs
log "Log files: done"

# ----------------------------------------------------------------------
# install jdk7
#
log "JDK7 upgrade part 2 - Search for JDK6 dirs to move..."
for d in access identity dir web ; do
  dest=${INSTALL_APPHOME_DIR}/products/${d}
  # skip if mw home doesnt exist
  [ -a ${dest} ] || continue
  # skip if already dóne
  [ -h ${dest}/jdk6 ] && continue
  log "We will move and replace JDK6 in ${dest}"
  mv ${dest}/jdk6 ${dest}/jdk/
  ln -s ${dest}/jdk/${jdkname} ${dest}/jdk6
  log "JDK6 moved - done"
done

# ----------------------------------------------------------------------
# patch domains and wl_home for jdk7
#
if [ "${acchost}" == "yes" ] ; then
  log "Applying patches for JDK7 upgrade to WebLogic and Access Domain..."
  . ${HOSTENV}/env/acc.env
  ${DEPLOYER}/libexec/patch-wls-domain.sh ${DEPLOYER}/lib/access
  log "Patches have been applied"
fi
if [ "${idmhost}" == "yes" ] ; then
  log "Applying patches for JDK7 upgrade to WebLogic and Idenity Domain..."
  . ${HOSTENV}/env/idm.env
  ${DEPLOYER}/libexec/patch-wls-domain.sh ${DEPLOYER}/lib/identity
  log "Patches have been applied"
fi

# ----------------------------------------------------------------------
# webgate
#
log "Webgate: fix installation bug"

_webg=${iam_top}/products/web/webgate/webgate/ohs/config

if [ -a ${_webg}/oblog_config_wg.xml -a ! -a ${_webg}/oblog_config.xml ] ; then
  cp ${_webg}/oblog_config_wg.xml ${_webg}/oblog_config.xml
fi

log "Webgate: done"

exit 0

# ----------------------------------------------------------------------
# httpd server, ohs, apache
#
log "HTTP Server: deploying configs..."

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

log "HTTP Server: done"

# ----------------------------------------------------------------------
# TODO: bundle patches
#

# ${HOME}/bin/start-all


exit 0

