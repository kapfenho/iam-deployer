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
    -connectString ${dbs_dbhost}:${dbs_port}:${iam_sid} \
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
    -connectString ${dbs_dbhost}:${dbs_port}:${iam_sid} \
    -dbUser sys \
    -dbRole sysdba \
    -schemaPrefix ${iam_oim_prefix} \
    -component MDS \
    -component OPSS \
    -component SOAINFRA \
    -component ORASDPM \
    -component OIM > /dev/null \
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
    -connectString ${dbs_dbhost}:${dbs_port}:${iam_sid} \
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
    -connectString ${dbs_dbhost}:${dbs_port}:${iam_sid} \
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
    -connectString ${dbs_dbhost}:${dbs_port}:${iam_sid} \
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
    -connectString ${dbs_dbhost}:${dbs_port}:${iam_sid} \
    -dbUser sys \
    -dbRole sysdba \
    -schemaPrefix ${iam_bip_prefix} \
    -component MDS  \
    -component BIPLATFORM \
    <<EOF
${iam_dba_pass}
EOF
}



