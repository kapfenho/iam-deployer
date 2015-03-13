#!/bin/sh

set -o errexit nounset

. ${DEPLOYER}/user-config/iam.config
. ${DEPLOYER}/lib/libcommon2.sh
. ${DEPLOYER}/lib/libiam.sh
. ${DEPLOYER}/lib/libjdk.sh

export JAVA_HOME=${s_runjdk}
export      PATH=${JAVA_HOME}/bin:${PATH}

umask ${iam_user_umask}

# set variables from provisioning config file
uc=${DEPLOYER}/user-config/iam/provisioning.rsp

     s_repo=$(grep "INSTALL_INSTALLERS_DIR=" ${uc} | cut -d= -f2)
iam_mw_home=$(grep "COMMON_FMW_DIR="         ${uc} | cut -d= -f2)

if [ $# -gr 0 -a "${1}" == "-d" ] ; then
  echo
  warning "I am gonna DELETE IAM - RETURN to continue, Ctrl-C to cancel"
  read nil
  rm -Rf ${iam_top}/products \
         ${iam_top}/config \
         ${iam_top}/plan.lck \
         ${iam_top}/lcm/provisioning/phaseguards/* \
         ${iam_top}/lcm/provisioning/provlocks/* \
         ${iam_top}/lcm/privisioning/logs/*

  log "Files have been removed"
  warning "I am gonna DROP DATABASE SCHEMAS - RETURN to continue, Ctrl-C to cancel"
  read nil
  rcu_drop_identity
  rcu_drop_access
  log "Deletion completed"
  exit 0
fi

log "Start deploying"

# deploy life cycle managment
deploy_lcm
 
# deployment and instance creation with lifecycle management
for step in preverify install
do
  deploy $step
done

# use urandom
for p in access dir identity web
do
  jdk_patch_config ${iam_top}/products/${p}/jdk6
done

# deployment and instance creation with lifecycle management
for step in preconfigure configure configure-secondary postconfigure startup validate
do
  deploy $step
done

log "Deployment finished"

exit 0

