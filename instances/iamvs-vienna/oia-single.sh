#!/bin/sh
#
#  Oracle Identity Analytics - Single Host
#
set -o errexit
set -o errtrace

export PATH=${DEPLOYER}:${PATH}

# check nodemanager
if ! pgrep -f '\ weblogic\.NodeManager' >/dev/null ; then
  echo "ERROR: nodemanager on node 1 not running!" ; exit 80
fi

echo "Confirm you have executed >iam remove -t analytics< with ENTER"
read nil

. ${DEPLOYER}/user-config/iam.config
mkdir -p ${iam_analytics_home}

# create schema
iam rcu -a create -t analytics

# install jdk7 in home analytics
iam jdk -a install7 -O analytics

# install weblogic
iam weblogic -a install -t analytics

# create env files and scripts
iam userenv -a env
iam userenv -a profile

# copy lib files
iam weblogic -a wlstlibs -t analytics

# create domain
iam analytics -a domcreate -T single

# unpack OIA application
iam analytics -a explode

# configure OIA domain
iam analytics -a domconfig

# configure OIA application instance
iam analytics -a appconfig -T single

# perform OIM-OIA integration steps
iam analytics -a oimintegrate

# deploy OIA application to WLS
iam analytics -a wlsdeploy

~/bin/stop-analytics
~/bin/start-analytics

echo -e "\n >>  Setup finished successfully"

