#!/bin/sh

#  Installation script for Oracle WebCenter Content installation
#+ Run as OS user that owns the database binaries.
# 
# This procedure can be rerun after an error correction. In the next run 
#+the script will skip already executed steps.
#+All tasks are executed under the defined user account.
#
# Installation files

set -o errexit
set -o nounset

umask 0002

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${_DIR}/lib/libcommon.sh
. ${_DIR}/lib/libdb.sh
. ${_DIR}/lib/libsys.sh
. ${_DIR}/lib/librcu.sh
. ${_DIR}/user-config/database.config
. ${_DIR}/user-config/iam.config

log "main" "start"

local ic=${_DIR}/user-config/dbs/db_install.rsp
local cc=${_DIR}/user-config/dbs/db_create.rsp

    ORACLE_HOME=$(grep "ORACLE_HOME="        ${ic} | cut -d= -f2)
        dbs_app=$(grep "ORACLE_BASE="        ${ic} | cut -d= -f2)
     dbs_orainv=$(grep "INVENTORY_LOCATION=" ${ic} | cut -d= -f2)
 dbs_orainv_grp=$(grep "UNIX_GROUP_NAME="    ${ic} | cut -d= -f2)
dbs_servicename=$(grep "GDBNAME ="           ${cc} | cut -d= -f2)
        dbs_sid=$(grep "SID ="               ${cc} | cut -d= -f2)
     ORACLE_SID=${dbs_sid}
 DB_SERVICENAME=${dbs_servicename}

 # set ORACLE_HOME env variable
set_oracle_home

# create bashrc, bash_profile and source them
create_and_source_user_profile ORACLE_HOME ${HOME}/.bashrc \
    ${_DIR}/lib/templates/dbs/

# deploy jdk, we need a jdk for installation
#jdk_deploy ${dbs_java_home} \
#    ${s_jdkname} \
#    ${s_jdk} \
#    ${dbs_java_urandom} \
#    ${dbs_java_cacerts} \
#    ${dbs_java_current}   

#  oraInventory pointer: /etc/oraInventory and empty inventory dir
create_orainv ${dbs_orainv_ptr} \
    ${dbs_orainv} \
    ${dbs_orainv_grp}

# rdbms software installation with response file
install_db

export PATH=${PATH}:${ORACLE_HOME}/bin
export LD_LIBRARY_PATH=${ORACLE_HOME}/lib
export ORACLE_HOME ORACLE_SID DB_SERVICENAME

# patch the patcher
patch_opatch
    
# apply rdbms patches
patch_orahome 16619892

# create Database Instance
create_database

# configure database networking (netca)
#run_netca

config_database_for_iam

set_db_autostart
rcd_add oradb ${_DIR}/sys/redhat/rc.d/oradb.sh
rcd_service_start oradb

# create database schema for identity mgmt
rcu_identity
# create database schema for access mgmt
rcu_access

log "main" "done"

exit 0

