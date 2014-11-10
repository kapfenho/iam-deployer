#!/bin/sh

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
  echo "oim1"
  mkdir -p /var/log/fmw/nodemanager
  mvlog /opt/fmw/config/domains/identity_test/servers/AdminServer/logs \
        /var/log/fmw/identity_test/AdminServer
  mvlog /opt/local/domains/identity_test/servers/wls_soa1/logs \
        /var/log/fmw/identity_test/wls_soa1
  mvlog /opt/local/domains/identity_test/servers/wls_oim1/logs \
        /var/log/fmw/identity_test/wls_oim1
  ;;
oim2)
  echo "oim2"
  mkdir -p /var/log/fmw/nodemanager
  mvlog /opt/local/domains/identity_test/servers/wls_soa2/logs \
        /var/log/fmw/identity_test/wls_soa2
  mvlog /opt/local/domains/identity_test/servers/wls_oim2/logs \
        /var/log/fmw/identity_test/wls_oim2
  ;;
oam1)
  echo "oam1"
  mkdir -p /var/log/fmw/nodemanager
  mvlog /opt/fmw/config/domains/access_test/servers/AdminServer/logs \
        /var/log/fmw/access_test/AdminServer
  mvlog /opt/local/domains/access_test/servers/wls_oam1/logs \
        /var/log/fmw/access_test/wls_oam1
  ;;
oam2)
  echo "oam2"
  mkdir -p /var/log/fmw/nodemanager
  mvlog /opt/local/domains/access_test/servers/wls_oam2/logs \
        /var/log/fmw/access_test/wls_oam2
  ;;
oud1)
  echo "oud1"
  mkdir -p /var/log/fmw/oud1
  mv   /opt/local/instances/oud1/OUD/logs /var/log/fmw/oud1/
  ln -s /var/log/fmw/oud1/logs /opt/local/instances/oud1/OUD/logs
  ;;
oud2)
  echo "oud2"
  mkdir -p /var/log/fmw/oud2
  mv   /opt/local/instances/oud2/OUD/logs /var/log/fmw/oud2/
  ln -s /var/log/fmw/oud2/logs /opt/local/instances/oud2/OUD/logs
  ;;
web1)
  echo "web1"
  mkdir -p /var/log/fmw/ohs1
  mv   /opt/local/instances/ohs1/auditlogs   /var/log/fmw/ohs1/
  mv   /opt/local/instances/ohs1/diagnostics /var/log/fmw/ohs1/
  ln -s /var/log/fmw/ohs1/auditlogs   /opt/local/instances/ohs1/auditlogs
  ln -s /var/log/fmw/ohs1/diagnostics /opt/local/instances/ohs1/diagnostics
  ln -s /var/log/fmw/ohs1/diagnostics/logs/OHS/ohs1  /var/log/fmw/ohs1/logs
  ;;
web2)
  echo "web2"
  mkdir -p /var/log/fmw/ohs2
  mv   /opt/local/instances/ohs2/auditlogs   /var/log/fmw/ohs2/
  mv   /opt/local/instances/ohs2/diagnostics /var/log/fmw/ohs2/
  ln -s /var/log/fmw/ohs2/auditlogs   /opt/local/instances/ohs2/auditlogs
  ln -s /var/log/fmw/ohs2/diagnostics /opt/local/instances/ohs2/diagnostics
  ln -s /var/log/fmw/ohs2/diagnostics/logs/OHS/ohs2  /var/log/fmw/ohs2/logs
  ;;
esac

