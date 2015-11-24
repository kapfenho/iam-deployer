#!/bin/sh

# run IAM Tool steps to deploy OIA
#
set -o errexit
set -o errtrace

export PATH=${DEPLOYER}:${PATH}

iam rcu -a create -t analytics

# /products is shared: install once
iam jdk -a install7 -O analytics

# install weblogic once
iam weblogic -a install -t analytics

# since products/analytics is avail: new env
# cluster: both have -A for all hosts
iam userenv -a env -A
iam userenv -a profile -A

# copy lib files
iam weblogic -a wlstlibs -t analytics

# create cluster domain and distribute
iam analytics -a domcreate -P cluster
iam analytics -a rdeploy -P pack
iam analytics -a rdeploy -P unpack -H oim2

# unpack OIA application
iam analytics -a explode

# configure OIA domain
iam analytics -a domconfig

# configure OIA application instance
iam analytics -a appconfig -P single

# perform OIM-OIA integration steps
iam analytics -a oimintegrate

# deploy OIA application to WLS
iam analytics -a wlsdeploy -P cluster
