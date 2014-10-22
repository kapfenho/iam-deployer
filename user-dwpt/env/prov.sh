#!/usr/bin/env bash

set -o errexit nounset
export deployer=/opt/install/dwpbank/iam-deployer
. ${deployer}/user-conf/env/env.sh
#  init done

export JAVA_HOME=${s_repo}/installers/jdk/jdk7
export PATH=${JAVA_HOME}/bin:/usr/local/bin:/usr/bin:/bin

cd ${lcm}/provisioning/bin

./runIAMDeployment.sh \
  -responseFile ${deployer}/user-config/iam/provisioning.rsp \
  -ignoreSysPrereqs true \
  -target ${1}

