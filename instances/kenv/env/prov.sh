#!/bin/bash

s_lcm=/l/ora/lcm/lcm

export DEPLOYER=/l/ora/src/iam-deployer
export JAVA_HOME=/mnt/media/IAM_repository/iam-11.1.2.2/repo/installers/jdk/jdk6
export PATH=${JAVA_HOME}/bin:/usr/local/bin:/usr/bin:/bin

cd ${s_lcm}/provisioning/bin

./runIAMDeployment.sh \
  -responseFile $DEPLOYER/user-config/iam/provisioning.rsp \
  -ignoreSysPrereqs true \
  -target ${1}
