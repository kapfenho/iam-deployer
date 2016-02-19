#!/bin/bash
#
#  IAM single host setup workflow
#
set -o errexit
set -o errtrace

export DEPLOYER
export PATH=${DEPLOYER}:${PATH}
source ${DEPLOYER}/lib/user-config.sh

for h in ${provhosts[@]}; do
  if ! ping -q -w 1 ${h} >/dev/null 2>&1 ; then
    echo "Postponing provisioning until host ${h} is available"
    exit 0
  fi
done

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

# deploy user environment in shared location
iam userenv -a env
# on each host: load in user profile and create easy to reach shortcuts 
iam userenv -a profile

# copy weblogic libraries
iam weblogic -a wlstlibs -t identity
iam weblogic -a wlstlibs -t access

# generate keyfiles
iam identity -a keyfile -u ${nmUser}   -p ${nmPwd} -n
iam identity -a keyfile -u ${domiUser} -p ${domiPwd}

iam access   -a keyfile -u ${nmUser}   -p ${nmPwd} -n
iam access   -a keyfile -u ${domaUser} -p ${domaPwd}

# domain configuration
iam identity -a config
iam access   -a config

# stop all services
$SHELL -l ~/bin/stop-identity
$SHELL -l ~/bin/stop-access
$SHELL -l ~/bin/stop-nodemanager
$SHELL -l ~/bin/stop-dir
$SHELL -l ~/bin/stop-webtier

exit 0

iam weblogic -a jdk7fix -t identity
iam weblogic -a jdk7fix -t access

iam identity -a domainfix
iam access   -a domainfix

# identity domain post-install steps
iam identity -a movelogs
iam access   -a movelogs

# webgate installation bug fix
iam webtier -a movelogs
iam webtier -a config

echo -e "\nSetup finished successfully!\n"

