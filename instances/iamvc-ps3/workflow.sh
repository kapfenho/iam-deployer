#!/bin/bash -x
#
#  IAM Setup workflow for cluster
#
#  Prerequisites:
#  - there should be ssh-key communication available
#    on hosts on which the deployment should be performed
# 
set -o errexit errtrace

export DEPLOYER
export PATH=${DEPLOYER}:${PATH}
source ${DEPLOYER}/lib/user-config.sh

for h in ${provhosts[@]}; do
  # copy comfortable env for manual installation works
  cp -f /vagrant/lib/templates/hostenv/env/bash_profile_vagrant_install_temp \
    ${HOME}/.bash_profile
  chmod 0644 ${HOME}/.bash_profile
  # check if all hosts are up
  if ! ping -q -w 1 ${h} >/dev/null 2>&1 ; then
    echo "Postponing provisioning until host ${h} is available"
    exit 0
  fi
done

iam ssh-key -a add -A

# install database
# database
iam orainv

# ps2 rcu: create database schemas
#iam rcu -a create -t identity

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

echo
echo "***** developing: stopping here ***"
exit 0

# deploy user environment in shared location
iam userenv -a env -A
# ssh ${web2} -- sed -i 's/ohs1/ohs2/g' .env/web.env

# on each host: load in user profile and create easy to reach shortcuts 
iam userenv -a profile -A

# copy weblogic libraries
iam weblogic -a wlstlibs -t identity -H ${oim1}

iam identity -a keyfile -u ${nmUser}   -p ${nmPwd} -n -H ${oim1}
iam identity -a keyfile -u ${nmUser}   -p ${nmPwd} -n -H ${oim2}

iam identity -a keyfile -u ${domiUser} -p ${domiPwd} -H ${oim1}
iam identity -a keyfile -u ${domiUser} -p ${domiPwd} -H ${oim2}


iam identity -a config -H ${oim1}

# upgrade jdk
iam jdk -a install7 -O identity -H ${oim1}

ssh ${oim1} -- $SHELL -l ~/bin/stop-identity
ssh ${oim1} -- $SHELL -l ~/bin/stop-nodemanager
ssh ${oim2} -- $SHELL -l ~/bin/stop-nodemanager
ssh ${web1} -- $SHELL -l ~/bin/stop-webtier
ssh ${web2} -- $SHELL -l ~/bin/stop-webtier

iam jdk -a move6 -O identity -H ${oim1}

# identity domain PSA run
iam identity -a psa -H ${oim1}

iam weblogic -a jdk7fix -t identity -H ${oim1}
iam identity -a jdk7fix -H ${oim1}
iam identity -a jdk7fix -H ${oim2}

# identity domain post-install steps
iam identity -a movelogs -H ${oim1}
iam identity -a movelogs -H ${oim2}

# webgate installation bug fix
iam webtier -a movelogs -H ${web1}
iam webtier -a movelogs -H ${web2}
iam webtier -a config -v -H ${web1}
iam webtier -a config -v -H ${web2}

