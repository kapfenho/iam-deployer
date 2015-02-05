#  rcu functions
#
#  schemas:
#    http://docs.oracle.com/html/E38978_01/r2_im_requirements.htm#CIHEDGIH

#  create database schemas for identity management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, dbs_sys_pass,
#+              iam_oim_schema_pass
#+ 
rcu_identity() {
  log "rcu_identity" "start"

  # TODO: if exists
  ${s_rcu_home}/bin/rcu \
  -silent \
  -createRepository \
  -databaseType ORACLE \
  -connectString ${dbs_dbhost}:1521:${iam_sid} \
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
${dbs_sys_pass}
${iam_oim_schema_pass}
EOF
  log "rcu_identity" "done"
}

#  drop database schemas of identity management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, dbs_sys_pass
#+ 
rcu_drop_identity() {
  log "rcu_drop_identity" "start"

  ${s_rcu_home}/bin/rcu \
  -silent \
  -dropRepository \
  -databaseType ORACLE \
  -connectString ${dbs_dbhost}:1521:${iam_sid} \
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
${dbs_sys_pass}
EOF
  log "rcu_drop_identity" "done"
}

#  create database schemas for access management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, dbs_sys_pass,
#+              iam_oam_schema_pass
#+ 
rcu_access() {
  log "rcu_access" "start"
 
  # TODO: if exists
  ${s_rcu_home}/bin/rcu \
  -silent \
  -createRepository \
  -databaseType ORACLE \
  -connectString ${dbs_dbhost}:1521:${iam_sid} \
  -dbUser sys \
  -dbRole sysdba \
  -useSamePasswordForAllSchemaUsers true \
  -schemaPrefix DEVA \
  -component MDS       \
  -component IAU       \
  -component OPSS      \
  -component OAM       \
  <<EOF
${dbs_sys_pass}
${iam_oam_schema_pass}
EOF
  log "rcu_access" "done"
}

#  drop database schemas of access management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, dbs_sys_pass
#+ 
rcu_drop_access() {
  log "rcu_drop_access" "start"
 
  ${s_rcu_home}/bin/rcu \
  -silent \
  -dropRepository \
  -databaseType ORACLE \
  -connectString ${dbs_dbhost}:1521:${iam_sid} \
  -dbUser sys \
  -dbRole sysdba \
  -schemaPrefix DEVA \
  -component MDS       \
  -component IAU       \
  -component OPSS      \
  -component OAM       \
  <<EOF
${dbs_sys_pass}
EOF
  log "rcu_drop_access" "done"
}

