#!/bin/bash

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
  log "WL_HOME already patch, nothing to do"
else
  patch -b ${WL_HOME}/common/bin/commEnv.sh <${src}/wl_home/commEnv.sh.patch
  log "WL_HOME patched: ${WL_HOME}"
fi

# admin domain
if ! [ -a ${ADMIN_HOME}/bin/setCustDomainEnv.sh ]; then
  cp ${src}/domain/setCustDomainEnv.sh ${ADMIN_HOME}/bin/
fi

if ! grep setCustDomainEnv ${ADMIN_HOME}/bin/setDomainEnv.sh >/dev/null 2>&1 ; then
  patch -b ${ADMIN_HOME}/bin/setDomainEnv.sh <${src}/domain/setDomainEnv.sh.patch
  log "ADMIN_HOME patched: ${ADMIN_HOME}"
fi

# local domain
if ! [ -a ${WRK_HOME}/bin/setCustDomainEnv.sh ]; then
  cp ${src}/domain/setCustDomainEnv.sh ${WRK_HOME}/bin/
fi

if ! grep setCustDomainEnv ${WRK_HOME}/bin/setDomainEnv.sh >/dev/null 2>&1 ; then
  patch -b ${WRK_HOME}/bin/setDomainEnv.sh <${src}/domain/setDomainEnv.sh.patch
  log "WRK_HOME patched: ${WRK_HOME}"
fi

