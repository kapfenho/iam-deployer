#  rcu functions
#
#  schemas:
#    http://docs.oracle.com/html/E38978_01/r2_im_requirements.htm#CIHEDGIH

# ------------------------------------------------------------------------
#  create database schemas for identity management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, iam_dba_pass,
#+              iam_oim_schema_pass
#+ 
rcu_identity() {
  ${s_rcu_home}/bin/rcu \
    -silent \
    -createRepository \
    -databaseType ORACLE \
    -connectString ${dbs_dbhost}:${dbs_port}/${iam_sid} \
    -dbUser sys \
    -dbRole sysdba \
    -useSamePasswordForAllSchemaUsers true \
    -schemaPrefix ${iam_oim_prefix} \
    -component MDS \
    -component OPSS \
    -component SOAINFRA \
    -component ORASDPM \
    -component OIM \
    <<EOF
${iam_dba_pass}
${iam_oim_schema_pass}
EOF
}

#  drop database schemas of identity management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, iam_dba_pass
#+ 
rcu_drop_identity() {
  ${s_rcu_home}/bin/rcu \
    -silent \
    -dropRepository \
    -databaseType ORACLE \
    -connectString ${dbs_dbhost}:${dbs_port}/${iam_sid} \
    -dbUser sys \
    -dbRole sysdba \
    -schemaPrefix ${iam_oim_prefix} \
    -component MDS \
    -component OPSS \
    -component SOAINFRA \
    -component ORASDPM \
    -component OIM \
    <<EOF
${iam_dba_pass}
EOF
}

#  create database schemas for access management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, iam_dba_pass,
#+              iam_oam_schema_pass
#+ 
rcu_access() {
  RCU_LOG_LOCATION=/tmp ${s_rcu_home}/bin/rcu \
    -silent \
    -createRepository \
    -databaseType ORACLE \
    -connectString ${dbs_dbhost}:${dbs_port}/${iam_sid} \
    -dbUser sys \
    -dbRole sysdba \
    -useSamePasswordForAllSchemaUsers true \
    -schemaPrefix ${iam_oam_prefix} \
    -component MDS \
    -component IAU \
    -component OPSS \
    -component OAM \
    <<EOF
${iam_dba_pass}
${iam_oam_schema_pass}
EOF
}

# ------------------------------------------------------------------------
#  drop database schemas of access management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, iam_dba_pass
#+ 
rcu_drop_access() {
  ${s_rcu_home}/bin/rcu \
    -silent \
    -dropRepository \
    -databaseType ORACLE \
    -connectString ${dbs_dbhost}:${dbs_port}/${iam_sid} \
    -dbUser sys \
    -dbRole sysdba \
    -schemaPrefix ${iam_oam_prefix} \
    -component MDS \
    -component IAU \
    -component OPSS \
    -component OAM \
    <<EOF
${iam_dba_pass}
EOF
}


# ------------------------------------------------------------------------
#  create database schemas for identity management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, iam_dba_pass,
#+              iam_oim_schema_pass
#+ 
rcu_bi_publisher() {
  ${s_rcu_home}/bin/rcu \
    -silent \
    -createRepository \
    -databaseType ORACLE \
    -connectString ${dbs_dbhost}:${dbs_port}/${iam_sid} \
    -dbUser sys \
    -dbRole sysdba \
    -useSamePasswordForAllSchemaUsers true \
    -schemaPrefix ${iam_bip_prefix} \
    -component MDS  \
    -component BIPLATFORM \
    <<EOF
${iam_dba_pass}
${iam_bip_schema_pass}
EOF
}

# ------------------------------------------------------------------------
#  drop database schemas of access management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, iam_dba_pass
#+ 
rcu_drop_bi_publisher() {
  ${s_rcu_home}/bin/rcu \
    -silent \
    -dropRepository \
    -databaseType ORACLE \
    -connectString ${dbs_dbhost}:${dbs_port}/${iam_sid} \
    -dbUser sys \
    -dbRole sysdba \
    -schemaPrefix ${iam_bip_prefix} \
    -component MDS  \
    -component BIPLATFORM \
    <<EOF
${iam_dba_pass}
EOF
}

run_rcu()
{
  local _mode=${1}
  local _product=${2}
  local _user_check=""
  local _exists

  case ${_product} in
    identity)
      _user_check="${iam_oim_prefix}_OIM" ;;
    access)
      _user_check="${iam_oam_prefix}_OAM" ;;
    bip)
      error "TODO: find db schema name"
      _user_check="${iam_bip_prefix}_BIP" ;;
    analytics)
      if [ "${_mode}" == "create" ] ; then
        create_oia_schema
        return $?
      elif [ "${_mode}" == "remove" ] ; then
        drop_oia_schema
        return $?
      fi
      ;;
    \*)
      error "product not available in schema check!" ;;
  esac

  log "RCU: testing for user ${_user_check}"

  ORACLE_HOME=${s_rcu_home}
  LD_LIBRARY_PATH=${ORACLE_HOME}/lib
  export ORACLE_HOME LD_LIBRARY_PATH
  set -x
  local _sqlout=$(mktemp /tmp/rcu-check-XXXXXXX)
  sqlcmd="${ORACLE_HOME}/bin/sqlplus sys/${iam_dba_pass}@//${dbs_dbhost}:${dbs_port}/${iam_servicename} as sysdba"
  # if echo "select 'EXISTS' from dba_users where username = '${_user_check}';" | ${sqlcmd} | grep -q EXISTS ; then
  if echo "select 'EXISTS' from dba_users where username = '${_user_check}';" | ${sqlcmd} >${_sqlout} ; then
    if grep -q 'EXISTS' ${_sqlout} ; then
      log "found user ${_user_check} in database"
      _exists=1
    else
      log "no user ${_user_check} found in database"
      unset _exists
    fi
  else
    error "Problem while connecting to database"
  fi
  #rm -f ${_sqlout}
  
  if   [ "${_mode}" == "create" -a -z "${_exists}" ] ; then
    log "running rcu tool"
    rcu_${_product} | strings
  elif [ "${_mode}" == "remove" -a -n "${_exists}" ] ; then
    rcu_drop_${_product} | strings
  fi
  unset ORACLE_HOME LD_LIBRARY_PATH
  set +x
}

# ----------------------------------------------------------------------
#

create_oia_schema()
{
  log "Creating OIA database schema"

  local dbconn="//${dbs_dbhost}:${dbs_port}/${iam_servicename}"
  ORACLE_HOME=${s_rcu_home}
  LD_LIBRARY_PATH=${ORACLE_HOME}/lib
  export ORACLE_HOME LD_LIBRARY_PATH
  set -x

  # create user and tablespaces
  local sqlp1="${ORACLE_HOME}/bin/sqlplus sys/${iam_dba_pass}@${dbconn} as sysdba"
  ${sqlp1} <<-EOS
  @${DEPLOYER}/oia/dbuser.sql;
  exit;
EOS
  
  # create objects
  sqlp2="${ORACLE_HOME}/bin/sqlplus ${iam_oia_dbuser}/${iam_oia_schema_pass}@${dbconn}"
  ${sqlp2} <<-EOS
  @${s_oia}/sql/10-create-schema.sql
  @${s_oia}/sql/20-mig1.sql
  @${s_oia}/sql/21-mig2.sql
  @${s_oia}/sql/22-mig3.sql
  commit;
  exit;
EOS

  log "Database schema OIA created"

  unset ORACLE_HOME LD_LIBRARY_PATH
  set +x
}

