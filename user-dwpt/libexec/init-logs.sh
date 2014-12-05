#!/bin/sh

# create log area and link locations.  this script shall be executed 
# on each machine

dst=/var/log/fmw

set -o errexit nounset

mvlog() {
  local src=${1}
  local dst=${2}
  mkdir -p ${dst}
  mv -f ${src}/* ${dst}/
  rm -Rf ${src}
  ln -sf ${dst} ${src}
}

set -x

# nodemanager
mkdir -p ${dst}/nodemanager

# idenitity
mvlog /opt/fmw/config/domains/identity_test/servers/AdminServer/logs \
      ${dst}/identity_test/AdminServer
mvlog /opt/local/fmw/domains/identity_test/servers/wls_soa1/logs \
      ${dst}/identity_test/wls_soa1
mvlog /opt/local/fmw/domains/identity_test/servers/wls_oim1/logs \
      ${dst}/identity_test/wls_oim1

# access
mvlog /opt/fmw/config/domains/access_test/servers/AdminServer/logs \
      ${dst}/access_test/AdminServer
mvlog /opt/local/domains/access_test/servers/wls_oam1/logs \
      ${dst}/access_test/wls_oam1

# directory
mkdir -p ${dst}/oud1
mv   /opt/local/instances/oud1/OUD/logs ${dst}/oud1/
ln -s ${dst}/oud1/logs /opt/local/instances/oud1/OUD/logs

# webtier
mkdir -p ${dst}/ohs1
mv   /opt/local/instances/ohs1/auditlogs   ${dst}/ohs1/
mv   /opt/local/instances/ohs1/diagnostics ${dst}/ohs1/
ln -s ${dst}/ohs1/auditlogs   /opt/local/instances/ohs1/auditlogs
ln -s ${dst}/ohs1/diagnostics /opt/local/instances/ohs1/diagnostics
ln -s ${dst}/ohs1/diagnostics/logs/OHS/ohs1  ${dst}/ohs1/logs

set +x

