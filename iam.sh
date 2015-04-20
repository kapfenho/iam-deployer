#!/bin/sh

set -o errexit nounset

. ${DEPLOYER}/user-config/iam.config
. ${DEPLOYER}/lib/libcommon2.sh
. ${DEPLOYER}/lib/libiam.sh
. ${DEPLOYER}/lib/libjdk.sh
. ${DEPLOYER}/lib/librcu.sh

export JAVA_HOME=${s_runjdk}
export      PATH=${JAVA_HOME}/bin:${PATH}
export RCU_LOG_LOCATION=/tmp 

umask ${iam_user_umask}

# set variables from provisioning config file
uc=${DEPLOYER}/user-config/iam/provisioning.rsp
orainst_loc=${iam_orainv_ptr}
db_flag=${iam_top}/.db_schemas_completed

     s_repo=$(grep "INSTALL_INSTALLERS_DIR=" ${uc} | cut -d= -f2)
iam_mw_home=$(grep "COMMON_FMW_DIR="         ${uc} | cut -d= -f2)

if [ $# -gt 0 -a "${1}" == "-d" ] ; then
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
set -x
if ! [ -a ${db_flag} ] ; then
  log "Creating database schemas"
  if rcu_identity && rcu_access && rcu_bi_publisher ; then
    touch ${db_flag}
    log "Database schemas created successfully"
  else
    error "Error in creating database schemas, check logs in /tmp"
    exit 1
  fi
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

