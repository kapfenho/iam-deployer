#  Oracle database functions

#  sorce the oracle environment, in parameter
#+ 1: oracle_home of database installation
#+ 2: database name, used as SID
#
dbs_source_env()
{
  if ! [ -a ${1} ] ; then
    log "dbs_source_env" "ERROR: given directory doesn't exist"
  else
    ORAENV_ASK=NO
    ORACLE_SID=${2}
    set +o nounset
    . ${1}/bin/oraenv -s
    set -o nounset
    log "dbs_source_env" "environment set"
  fi
}
  
#  Alter database settings: processes to 500, open cursors to 1500
#+ storing in spfile. Stateless, can be re-executed.
#+ Vars used: ORACLE_SID, dbs_sid
#
config_database_for_iam()
{
  log "config_database_for_iam" "start"
  if [ -z ${ORACLE_SID} ] ; then
    ORACLE_SID=${dbs_sid}
  fi
  ${ORACLE_HOME}/bin/sqlplus / as sysdba ${ORACLE_HOME}/rdbms/admin/xaview.sql
  ${ORACLE_HOME}/bin/sqlplus / as sysdba << EOF
  @?/rdbms/admin/xaview.sql
  ALTER SYSTEM SET PROCESSES=1600 SCOPE=SPFILE;
  ALTER SYSTEM SET OPEN_CURSORS=1600 SCOPE=SPFILE;
  ALTER SYSTEM SET SESSION_CACHED_CURSORS=500 SCOPE=SPFILE;
  ALTER SYSTEM SET SESSION_MAX_OPEN_FILES=50 SCOPE=SPFILE;
  SHUTDOWN IMMEDIATE;
  STARTUP;
  EXIT;
EOF
  log "config_database_for_iam" "done"
}

#  Restart database with shutdown immediate, followed by start to online.
#+ Vars used: ORACLE_HOME and ORACLE_SID
#
restart_db()
{
  if [ -z ${ORACLE_SID} ] ; then
    ORACLE_SID=${dbs_sid}
  fi
  ${ORACLE_HOME}/bin/sqlplus -s / as sysdba &>/dev/null << EOF
  whenever sqlerror exit sql.sqlcode;
  shutdown immediate;
  startup;
  exit;
EOF
}

#  set datbase instance to autostart (option in file /etc/oratab)
#+ Vars needed: dbs_sid
#
set_db_autostart() {
  sudo -n sed -i -e "s/${dbs_sid}:\/opt\/oracle\/product\/11.2\/db:N/${dbs_sid}:\/opt\/oracle\/product\/11.2\/db:Y/g" /etc/oratab
}

#  Oracle Database software installation. Configuration from response file used.
#+ Skip if already installed.
#+ Vars needed: s_img_db
#+ No parameters used.
#
install_db() {
  log "install_db" "start"
  if [ -a ${ORACLE_HOME}/bin/sqlplus ] ; then
    log "install_db" "skipped"
  else
    log "install_db" "installing..."
    ${s_img_db}/database/runInstaller -silent \
        -waitforcompletion \
        -ignoreSysPrereqs \
        -ignorePrereq \
        -responseFile ${_DIR}/user-config/dbs/db_install.rsp
    log "install_db" "installation done, executing root scripts..."
    log "install_db" "executing root script.."
    if ! sudo -n ${ORACLE_HOME}/root.sh ; then
      echo "ERROR: No permission, but I will continue.  Afterwards root must execute
      ${ORACLE_HOME}/root.sh"
    fi
    log "install_db" "done"
  fi
}

#  Patch Opatch utility, this is patch p6880880 - upgrade to OPatch 
#+ version 11.2.0.3.5, skipping if already applied. Execute right after 
#+ install. 
#+ Variables needed: ORACLE_HOME and s_patch, no parameters
#
patch_opatch()
{
  local _o=${ORACLE_HOME}/OPatch
  local _b=${ORACLE_HOME}/OPatch.prev
  local _skip='OPatch.*11\.2\.0\.3\.5'
  log "patch_opatch" "start"

  if ! ${ORACLE_HOME}/OPatch/opatch lsinventory | grep -q "${_skip}" ; then
    if [ -a ${_b} ] ; then
      # write this to stdout
      c="rm -Rf ${_b}" ; echo "${c}" ; ${c}
    fi
    c="mv ${_o} ${_b}" ; echo ${c} ; ${c}
    unzip -d ${ORACLE_HOME}/ ${s_patches}/p6880880_112000_Linux-x86-64.zip 'OPatch/*'
    log "patch_opatch" "new version extracted to ${ORACLE_HOME}/OPatch/"
    log "patch_opatch" "you can remove the former one: ${_b}"
  else
    log "patch_opatch" "skipped"
  fi
}

#  Patch the Database system (orahome)
#+ precondition: extracted patch files in patch folder needed: $s_patches
#+ skip when lsinventory repsonds with patch number or /No need to/
#+ in 1: oracle patch number
#
patch_orahome()
{
  log "patch_orahome_$1" "start"

  # check if patch has already been applied
  if ! ${ORACLE_HOME}/OPatch/opatch lsinventory | egrep -q "$1|No need to" ; then
    (
      log "patch_orahome_$1" "applying now..."
      cd ${s_patches}/$1
      ${ORACLE_HOME}/OPatch/opatch apply \
          -silent \
          -ocmrf ${_DIR}/lib/dbs/ocm.rsp
      log "patch_orahome_$1" "end"
    )
  else
    log "patch_orahome_$1" "already applied - skipped"
  fi
}

#  create database instance as defined in response file, skip if existing
#+ no parameters
#
create_database()
{
  log "create_database" "start"

  # check if db already exists
  if ! grep -q ${dbs_sid} /etc/oratab ; then
    
    # create db with resp file
    ${ORACLE_HOME}/bin/dbca -silent -responseFile ${_DIR}/user-config/dbs/db_create.rsp
    log "create_database" "db created"
    log "create_database" "done"
  else
    log "create_database" "skipped"
  fi
}

#  Configure database listener and networking configureation, as defined 
#+ in response file
#+ Vars used: ORACLE_HOME
#
run_netca()
{
  log "run_netca" "start"
  if ! [ -a ${ORACLE_HOME}/network/admin/listener.ora ] ; then
    ${ORACLE_HOME}/bin/netca -silent \
        -responsefile ${_DIR}/user-config/dbs/db_netca.rsp
    log "run_netca" "done"
  else
    log "run_netca" "skipped"
  fi
}

#  check if OID schema is installed
#
check_oid_schemas()
{
  local old_sid=$ORACLE_SID              # backup old SID name
  export ORACLE_SID=${DB_SERVICENAME}    # set new SID name

  ## execute SQL script (check if ODS and ODSSM schemas exist) with sqlplus
  ${ORACLE_HOME}/bin/sqlplus -s / as sysdba << EOF &>/dev/null
  whenever sqlerror exit sql.sqlcode;
  set echo off 
  set heading off
  SPOOL schema_check.sql
  select username from dba_users;
  SPOOL off
  exit;
EOF
  export ORACLE_SID=$old_sid 
}

