#!/bin/sh

if [ -z $DEPLOYER ]
then
  echo "ERROR: Environment variable DEPLOYER not set!"
  echo
  exit 70
fi

base=/opt/fmw/config/deploy/imint
src=${DEPLOYER}/lib/templates/imint
srvconf=/opt/local/domains/identity_dev02/servers/wls_oim1/data/nodemanager/startup.properties

mkdir -p ${base}/{current,new,archive}
mkdir -p ${base}/current/{config,plan}

[ -a ${base}/current/config/README.markdown ] || cp ${src}/README.markdown ${base}/current/config/
[ -a ${base}/current/config/imint.yml       ] || cp ${src}/imint.yml       ${base}/current/config/
[ -a ${base}/current/plan/Plan.xml          ] || cp ${src}/Plan.xml        ${base}/current/plan/

mkdir -p /opt/local/domains/identity_dev02/servers/wls_oim1/data/nodemanager
cp ${DEPLOYER}/user-config/identity/startup.properties /opt/local/domains/identity_dev02/servers/wls_oim1/data/nodemanager/

if [ -a ${base}/new/imint* ]
then 
  echo "Application package found - now deploying..."
  (
    . ${HOME}/.env/idm.env
    deploy imint
  )
else
  echo "ERROR: application package not found!"
  echo "       search path: ${base}/new/imint*"
  echo "Put package there and restart $0"
  echo
  exit 71
fi


