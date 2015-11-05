#!/bin/bash
#
#  VWFS Post installation steps
#
#  Prerequisites:
#  - there should be ssh-key communication available
#    on hosts on which the deployment should be performed
#

#  Single host setup workflow
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
#iam orainv
#
## rcu: create database schemas
#iam rcu -a create -t identity
#
## install lcm
#iam lcminst
#
## let's do the lcm...
#for step in \
#  preverify \
#  install \
#  unblock \
#  preconfigure \
#  configure \
#  configure-secondary \
#  postconfigure \
#  startup \
#  validate
#do
#  # execute step on all hosts
#  iam lcmstep -a ${step}
#done

# deploy user environment in shared location
iam userenv -a env
# on each host: load in user profile and create easy to reach shortcuts 
iam userenv -a profile

# copy weblogic libraries
iam weblogic -a wlstlibs -t identity

# generate keyfiles
iam identity -a keyfile -u ${nmUser}   -p ${nmPwd} -n
iam identity -a keyfile -u ${domiUser} -p ${domiPwd}

# domain configuration
iam identity -a config

# upgrade jdk
iam jdk -a install7 -O identity

$SHELL -l ~/bin/stop-all

iam jdk -a move6 -O identity

# identity domain PSA run
iam identity -a psa

iam weblogic -a jdk7fix -t identity
iam identity -a jdk7fix

# identity domain post-install steps
iam identity -a movelogs

# webgate installation bug fix
iam webtier -a movelogs

