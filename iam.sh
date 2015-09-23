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

log "Start deploying"

# deploy life cycle managment
deploy_lcm

# the patched weblogic installier uses env TMPDIR and needs 1300 MB
#
oldtmp=${TMPDIR}
${TMPDIR:=/tmp}
if expr $(df -m ${TMPDIR} | tail -1 | awk '{ print $3 }') \< 1300 >/dev/null ; then
  export TMPDIR=${iam_top}
fi

# deployment and instance creation with lifecycle management
for step in preverify install
do
  deploy $step
done

# restore old TMPDIR config
export TMPDIR=${oldtmp}

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

