#!/bin/sh

# run IAM Tool steps to deploy OIA
#
set -o errexit
set -o errtrace

oim1=bsul0355.fs01.vwf.vwfs-ad
oim2=bsul0356.fs01.vwf.vwfs-ad
oia1=$oim1
oia2=$oim2
web1=$oim1
web2=$oim2

export PATH=${DEPLOYER}:${PATH}

# check nodemanager
if ! ssh $oia2 pgrep -f '\ weblogic\.NodeManager' >/dev/null ; then
  echo "ERROR: nodemanager on node 2 not running!" ; exit 80
elif ! pgrep -f '\ weblogic\.NodeManager' >/dev/null ; then
  echo "ERROR: nodemanager on node 1 not running!" ; exit 80
fi

echo "Confirm you have executed >iam remove -t analytics -A< with ENTER"
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
iam userenv -a env -H $oia1
iam userenv -a env -H $oia2
iam userenv -a profile -H $oia1
iam userenv -a profile -H $oia1

# copy lib files
iam weblogic -a wlstlibs -t analytics

# create cluster domain and distribute
iam analytics -a domcreate -T cluster
iam analytics -a rdeploy -P pack   -H $oia1
iam analytics -a rdeploy -P unpack -H $oia2

# unpack OIA application
iam analytics -a explode

# configure OIA domain
iam analytics -a domconfig -H $oia1
iam analytics -a domconfig -H $oia2

# configure OIA application instance
iam analytics -a appconfig -T cluster

# perform OIM-OIA integration steps
iam analytics -a oimintegrate

# deploy OIA application to WLS
iam analytics -a wlsdeploy

~/bin/stop-analytics
~/bin/start-analytics

echo -e "\nFinished successfully"

