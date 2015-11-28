#!/bin/sh

# run IAM Tool steps to deploy OIA
#
set -o errexit
set -o errtrace

export PATH=${DEPLOYER}:${PATH}

pgrep -f '\ weblogic\.NodeManager' >/dev/null || start-nodemanager

iam rcu -a create -t analytics

iam jdk -a install7 -O analytics

iam weblogic -a install -t analytics

iam userenv -a env
iam userenv -a profile

iam weblogic -a wlstlibs -t analytics

iam analytics -a domcreate -P single

# unpack OIA application
iam analytics -a explode

# configure OIA domain
iam analytics -a domconfig

# configure OIA application instance
iam analytics -a appconfig -P single

# perform OIM-OIA integration steps
iam analytics -a oimintegrate

# deploy OIA application to WLS
iam analytics -a wlsdeploy -P single

echo -e "\nFinished successfully"

