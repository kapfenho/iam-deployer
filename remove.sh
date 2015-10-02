#!/bin/bash

. ${DEPLOYER}/user-config/iam.config
. ${DEPLOYER}/lib/libcommon2.sh
. ${DEPLOYER}/lib/librcu.sh

export JAVA_HOME=${s_runjdk}
export      PATH=${JAVA_HOME}/bin:${PATH}
export RCU_LOG_LOCATION=/tmp 

umask ${iam_user_umask}

set -o verbose

# set variables from provisioning config file
uc=${DEPLOYER}/user-config/iam/provisioning.rsp
orainst_loc=${iam_orainv_ptr}
db_flag=${iam_top}/.db_schemas_completed

help() {

  echo
  echo "Options for removing:"
  echo " -i    identity database"
  echo " -a    access database"
  echo " -b    bi publisher database"
  echo " -f    files and directories"
  echo
}

remove_files() {
  set -x
  rm -Rf ${iam_top}/products/* \
         ${iam_top}/config/* \
         ${iam_top}/*.lck \
         ${iam_top}/lcm/lcmhome/provisioning/phaseguards/* \
         ${iam_top}/lcm/lcmhome/provisioning/provlocks/* \
         ${iam_top}/lcm/lcmhome/provisioning/logs/*
  set +x
}

# main program -----------------------------
#

while getopts iabf FLAG; do
  case $FLAG in
    i) echo "....i" ;;
      #rcu_drop_identity ;;
    a) echo "....a" ;;
      #rcu_drop_access ;;
    b) echo "....b" ;;
      #rcu_drop_bi_publisher ;;
    f) echo "....f" ;;
      #remove_files ;;
    *)
      help ;;
  esac
done

remove_files

exit 0

