#!/bin/sh

set -o errexit
set -o nounset

dbs_dbhost="oim12.agoracon.at"
dbs_port=1521
iam_servicename="oim12"
iam_oim_prefix="OIM"
iam_dba_pass="Montag11"
iam_oim_schema_pass="Montag11"

$ORACLE_HOME/oracle_common/bin/rcu \
    -silent \
    -createRepository \
    -databaseType ORACLE \
    -connectString ${dbs_dbhost}:${dbs_port}/${iam_servicename} \
    -dbUser sys \
    -dbRole sysdba \
    -useSamePasswordForAllSchemaUsers true \
    -schemaPrefix ${iam_oim_prefix} \
    -component MDS \
    -component WLS \
    -component IAU \
    -component IAU_VIEWER \
    -component IAU_APPEND \
    -component OPSS \
    -component SOAINFRA \
    -component UCSUMS \
    -component OIM \
    -component STB \
    <<EOF
${iam_dba_pass}
${iam_oim_schema_pass}
EOF
