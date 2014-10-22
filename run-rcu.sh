#!/bin/sh
#
#  oracle rcu wrapper
#                                                                    schemas
#      http://docs.oracle.com/html/E38978_01/r2_im_requirements.htm#CIHEDGIH
#
#                                 horst.kapfenberger@agoracon.at, 2014-09-10
#                                                           vim: set ft=sh :

set -o errexit
set -o nounset

#  ----------------------- configure me ------------------------
#
s_rcu_home=/mnt/oracle/iam-11.1.2.2/repo/installers/fmw_rcu/linux/rcuHome
dbs_dbhost=dbhostname
iam_sid=mysid
dbs_sys_pass=mysyspassword
iam_oim_schema_pass=myoimpassword
iam_oam_schema_pass=myoampassword
#
#  ---------------------------  thanks  ------------------------


#  create database schemas for identity management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, dbs_sys_pass,
#+              iam_oim_schema_pass
#+ 
rcu_identity() {
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
}

#  drop database schemas of identity management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, dbs_sys_pass
#+ 
rcu_drop_identity() {
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
}

#  create database schemas for access management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, dbs_sys_pass,
#+              iam_oam_schema_pass
#+ 
rcu_access() {
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
}

#  drop database schemas of access management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, dbs_sys_pass
#+ 
rcu_drop_access() {
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
}


echo

rcu_drop_identity
rcu_drop_access

echo "RUN-RCU: Starting identity creation..."
rcu_identity
echo "RUN-RCU: Starting access   creation..."
rcu_access
echo "RUN-RCU: Finished."

exit 0

