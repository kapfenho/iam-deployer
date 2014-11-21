#!/bin/sh

# the patches correct bugs of the default configuration:
#   * several concurrent jvm memory options are stated
#   * jvm runs in client mode (dev and prod mode)
#   * jvm options are not jdk7 compatible
#

set -o errexit nounset

if [ ${#} -lt 1 -o -z ${1} ] ; then
  echo "ERROR: Parameter missing"
  echo "example:  ${0} /vagrant/lib/access"
  echo
  exit 0
fi

src=${1}

patch -b ${WL_HOME}/common/bin/commEnv.sh   <${src}/wl_home/commEnv.sh.patch
patch -b ${DOMAIN_HOME}/bin/setDomainEnv.sh <${src}/domain/setDomainEnv.sh.patch

cp ${src}/domain/setCustDomainEnv.sh ${DOMAIN_HOME}/bin/

