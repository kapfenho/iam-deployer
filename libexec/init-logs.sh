#!/bin/sh

# create log area and link locations.  this script shall be executed 
# on each machine

dst=/var/log/fmw

set -o errexit nounset

mvlog() {
  src=${1}
  dst=${2}
  mkdir -p ${dst}
  mv "${src}/*" ${dst}/
  rm -Rf ${src}
  ln -s ${dst} ${src}
}

set -x
case "$(hostname -s)" in
oim1)
  mkdir -p ${dst}/nodemanager
  mvlog /opt/fmw/config/domains/identity_test/servers/AdminServer/logs \
        ${dst}/identity_test/AdminServer
  mvlog /opt/local/domains/identity_test/servers/wls_soa1/logs \
        ${dst}/identity_test/wls_soa1
  mvlog /opt/local/domains/identity_test/servers/wls_oim1/logs \
        ${dst}/identity_test/wls_oim1
  ;;
oim2)
  mkdir -p ${dst}/nodemanager
  mvlog /opt/local/domains/identity_test/servers/wls_soa2/logs \
        ${dst}/identity_test/wls_soa2
  mvlog /opt/local/domains/identity_test/servers/wls_oim2/logs \
        ${dst}/identity_test/wls_oim2
  ;;
oam1)
  mkdir -p ${dst}/nodemanager
  mvlog /opt/fmw/config/domains/access_test/servers/AdminServer/logs \
        ${dst}/access_test/AdminServer
  mvlog /opt/local/domains/access_test/servers/wls_oam1/logs \
        ${dst}/access_test/wls_oam1
  ;;
oam2)
  mkdir -p ${dst}/nodemanager
  mvlog /opt/local/domains/access_test/servers/wls_oam2/logs \
        ${dst}/access_test/wls_oam2
  ;;
oud1)
  mkdir -p ${dst}/oud1
  mv   /opt/local/instances/oud1/OUD/logs ${dst}/oud1/
  ln -s ${dst}/oud1/logs /opt/local/instances/oud1/OUD/logs
  ;;
oud2)
  mkdir -p ${dst}/oud2
  mv   /opt/local/instances/oud2/OUD/logs ${dst}/oud2/
  ln -s ${dst}/oud2/logs /opt/local/instances/oud2/OUD/logs
  ;;
web1)
  mkdir -p ${dst}/ohs1
  mv   /opt/local/instances/ohs1/auditlogs   ${dst}/ohs1/
  mv   /opt/local/instances/ohs1/diagnostics ${dst}/ohs1/
  ln -s ${dst}/ohs1/auditlogs   /opt/local/instances/ohs1/auditlogs
  ln -s ${dst}/ohs1/diagnostics /opt/local/instances/ohs1/diagnostics
  ln -s ${dst}/ohs1/diagnostics/logs/OHS/ohs1  ${dst}/ohs1/logs
  ;;
web2)
  mkdir -p ${dst}/ohs2
  mv   /opt/local/instances/ohs2/auditlogs   ${dst}/ohs2/
  mv   /opt/local/instances/ohs2/diagnostics ${dst}/ohs2/
  ln -s ${dst}/ohs2/auditlogs   /opt/local/instances/ohs2/auditlogs
  ln -s ${dst}/ohs2/diagnostics /opt/local/instances/ohs2/diagnostics
  ln -s ${dst}/ohs2/diagnostics/logs/OHS/ohs2  ${dst}/ohs2/logs
  ;;
esac

