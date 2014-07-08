#!/bin/sh
set -o errexit
set -o nounset

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${_DIR}/lib/files.sh
. ${_DIR}/lib/libcommon.sh
. ${_DIR}/lib/libsys.sh
. ${_DIR}/lib/libdb.sh
. ${_DIR}/lib/librcu.sh
. ${_DIR}/lib/libiam.sh
. ${_DIR}/lib/librcu.sh
. ${_DIR}/user-config/dbs.sh
. ${_DIR}/user-config/iam.sh

JAVA_HOME=${s_runjdk};         export JAVA_HOME
PATH=${JAVA_HOME}/bin:${PATH}; export PATH
umask ${iam_user_umask}

echo
echo "Removing IAM Domain"
echo
echo "Press RETURN to continue, Ctrl-C to cancel".
read

b=/appl/iam/fmw
set -x
rm -Rf  $b/products \
        $b/config \
        $b/plan.lck \
        $b/lcm/provisioning/phaseguards/* \
        $b/lcm/provisioning/provlocks/* \
        $b/lcm/privisioning/logs/*
set +x

echo "Files have been removed, now dropping schemas..."

echo "Dropping Access Management..."
rcu_drop_identity
echo "Dropping Access Management..."
rcu_drop_access
echo "Done"

exit 0

