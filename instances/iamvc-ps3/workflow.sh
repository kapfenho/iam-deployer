#!/bin/bash -x
#
#  IAM Setup workflow for cluster
#
set -o errexit
set -o errtrace

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

# ---- post install phase 1 ---
#
# all services need to be up

iam userenv -a env -A
iam userenv -a profile -A

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

# stop all services - end of postinstall phase 1
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

# ---- post install phase 2 ---
#
# all services need to be down

iam weblogic  -a jdk7fix -t identity -H ${oim1}
iam weblogic  -a jdk7fix -t access   -H ${oam1}

iam identity  -a domainfix -H ${oim1}
iam identity  -a domainfix -H ${oim2}

iam access    -a domainfix -H ${oam1}
iam accss     -a domainfix -H ${oam2}

iam identity  -a movelogs  -H ${oim1}
iam identity  -a movelogs  -H ${oim2}
iam access    -a movelogs  -H ${oam1}
iam access    -a movelogs  -H ${oam2}
iam directory -a movelogs  -H ${oud1}
iam directory -a movelogs  -H ${oud2}
iam webtier   -a movelogs  -H ${web1}
iam webtier   -a movelogs  -H ${web2}

iam webtier   -a config    -H ${web1}
iam webtier   -a config    -H ${web2}

echo -e "\nSetup finished successfully!\n"
