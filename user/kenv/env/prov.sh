#!/bin/bash

# this script is calley by the ssh from the provisioning host

iam_top=/l/ora

s_lcm=/l/ora/lcm/lcm

export DEPLOYER=/vagrant
export JAVA_HOME=/mnt/oracle/iam-11.1.2.2/repo/installers/jdk/jdk7
export PATH=${JAVA_HOME}/bin:/usr/local/bin:/usr/bin:/bin

cd ${s_lcm}/provisioning/bin

./runIAMDeployment.sh \
  -responseFile /vagrant/user-config/iam/provisioning.rsp \
  -ignoreSysPrereqs true \
  -target ${1}
