#!/bin/bash
#
#  IAM single host setup workflow
#
set -o errexit
set -o errtrace

export DEPLOYER
export PATH=${DEPLOYER}:${PATH}
source ${DEPLOYER}/lib/user-config.sh

# create inventory, for lcm only
iam orainv
# install lcm
iam lcminst
# switch off checks
# iam lcmprovmod

# let's do the lcm...
#  skipped:  validate
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
  iam lcmstep -a ${step}
done

exit

# ---- post install phase 1 ---
#
# all services need to be up

iam userenv -a env
iam userenv -a profile

iam weblogic -a wlstlibs -t identity
iam weblogic -a wlstlibs -t access

iam identity -a keyfile -u ${nmUser}   -p ${nmPwd} -n
iam identity -a keyfile -u ${domiUser} -p ${domiPwd}

iam access   -a keyfile -u ${nmUser}   -p ${nmPwd} -n
iam access   -a keyfile -u ${domaUser} -p ${domaPwd}

iam identity -a config
iam access   -a config

# stop all services
$SHELL -l ~/bin/stop-identity
$SHELL -l ~/bin/stop-access
$SHELL -l ~/bin/stop-nodemanager
$SHELL -l ~/bin/stop-dir
$SHELL -l ~/bin/stop-webtier

# ---- post install phase 2 ---
#
# all services need to be down

iam weblogic -a jdk7fix -t identity
iam weblogic -a jdk7fix -t access

iam identity -a domainfix
iam access   -a domainfix

iam identity  -a movelogs
iam access    -a movelogs
iam directory -a movelogs
iam webtier   -a movelogs

iam webtier   -a config

echo -e "\nSetup finished successfully!\n"

