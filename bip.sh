#!/bin/sh

. ${DEPLOYER}/user-config/iam.config
. ${DEPLOYER}/lib/libcommon2.sh

set -o errexit nounset

# export JAVA_HOME=${s_runjdk}
# export      PATH=${JAVA_HOME}/bin:${PATH}

if [ $# -gr 0 -a "${1}" == "-d" ] ; then
  echo
  log "DELETING BI-Publisher, press RETURN to continue, Ctrl-C to cancel"
  read nil
  rm -Rf /opt/fmw/products/bip \
         /opt/fmw/config/domains/bip* \
         /opt/local/instances/bip*
  log "Deletion completed"
  exit 0
fi

check_input() {
  if ! which java 2>/dev/null ; then
    error "MISSING: Java not found"
    exit 80
  fi 
  if ! [ -a "${s_bip}/Disk1/runInstaller" ] ; then
    error "MISSING: s_bip/Disk1/runInstaller"
    exit 80
  fi
}

umask ${iam_user_umask}

# set variables from provisioning config file
#
uc1=${DEPLOYER}/user-config/bip/bip_install.rsp
uc2=${DEPLOYER}/user-config/bip/bip_config.rsp

    bip_mw_home=$(grep "MW_HOME="          ${uc1} | cut -d= -f2)
   bip_ora_home=$(grep "ORACLE_HOME="      ${uc1} | cut -d= -f2)
bip_domain_home=$(grep "DOMAIN_HOME_PATH=" ${uc2} | cut -d= -f2)

# are all files available..?
check_input

# Inventory pointer
if ! [ -a ${iam_orainv_ptr} ] ; then
  log "Creating oraInst.loc"
  if ! [ -a $(basedir ${iam_orainv_ptr}) ] ; then
    mkdir -p $(basedir ${iam_orainv_ptr})
  fi
  echo "inventory_loc=/opt/oracle/oraInventory" > ${iam_orainv_ptr}
  echo "inst_group=oinstall"                   >> ${iam_orainv_ptr}
else
  log "Skipped: Creating oraInst.loc"
fi

# create mw home dir
if ! [ -a "${bip_mw_home}" ] ; then
  log "Creating MW_HOME directory...."
  mkdir -p ${bip_mw_home}
  chmod 0750 ${bip_mw_home}
else
  log "Skipped: MW_HOME creation"
fi

# install jdk
if ! [ -a "${bip_mw_home}/jdk" ] ; then
  log "Deploying JDK...."
  mkdir -p ${bip_mw_home}/jdk
  tar xzf ${s_jdk} -C ${bip_mw_home}/jdk
  ln -s ${bip_mw_home}/jdk/jdk1.7.0_71 ${bip_mw_home}/jdk/current
else
  log "Skipped: JDK deployment"
fi

# weblogic
if ! [ -a "${bip_mw_home}/wlserver_10.3" ] ; then
  log "Installing Weblogic Server..."
  java -d64 -jar ${s_wls} -mode=silent -silent_xml=${DEPLOYER}/user-config/bip/wls_install.xml
else
  log "Skipped: Weblogic server installation"
fi

# bip software
if ! [ -a "${bip_ora_home}" ] ; then
  log "Installing BIP software..."
  ${s_bip}/Disk1/runInstaller -silent \
    -jreLoc ${JAVA_HOME}/jre \
    -invPtrLoc ${iam_orainv_ptr} \
    -response ${DEPLOYER}/user-config/bip/bip_install.rsp \
    -ignoreSysPrereqs \
    -nocheckForUpdates \
    -waitforcompletion
else
  log "Skipped: Installation of BIP software"
fi

# create bip instance
if ! [ -a ${bip_domain_home} ] ; then
  log "Creating BI Publisher domain..."
  cp -f ${DEPLOYER}/user-config/bip/staticports.ini /tmp/
  ${bip_ora_home}/bin/config.sh \
    -silent \
    -invPtrLoc ${iam_orainv_ptr} \
    -responseFile ${DEPLOYER}/user-config/bip/bip_config.rsp \
    -jreLoc ${JAVA_HOME}/jre \
    -waitforcompletion \
    -noconsole
  rm -f /tmp/staticports.ini
else
  log "Skipped: Creating BI Publisher domain"
fi

log "Finished BI Publisher Deployment"

# exit 0

