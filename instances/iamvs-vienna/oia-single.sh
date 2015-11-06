#!/bin/sh

# run IAM Tool steps to deploy OIA
#

export PATH=${DEPLOYER}:${PATH}

# # create DB Schemas
# echo ""
# echo ""
# echo "#### OIA DEPLOYMENT: creating DB Schemas"
# echo ""
# echo ""
# ${DEPLOYER}/user-config/oia/fallback/fallback.sh

# install JDK7 for OIA Domain
echo ""
echo ""
echo "#### OIA DEPLOYMENT: installing JDK7"
echo ""
echo ""
iam jdk -a install7 -O analytics

# install WLS
echo ""
echo ""
echo "#### OIA DEPLOYMENT: installing WLS"
echo ""
echo ""
iam weblogic -a install -t analytics

iam userenv -a env
# on each host: load in user profile and create easy to reach shortcuts 
iam userenv -a profile

iam weblogic -a wlstlibs -t analytics
# 
# create OIA domain and managed servers
echo ""
echo ""
echo "#### OIA DEPLOYMENT: Creating WLS Domain and OIA Managed Server."
echo ""
echo ""
#iam analytics -a domcreate -H iamvs
iam analytics -a domcreate -P single

# unpack OIA application
echo ""
echo ""
echo "#### OIA DEPLOYMENT: unpacking OIA application"
echo ""
echo ""
iam analytics -a explode

# configure OIA domain
echo ""
echo ""
echo "#### OIA DEPLOYMENT: Configuring OIA Domain (setDomainEnv.sh)"
echo ""
echo ""
iam analytics -a domconfig

# configure OIA application instance
echo ""
echo ""
echo "#### OIA DEPLOYMENT: configuring OIA application"
echo ""
echo ""
iam analytics -a appconfig -P single

# perform OIM-OIA integration steps
echo ""
echo ""
echo "#### OIA DEPLOYMENT: performing OIA-OIM integration steps"
echo ""
echo ""
iam analytics -a oimintegrate

# deploy OIA application to WLS
echo ""
echo ""
echo "#### OIA DEPLOYMENT: deploying OIA application to WLS"
echo ""
echo ""
iam analytics -a wlsdeploy -P single
