#  rcu funtions
#
#  schemas:
#    http://docs.oracle.com/html/E38978_01/r2_im_requirements.htm#CIHEDGIH

function rcu_identity() {
  log "rcu_identity" "start"

  # TÓDO: if exists
  #cd ${s_rcu_home}
  ${s_rcu_home}/bin/rcu \
  -silent \
  -createRepository \
  -databaseType ORACLE \
  -connectString ${dbs_hostname}:1521:${iam_sid} \
  -dbUser sys \
  -dbRole sysdba \
  -useSamePasswordForAllSchemaUsers true \
  -schemaPrefix DEVI \
  -component MDS       \
  -component IAU       \
  -component OPSS      \
  -component SOAINFRA  \
  -component ORASDPM   \
  -component OIM       \
  <<EOF
${iam_dba_pass}
${iam_oim_schema_pass}
EOF
  log "rcu_identity" "done"
}

function rcu_drop_identity() {
  log "rcu_drop_identity" "start"

  ${s_rcu_home}/bin/rcu \
  -silent \
  -dropRepository \
  -databaseType ORACLE \
  -connectString ${dbs_hostname}:1521:${iam_sid} \
  -dbUser sys \
  -dbRole sysdba \
  -schemaPrefix DEVI \
  -component MDS       \
  -component IAU       \
  -component OPSS      \
  -component SOAINFRA  \
  -component ORASDPM   \
  -component OIM       \
  <<EOF
${iam_dba_pass}
EOF
  log "rcu_drop_identity" "done"
}

function rcu_access() {
  log "rcu_access" "start"
 
  # TÓDO: if exists
  #cd ${s_rcu_home}
  ${s_rcu_home}/bin/rcu \
  -silent \
  -createRepository \
  -databaseType ORACLE \
  -connectString ${dbs_hostname}:1521:${iam_sid} \
  -dbUser sys \
  -dbRole sysdba \
  -useSamePasswordForAllSchemaUsers true \
  -schemaPrefix DEVA \
  -component MDS       \
  -component IAU       \
  -component OPSS      \
  -component OAM       \
  <<EOF
${iam_dba_pass}
${iam_oam_schema_pass}
EOF
  log "rcu_access" "done"
}


function rcu_drop_access() {
  log "rcu_drop_access" "start"
 
  ${s_rcu_home}/bin/rcu \
  -silent \
  -dropRepository \
  -databaseType ORACLE \
  -connectString ${dbs_hostname}:1521:${iam_sid} \
  -dbUser sys \
  -dbRole sysdba \
  -schemaPrefix DEVA \
  -component MDS       \
  -component IAU       \
  -component OPSS      \
  -component OAM       \
  <<EOF
${iam_dba_pass}
${iam_oam_schema_pass}
EOF
  log "rcu_access" "done"
}


# -silent \
# -createRepository \
# -databaseType ORACLE \
# -connectString crs907.it.internal:1521:OWCT01_SITE1 \
# -dbUser sys \
# -dbRole sysdba \
# -useSamePasswordForAllSchemaUsers true \
# -schemaPrefix DEVI \
# -component MDS      -tablespace HORST_DEV2 -tempTablespace TEMP \
# -component IAU      -tablespace HORST_DEV2 -tempTablespace TEMP \
# -component OPSS     -tablespace HORST_DEV2 -tempTablespace TEMP \
# -component SOAINFRA -tablespace HORST_DEV2 -tempTablespace TEMP \
# -component ORASDPM  -tablespace HORST_DEV2 -tempTablespace TEMP \
# -component OIM      -tablespace HORST_DEV2 -tempTablespace TEMP \
# -component OAM      -tablespace HORST_DEV2 -tempTablespace TEMP \
# <<EOF
# dba_pwd
# new_user_pwd
# EOF
