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
    -connectString ${dbs_dbhost}:${dbs_port}/${iam_servicename} \
    -dbUser sys \
    -dbRole sysdba \
    -useSamePasswordForAllSchemaUsers true \
    -schemaPrefix ${iam_oim_prefix} \
    -component MDS \
    -component OPSS \
    -component SOAINFRA \
    -component ORASDPM \
    -component OIM \
    -component BIPLATFORM \
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
    -connectString ${dbs_dbhost}:${dbs_port}/${iam_servicename} \
    -dbUser sys \
    -dbRole sysdba \
    -schemaPrefix ${iam_oim_prefix} \
    -component MDS \
    -component OPSS \
    -component SOAINFRA \
    -component ORASDPM \
    -component OIM \
    -component BIPLATFORM \
    <<EOF
${iam_dba_pass}
EOF
}

# ------------------------------------------------------------------------
#  create database schemas for access management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, iam_dba_pass,
#+              iam_oam_schema_pass
#+ 
rcu_access() {
  RCU_LOG_LOCATION=/tmp ${s_rcu_home}/bin/rcu \
    -silent \
    -createRepository \
    -databaseType ORACLE \
    -connectString ${dbs_dbhost}:${dbs_port}/${iam_servicename} \
    -dbUser sys \
    -dbRole sysdba \
    -useSamePasswordForAllSchemaUsers true \
    -schemaPrefix ${iam_oam_prefix} \
    -component MDS \
    -component IAU \
    -component OPSS \
    -component OAM \
    -component OMSM \
    <<EOF
${iam_dba_pass}
${iam_oam_schema_pass}
EOF
}

#  drop database schemas of access management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, iam_dba_pass
#+ 
rcu_drop_access() {
  ${s_rcu_home}/bin/rcu \
    -silent \
    -dropRepository \
    -databaseType ORACLE \
    -connectString ${dbs_dbhost}:${dbs_port}/${iam_servicename} \
    -dbUser sys \
    -dbRole sysdba \
    -schemaPrefix ${iam_oam_prefix} \
    -component MDS \
    -component IAU \
    -component OPSS \
    -component OAM \
    -component OMSM \
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
    -connectString ${dbs_dbhost}:${dbs_port}/${iam_servicename} \
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

#  drop database schemas of access management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, iam_dba_pass
#+ 
rcu_drop_bi_publisher() {
  ${s_rcu_home}/bin/rcu \
    -silent \
    -dropRepository \
    -databaseType ORACLE \
    -connectString ${dbs_dbhost}:${dbs_port}/${iam_servicename} \
    -dbUser sys \
    -dbRole sysdba \
    -schemaPrefix ${iam_bip_prefix} \
    -component MDS  \
    -component BIPLATFORM \
    <<EOF
${iam_dba_pass}
EOF
}

# ------------------------------------------------------------------------
#  create database schemas for analytics
#+ vars needed: dbs_dbhost, iam_servicename, iam_dba_pass,
#+              iam_oia_schema_pass
#+ 
rcu_analytics() {
  local dbconn="//${dbs_dbhost}:${dbs_port}/${iam_servicename}"
  # create user and tablespaces
  ${ORACLE_HOME}/bin/sqlplus sys/${iam_dba_pass}@${dbconn} as sysdba <<-EOS
  @${DEPLOYER}/user-config/oia/create-user.sql;
  exit;
EOS
  # create objects
  echo 
  echo "1 Load OIA 11.1.1.5.5AF schema with removed tablespace"
  echo "2 Loading migrate-rbacx-11.1.1.5.3To11.1.1.5.4-oracle.sql"
  echo "3 Loading migrate-rbacx-11.1.1.5.4To11.1.1.5.5-oracle.sql"
  echo 
  ${ORACLE_HOME}/bin/sqlplus ${iam_oia_dbuser}/${iam_oia_schema_pass}@${dbconn} <<-EOS
  @${s_oia_sql}/rbacx-11.1.1.5.1_oracle_schema-default-tbs.sql
  @${s_oia_sql}/migrate-rbacx-11.1.1.5.3To11.1.1.5.4-oracle.sql
  @${s_oia_sql}/migrate-rbacx-11.1.1.5.4To11.1.1.5.5-oracle.sql
  commit;
  exit;
EOS
  echo "Schema import completed"
}

#  drop database schemas of analytics
#+ 
rcu_drop_analytics() {
  local dbconn="//${dbs_dbhost}:${dbs_port}/${iam_servicename}"
  ${ORACLE_HOME}/bin/sqlplus sys/${iam_dba_pass}@${dbconn} as sysdba <<-EOS
  @${DEPLOYER}/user-config/oia/remove-user.sql;
  exit;
EOS
}

# ------------------------------------------------------------------------
#  create or drop application database schema, main function
#  check if schema exists before executing action
#+ 
run_rcu()
{
  local _mode=${1}
  local _product=${2}
  local _user_check=""
  local _exists

  # get username to check existence for
  case ${_product} in
    identity)
      _user_check="${iam_oim_prefix}_OIM" ;;
    access)
      _user_check="${iam_oam_prefix}_OAM" ;;
    bip)
      _user_check="${iam_bip_prefix}_BIP" ;;
    analytics)
      _user_check="${iam_oia_dbuser}"     ;;
    \*)
      error "product not available in schema check!" ;;
  esac

  log "RCU: testing existence of user ${_user_check}"

  export     ORACLE_HOME=${s_rcu_home}
  export LD_LIBRARY_PATH=${ORACLE_HOME}/lib
  local _sqlout=$(mktemp /tmp/rcu-check-XXXXXXX)
  sqlcmd="${ORACLE_HOME}/bin/sqlplus sys/${iam_dba_pass}@//${dbs_dbhost}:${dbs_port}/${iam_servicename} as sysdba"

  if echo "select 'EXISTS' from dba_users where username = '${_user_check}';" | ${sqlcmd} >${_sqlout} ; then
    if grep -q 'EXISTS' ${_sqlout} ; then
      log "RCU check: user ${_user_check} found in database"
      _exists=1
    else
      log "RCU check: user ${_user_check} not found in database"
      unset _exists
    fi
  else
    error "RCU check: problem while connecting to database"
  fi
  rm -f ${_sqlout}
 
  # RCU tool execution
  if   [ "${_mode}" == "create" -a -z "${_exists}" ] ; then
    rcu_${_product} | strings
  elif [ "${_mode}" == "remove" -a -n "${_exists}" ] ; then
    rcu_drop_${_product} | strings
  fi
  unset ORACLE_HOME LD_LIBRARY_PATH
}

