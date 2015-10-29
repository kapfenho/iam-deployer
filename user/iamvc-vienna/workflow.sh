#!/bin/bash -x
#
#  VWFS Post installation steps
#
#  Prerequisites:
#  - there should be ssh-key communication available
#    on hosts on which the deployment should be performed
#

#  Hosts are:
#    OIM:  oim1  oim2
#    WEB:  web1  web2
#

#  we need common.env to be able to execute iam tool locally
# 
set -o errexit errtrace

export DEPLOYER
export PATH=${DEPLOYER}:${PATH}
source ${DEPLOYER}/lib/user-config.sh

for h in ${provhosts[@]}; do
  if ! ping -q -w 1 ${h} >/dev/null 2>&1 ; then
    echo "Postponing provisioning until host ${h} is available"
    exit 0
  fi
done

# install database
# database
iam orainv

# rcu: create database schemas
iam rcu -a create -t identity

# install lcm
iam lcminst

# let's do the lcm...
for step in \
  preverify \
  install \
  unblock \
  preconfigure \
  configure \
  configure-secondary \
  postconfigure \
  startup \
  validate
do
  # execute step on all hosts
  iam lcmstep -a ${step} -A
done

# deploy user environment in shared location
iam userenv -a env
# on each host: load in user profile and create easy to reach shortcuts 
iam userenv -a profile -H oim1
iam userenv -a profile -H oim2
iam userenv -a profile -H web1
iam userenv -a profile -H web2

# copy weblogic libraries
iam weblogic -a wlstlibs -t identity -H oim1

iam identity -a keyfile -u ${nmUser}   -p ${nmPwd} -n
iam identity -a keyfile -u ${domiUser} -p ${domiPwd}

iam identity -t config

# upgrade jdk
iam jdk -t identity -P 1

ssh oim1 -- stop-all
ssh oim2 -- stop-all
ssh web1 -- stop-all
ssh web2 -- stop-all

iam jdk -t identity -P 2

# identity domain PSA run
iam identity -a psa

iam weblogic -a jdk7fix -t identity -H oim1
iam weblogic -a jdk7fix -t identity -H oim2
iam identity -a jdk7fix -t identity -H oim1
iam identity -a jdk7fix -t identity -H oim2

# identity domain post-install steps
iam identity -a postinstall
iam identity -a movelogs -H oim1
iam identity -a movelogs -H oim2

# webgate installation bug fix
iam webtier -a postinstall
iam webtier -a movelogs -H web1
iam webtier -a movelogs -H web2

