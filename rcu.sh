#!/bin/sh
#
#  oracle rcu wrapper
#  create or remove database schema for IAM
#
#  * Configuration in  user-config/iam.config
# 
#  * Create schemas
#      Execute without parameters
#        ./run-rcu.hs
#
#  * Drop schemas
#      specify any parameter
#        ./run-rcu.sh drop
#
#  http://docs.oracle.com/html/E38978_01/r2_im_requirements.htm#CIHEDGIH
#  horst.kapfenberger@agoracon.at, 2014-09-10
#  vim: set ft=sh :

set -o errexit nounset

if [ -z ${DEPLOYER} ] ; then
  echo "ERROR: env variable DEPLOYER not set!"
  exit 80
fi

. ${DEPLOYER}/user-config/iam.config
. ${DEPLOYER}/lib/libcommon2.sh

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
    -connectString ${dbs_dbhost}:1521:${iam_sid} \
    -dbUser sys \
    -dbRole sysdba \
    -useSamePasswordForAllSchemaUsers true \
    -schemaPrefix ${iam_oim_prefix} \
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
}

#  drop database schemas of identity management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, iam_dba_pass
#+ 
rcu_drop_identity() {
  ${s_rcu_home}/bin/rcu \
    -silent \
    -dropRepository \
    -databaseType ORACLE \
    -connectString ${dbs_dbhost}:1521:${iam_sid} \
    -dbUser sys \
    -dbRole sysdba \
    -schemaPrefix ${iam_oim_prefix} \
    -component MDS       \
    -component IAU       \
    -component OPSS      \
    -component SOAINFRA  \
    -component ORASDPM   \
    -component OIM       \
    <<EOF
${iam_dba_pass}
EOF
}

#  create database schemas for access management.
#+ vars needed: s_rcu_home, dbs_dbhost, iam_sid, iam_dba_pass,
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
    -schemaPrefix ${iam_oam_prefix} \
    -component MDS       \
    -component IAU       \
    -component OPSS      \
    -component OAM       \
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
    -connectString ${dbs_dbhost}:1521:${iam_sid} \
    -dbUser sys \
    -dbRole sysdba \
    -schemaPrefix ${iam_oam_prefix} \
    -component MDS       \
    -component IAU       \
    -component OPSS      \
    -component OAM       \
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
    -connectString ${dbs_dbhost}:1521:${iam_sid} \
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
    -connectString ${dbs_dbhost}:1521:${iam_sid} \
    -dbUser sys \
    -dbRole sysdba \
    -schemaPrefix ${iam_bip_prefix} \
    -component MDS  \
    -component BIPLATFORM \
    <<EOF
${iam_dba_pass}
EOF
}

# -------------------------------------------------------
echo

if [ ${#} -gt 0 ] 
then
  echo "*** Dropping schemas ***"
  echo "  press RETURN to continue or Ctrl-C to stop"
  read cont
  echo
  echo "***  Dropping Identity schema..."
  rcu_drop_identity
  echo "***  Dropping Access schema..."
  rcu_drop_access
  echo "***  Dropping BI Publisher schema..."
  rcu_drop_bi_publisher
else
  echo "*** Creating schemas ***"
  echo "  press RETURN to continue or Ctrl-C to stop"
  read cont
  echo
  echo "***  Creating Identity schema..."
  rcu_identity
  echo "***  Creating Access schema..."
  rcu_access
  echo "***  Creating BI Publisher schema..."
  rcu_bi_publisher
fi

echo "*** Schema actions finished. ***"

exit 0

