#!/bin/sh

# the patches correct bugs of the default configuration:
#   * several concurrent jvm memory options are stated
#   * jvm runs in client mode (dev and prod mode)
#   * jvm options are not jdk7 compatible
#

if [ $# -ne 1 ] ; then
  echo "ERROR: Parameter missing"
  echo "example:  ${0} /vagrant/lib/access"
  echo
  exit 0
fi

src=${1}

set -o errexit nounset
set -x

# wl_home
if grep -e 'PRODUCTION_MODE="true"' ${WL_HOME}/common/bin/commEnv.sh >/dev/null ; then
  echo "WL_HOME already patch, nothing to do"
  echo
else
  patch -b ${WL_HOME}/common/bin/commEnv.sh <${src}/wl_home/commEnv.sh.patch
fi

# admin domain
if [ -a ${DOMAIN_HOME}/bin/setCustDomainEnv.sh ]; then
  echo "DOMAIN_HOME already patch, nothing to do"
  echo
else
  cp ${src}/domain/setCustDomainEnv.sh ${DOMAIN_HOME}/bin/
  patch -b ${DOMAIN_HOME}/bin/setDomainEnv.sh <${src}/domain/setDomainEnv.sh.patch
fi

# local domain
if [ -a ${WRK_HOME}/bin/setCustDomainEnv.sh ]; then
  echo "WRK_HOME already patch, nothing to do"
  echo
else
  cp ${src}/domain/setCustDomainEnv.sh ${WRK_HOME}/bin/
  patch -b ${WRK_HOME}/bin/setDomainEnv.sh <${src}/domain/setDomainEnv.sh.patch
fi

