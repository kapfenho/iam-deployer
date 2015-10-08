#!/bin/bash

. ${DEPLOYER}/user-config/iam.config
. ${DEPLOYER}/lib/user-config.sh
. ${DEPLOYER}/lib/libcommon2.sh
. ${DEPLOYER}/lib/libiam.sh
. ${DEPLOYER}/lib/librcu.sh

export JAVA_HOME=${s_runjdk}
export      PATH=${JAVA_HOME}/bin:${PATH}
export RCU_LOG_LOCATION=/tmp 

umask ${iam_user_umask}

set -o errexit 

# set variables from provisioning config file
uc=${DEPLOYER}/user-config/iam/provisioning.rsp
orainst_loc=${iam_orainv_ptr}
db_flag=${iam_top}/.db_schemas_completed

help() {
  echo "Syntax: ${0} [-d] [-a] [-l] [-h]"
  echo
  echo "  Options for removing (default):"
  echo "    -d    include database (no)"
  echo "    -a    remove an all hosts (no)"
  echo "    -l    include LCM (no)"
  echo "    -h    print help message (this one)"
  echo
}

# main program -----------------------------
#

while getopts dalh FLAG; do
  case $FLAG in
    d)  opt_remove_db=yes    ;;
    a)  opt_on_all_hosts=yes ;;
    l)  opt_incl_lcm=yes     ;;
    h)  help; exit 0         ;;
  esac
done

[ "${opt_on_all_hosts}" != "yes" ] &&  provhosts=( $(hostname -f) )

provdir=${provfiles}/$(date "+%Y%m%d-%H%M%S")-remove
mkdir -p ${provdir}

for h in ${provhosts[@]} ; do
  ef=${provdir}/rm-${h}.sh
  remove_files >${ef} && ssh ${h} -- ${SHELL} ${ef}
done

if [ "${opt_remove_db}" == "yes" ] ; then
  source ${DEPLOYER}/lib/librcu.sh
  do_idm && rcu_drop_identity     | strings
  do_acc && rcu_drop_access       | strings
  do_bip && rcu_drop_bi_publisher | strings
fi

exit 0

