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
  # check if all hosts are up
  if ! ping -q -w 1 ${h} >/dev/null 2>&1 ; then
    echo "Postponing provisioning until host ${h} is available"
    exit 0
  fi
done

iam ssh-key -a add -A

# create inventory, for lcm only
iam orainv
# install lcm
iam lcminst

# let's do the lcm...
#  skipped:   validate
for step in \
  preverify \
  install \
  unblock \
  preconfigure \
  configure \
  configure-secondary \
  postconfigure \
  startup
do
  # execute step on all hosts
  iam lcmstep -a ${step} -A
done

# deploy user environment in shared location
iam userenv -a env -A

# on each host: load in user profile and create easy to reach shortcuts 
iam userenv -a profile -A

# copy weblogic libraries
iam weblogic -a wlstlibs -t identity -H ${oim1}
iam weblogic -a wlstlibs -t access   -H ${oam1}

iam identity -a keyfile -u ${nmUser}   -p ${nmPwd} -n -H ${oim1}
iam identity -a keyfile -u ${nmUser}   -p ${nmPwd} -n -H ${oim2}

iam identity -a keyfile -u ${domiUser} -p ${domiPwd} -H ${oim1}
iam identity -a keyfile -u ${domiUser} -p ${domiPwd} -H ${oim2}

iam access   -a keyfile -u ${nmUser}   -p ${nmPwd} -n -H ${oam1}
iam access   -a keyfile -u ${nmUser}   -p ${nmPwd} -n -H ${oam2}

iam access   -a keyfile -u ${domaUser} -p ${domaPwd} -H ${oam1}
iam access   -a keyfile -u ${domaUser} -p ${domaPwd} -H ${oam2}

iam identity -a config -H ${oim1}

iam access   -a config -H ${oam1}

ssh ${oim1} -- $SHELL -l ~/bin/stop-identity
ssh ${oam1} -- $SHELL -l ~/bin/stop-access
ssh ${oim1} -- $SHELL -l ~/bin/stop-nodemanager
ssh ${oim2} -- $SHELL -l ~/bin/stop-nodemanager
ssh ${oam1} -- $SHELL -l ~/bin/stop-nodemanager
ssh ${oam2} -- $SHELL -l ~/bin/stop-nodemanager
ssh ${oud1} -- $SHELL -l ~/bin/stop-dir
ssh ${oud2} -- $SHELL -l ~/bin/stop-dir
ssh ${web1} -- $SHELL -l ~/bin/stop-webtier
ssh ${web2} -- $SHELL -l ~/bin/stop-webtier

exit 0

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

echo -e "\nSetup finished successfully!\n"
