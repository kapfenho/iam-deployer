#!/bin/sh

# create log area and link locations.  this script shall be executed 
# on each machine

dst=/var/log/fmw

set -o errexit nounset

mvlog() {
  local src=${1}
  local dst=${2}
  if [ -h ${src} ] ; then
    echo "** Already moved dir ${src}"
    ls -l ${src}
  else
    mkdir -p ${dst}
    rm -Rf   ${dst}/*
    mv -f    ${src}/* ${dst}/
    rm -Rf   ${src}
    ln -sf   ${dst} ${src}
  fi
}

set -x

gdom=/opt/fmw/config/domains
ldom=/opt/local/domains
lins=/opt/local/instances

echo "-- nodemanager --"
mkdir -p ${dst}/nodemanager

echo "-- identity domain --"
mvlog ${gdom}/identity_test/servers/AdminServer/logs ${dst}/identity_test/AdminServer
mvlog ${ldom}/identity_test/servers/wls_soa1/logs    ${dst}/identity_test/wls_soa1
mvlog ${ldom}/identity_test/servers/wls_oim1/logs    ${dst}/identity_test/wls_oim1

echo "-- access domain --"
mvlog ${gdom}/access_test/servers/AdminServer/logs   ${dst}/access_test/AdminServer
mvlog ${ldom}/access_test/servers/wls_oam1/logs      ${dst}/access_test/wls_oam1

echo "-- directoy instance --"
mvlog ${lins}/oud1/OUD/logs     ${dst}/oud1

echo "-- webtier instance --"
mvlog ${lins}/ohs1/auditlogs    ${dst}/ohs1/auditlogs
mvlog ${lins}/ohs1/diagnostics  ${dst}/ohs1/diagnostics

echo "-- done --"

set +x

