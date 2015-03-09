#!/bin/sh

# create log area and link locations.  this script shall be executed 
# on each machine

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

move_logs_onehost() {
  
  local dst=/var/log/fmw
  
  set -o errexit nounset
  set -x
  
  gdom=${INSTALL_APPHOME_DIR}/config/domains
  ldom=${INSTALL_LOCALCONFIG_DIR}/domains
  lins=${INSTALL_LOCALCONFIG_DIR}/instances
  
  echo "-- nodemanager --"
  mkdir -p ${dst}/nodemanager
  
  echo "-- identity domain --"
  mvlog ${gdom}/$IDMPROV_IDENTITY_DOMAIN/servers/AdminServer/logs ${dst}/$IDMPROV_IDENTITY_DOMAIN/AdminServer
  mvlog ${ldom}/$IDMPROV_IDENTITY_DOMAIN/servers/wls_soa1/logs    ${dst}/$IDMPROV_IDENTITY_DOMAIN/wls_soa1
  mvlog ${ldom}/$IDMPROV_IDENTITY_DOMAIN/servers/wls_oim1/logs    ${dst}/$IDMPROV_IDENTITY_DOMAIN/wls_oim1
  
  echo "-- access domain --"
  mvlog ${gdom}/$IDMPROV_ACCESS_DOMAIN/servers/AdminServer/logs   ${dst}/$IDMPROV_ACCESS_DOMAIN/AdminServer
  mvlog ${ldom}/$IDMPROV_ACCESS_DOMAIN/servers/wls_oam1/logs      ${dst}/$IDMPROV_ACCESS_DOMAIN/wls_oam1
  
  echo "-- directoy instance --"
  mvlog ${lins}/oud1/OUD/logs     ${dst}/oud1
  
  echo "-- webtier instance --"
  mvlog ${lins}/ohs1/auditlogs    ${dst}/ohs1/auditlogs
  mvlog ${lins}/ohs1/diagnostics  ${dst}/ohs1/diagnostics
  
  echo "-- done --"
  
  set +x
}
