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

idmdom=${IDMPROV_IDENTITY_DOMAIN}
accdom=${IDMPROV_ACCESS_DOMAIN}

if [ -z ${idmdom} ] ; then
  error "Env variable IDMPROV_IDENTITY_DOMAIN not defined"
  exit 81
fi

set -x
case "$(hostname -s)" in
  dwpidmdev02 | dwptoim[34] )
    mkdir -p ${dst}/{nodemanager,${idmdom},${accdom},oud1,ohs1}
    mvlog /opt/fmw/config/domains/${idmdom}/servers/AdminServer/logs ${dst}/${idmdom}/AdminServer
    mvlog /opt/local/${lfmw}/domains/${idmdom}/servers/wls_soa1/logs ${dst}/${idmdom}/wls_soa1
    mvlog /opt/local/${lfmw}/domains/${idmdom}/servers/wls_oim1/logs ${dst}/${idmdom}/wls_oim1
    mvlog /opt/fmw/config/domains/${accdom}/servers/AdminServer/logs ${dst}/${accdom}/AdminServer
    mvlog /opt/local/${lfmw}/domains/${accdom}/servers/wls_oam1/logs ${dst}/${accdom}/wls_oam1
    oudins=oud1
    mkdir -p ${dst}/${oudins}
    mvlog /opt/local/${lfmw}/instances/${oudins}/OUD/logs            ${dst}/${oudins}/logs
    ohsins=ohs1
    mkdir -p ${dst}/${ohsins}
    mvlog /opt/local/${lfmw}/instances/${ohsins}/auditlogs                      ${dst}/${ohsins}/auditlogs
    mvlog /opt/local/${lfmw}/instances/${ohsins}/diagnostics/logs/OHS/${ohsins} ${dst}/${ohsins}/logs
    mvlog /opt/local/${lfmw}/instances/${ohsins}/diagnostics/logs/OPMN/opmn     ${dst}/${ohsins}/opmn
    ;;
  dwp[tp]oim1 )
    mkdir -p ${dst}/nodemanager
    mvlog /opt/fmw/config/domains/${idmdom}/servers/AdminServer/logs ${dst}/${idmdom}/AdminServer
    mvlog /opt/local/${lfmw}/domains/${idmdom}/servers/wls_soa1/logs ${dst}/${idmdom}/wls_soa1
    mvlog /opt/local/${lfmw}/domains/${idmdom}/servers/wls_oim1/logs ${dst}/${idmdom}/wls_oim1
    ;;
  dwp[tp]oim2 )
    mkdir -p ${dst}/nodemanager
    mvlog /opt/local/${lfmw}/domains/${idmdom}/servers/wls_soa2/logs ${dst}/${idmdom}/wls_soa2
    mvlog /opt/local/${lfmw}/domains/${idmdom}/servers/wls_oim2/logs ${dst}/${idmdom}/wls_oim2
    ;;
  dwp[tp]oam1 )
    mkdir -p ${dst}/nodemanager
    mvlog /opt/fmw/config/domains/${accdom}/servers/AdminServer/logs ${dst}/${accdom}/AdminServer
    mvlog /opt/local/${lfmw}/domains/${accdom}/servers/wls_oam1/logs ${dst}/${accdom}/wls_oam1
    ;;
  dwp[tp]oam2 )
    mkdir -p ${dst}/nodemanager
    mvlog /opt/local/${lfmw}/domains/${accdom}/servers/wls_oam2/logs ${dst}/${accdom}/wls_oam2
    ;;
  dwp[tp]oud1 )
    oudins=oud1
    mkdir -p ${dst}/${oudins}
    mvlog /opt/local/${lfmw}/instances/${oudins}/OUD/logs            ${dst}/${oudins}/logs
    ;;
  dwp[tp]oud2 )
    oudins=oud2
    mkdir -p ${dst}/${oudins}
    mvlog /opt/local/${lfmw}/instances/${oudins}/OUD/logs            ${dst}/${oudins}/logs
    ;;
  dwp[tp]idw1 )
    ohsins=ohs1
    mkdir -p ${dst}/${ohsins}
    mvlog /opt/local/${lfmw}/instances/${ohsins}/auditlogs                      ${dst}/${ohsins}/auditlogs
    mvlog /opt/local/${lfmw}/instances/${ohsins}/diagnostics/logs/OHS/${ohsins} ${dst}/${ohsins}/logs
    mvlog /opt/local/${lfmw}/instances/${ohsins}/diagnostics/logs/OPMN/opmn     ${dst}/${ohsins}/opmn
    ;;
  dwp[tp]idw2 )
    ohsins=ohs2
    mkdir -p ${dst}/${ohsins}
    mvlog /opt/local/${lfmw}/instances/${ohsins}/auditlogs                      ${dst}/${ohsins}/auditlogs
    mvlog /opt/local/${lfmw}/instances/${ohsins}/diagnostics/logs/OHS/${ohsins} ${dst}/${ohsins}/logs
    mvlog /opt/local/${lfmw}/instances/${ohsins}/diagnostics/logs/OPMN/opmn     ${dst}/${ohsins}/opmn
    ;;
esac

