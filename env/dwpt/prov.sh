#!/bin/sh

. /opt/install/dwpbank/iam-deployer/env/dwpt/set.sh

set -o errexit
set -o nounset

export JAVA_HOME=${s_repo}/installers/jdk/jdk7
export PATH=${JAVA_HOME}/bin:/usr/local/bin:/usr/bin:/bin

cd ${shared}/lcm/provisioning/bin

./runIAMDeployment.sh \
  -responseFile ${prj}/user-config/iam/provisioning.rsp \
  -ignoreSysPrereqs true \
  -target ${1}

