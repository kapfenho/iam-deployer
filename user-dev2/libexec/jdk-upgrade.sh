#!/bin/sh

# patch weblogic domain for jdk7
# domains must be down

set -o errexit nounset

deployer=${DEPLOYER}

if [ -z "${deployer}" ] 
then
  echo "ERROR: Environment variable DEPLOYER not set!"
  echo
  exit 77
fi
 
# access
#
(
source ${HOME}/.env/acc.env
set -x
if grep jdk6 ${DOMAIN_HOME}/bin/setDomainEnv.sh >/dev/null
then
  echo "Patching Access Domain"
  patch -b ${WL_HOME}/common/bin/commEnv.sh   <${deployer}/lib/access/wl_home/commEnv.sh.patch

  patch -b ${DOMAIN_HOME}/bin/setDomainEnv.sh <${deployer}/lib/access/domain/setDomainEnv.sh.patch
  cp ${deployer}/user-config/access/setCustDomainEnv.sh ${DOMAIN_HOME}/bin/

  patch -b ${WRK_HOME}/bin/setDomainEnv.sh    <${deployer}/lib/access/domain/setDomainEnv.sh.patch
  cp ${deployer}/user-config/access/setCustDomainEnv.sh ${WRK_HOME}/bin/
else
  echo "Access Domain already patched!"
fi
set +x
)


# identity
#
(
source ${HOME}/.env/idm.env
set -x
if grep jdk6 ${DOMAIN_HOME}/bin/setDomainEnv.sh >/dev/null
then
  echo "Patching Identity Domain"
  patch -b ${WL_HOME}/common/bin/commEnv.sh   <${deployer}/lib/identity/wl_home/commEnv.sh.patch

  patch -b ${ADMIN_HOME}/bin/setDomainEnv.sh  <${deployer}/lib/identity/domain/setDomainEnv.sh.patch
  cp ${deployer}/user-config/access/setCustDomainEnv.sh ${ADMIN_HOME}/bin/

  patch -b ${DOMAIN_HOME}/bin/setDomainEnv.sh <${deployer}/lib/identity/domain/setDomainEnv.sh.patch
  cp ${deployer}/user-config/access/setCustDomainEnv.sh ${DOMAIN_HOME}/bin/
else
  echo "Identity Domain already patched!"
fi
set +x
)

