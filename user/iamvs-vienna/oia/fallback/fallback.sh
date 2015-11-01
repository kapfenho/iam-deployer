#!/bin/sh

# create OIA Database User and Schema

set -o errexit nounset

iam_oia_prefix=IAM1I_OIA
iam_oia_schema_pass=Montag11

logfile=/tmp/oia_schema.log

#DEPLOYER=/home/fmwuser/iam-deployer
SQLPLUS='sudo -i -u oracle sqlplus'

. ${DEPLOYER}/user-config/iam.config

echo "Creating OIA Database User and Schema"
echo "Log file is at ${logfile}" 

# create OIA user
${SQLPLUS} -s / as sysdba &> ${logfile} << EOF
@${s_oia}/sql/00-create-tablespace.sql
@${s_oia}/sql/01-create-user.sql
commit;
exit;
EOF

${SQLPLUS} -s ${iam_oia_prefix}/${iam_oia_schema_pass}@${dbs_dbhost}/${iam_sid} &>> ${logfile} << EOF
@${s_oia}/sql/10-create-schema.sql
@${s_oia}/sql/20-mig1.sql
@${s_oia}/sql/21-mig2.sql
@${s_oia}/sql/22-mig3.sql
commit;
exit;
EOF

echo "Created OIA Database User and Schema."
