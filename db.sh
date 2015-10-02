#!/bin/bash

#  database system installation, instance and application schema creation.
#+ Run as OS user that owns the database binaries.
# 
#  This procedure can be rerun after a possible error correction. In the next
#+ run the script will skip already executed steps.
#+ All tasks are executed under the defined user account.
#

set -o errexit
set -o nounset

umask 0002

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${_DIR}/user-config/database.config
. ${_DIR}/lib/libcommon.sh
. ${_DIR}/lib/libdb.sh
. ${_DIR}/lib/libsys.sh
. ${_DIR}/lib/librcu.sh

log "main" "start"

# use settings from response files
ic=${_DIR}/user-config/dbs/db_install.rsp
cc=${_DIR}/user-config/dbs/db_create.rsp

    ORACLE_HOME=$(grep "^ORACLE_HOME="        ${ic} | cut -d= -f2)
        dbs_app=$(grep "^ORACLE_BASE="        ${ic} | cut -d= -f2)
     dbs_orainv=$(grep "^INVENTORY_LOCATION=" ${ic} | cut -d= -f2)
 dbs_orainv_grp=$(grep "^UNIX_GROUP_NAME="    ${ic} | cut -d= -f2)
dbs_servicename=$(grep "^GDBNAME ="           ${cc} | cut -d\" -f2)
   dbs_sys_pass=$(grep "^SYSPASSWORD ="       ${cc} | cut -d\" -f2)
        dbs_sid=$(grep "^SID ="               ${cc} | cut -d\" -f2)
     ORACLE_SID=${dbs_sid}
 DB_SERVICENAME=${dbs_servicename}

echo "You configured this settings:"
echo "dbs_app:         ${dbs_app}"
echo "dbs_orainv:      ${dbs_orainv}"
echo "dbs_orainv_grp:  ${dbs_orainv_grp}"
echo "dbs_servicename: ${dbs_servicename}"
echo "dbs_sid:         ${dbs_sid}"
echo "DB_SERVICENAME:  ${DB_SERVICENAME}"
echo "ORACLE_SID:      ${ORACLE_SID}"
echo "---------------------------------------"

if [ "$#" -gt 0 ] ; then
  echo "Press Ctrl-C to cancel or ENTER to continue: "
  read cont_now
fi

# create bashrc, bash_profile and source them
create_and_source_user_profile ORACLE_HOME ${HOME}/.bashrc \
    ${_DIR}/lib/templates/dbs/

#  oraInventory pointer: /etc/oraInventory and empty inventory dir
create_orainv ${dbs_orainv_ptr} \
    ${dbs_orainv} \
    ${dbs_orainv_grp}

# rdbms software installation with response file
install_db

export PATH=${PATH}:${ORACLE_HOME}/bin
export LD_LIBRARY_PATH=${ORACLE_HOME}/lib
export ORACLE_HOME ORACLE_SID DB_SERVICENAME

# create Database Instance
create_database

# configure database networking (netca)
#run_netca

config_database_for_iam

set_db_autostart
rcd_add oracle ${_DIR}/sys/redhat/rc.d/oracle
set +o errexit
rcd_service oracle stop
set -o errexit
rcd_service oracle start

log "main" "done"

exit 0

