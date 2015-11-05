#!/bin/bash -x
#
#  VWFS Post installation steps
#
#  Prerequisites:
#  - there should be ssh-key communication available
#    on hosts on which the deployment should be performed
#

#  Hosts are:
#    OIM + WEB:  bsul0355  bsul0356
#
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
iam userenv -a env -A
# on each host: load in user profile and create easy to reach shortcuts 
iam userenv -a profile -A

# copy weblogic libraries
iam weblogic -a wlstlibs -t identity

# generate keyfiles
iam identity -a keyfile -u ${nmUser}   -p ${nmPwd} -n -H bsul0355
iam identity -a keyfile -u ${nmUser}   -p ${nmPwd} -n -H bsul0356

iam identity -a keyfile -u ${domiUser} -p ${domiPwd} -H bsul0355
iam identity -a keyfile -u ${domiUser} -p ${domiPwd} -H bsul0356

iam identity -a config

# upgrade jdk
iam jdk -a install7 -O identity

ssh bsul0355 -- $SHELL -l ~/bin/stop-all
ssh bsul0356 -- $SHELL -l ~/bin/stop-all



iam jdk -a move6 -O identity

# identity domain PSA run
iam identity -a psa

iam weblogic -a jdk7fix -t identity
iam identity -a jdk7fix -A


# identity domain post-install steps
iam identity -a movelogs -A


# webgate installation bug fix
iam webtier -a movelogs -A
iam webtier -a config -v -A



