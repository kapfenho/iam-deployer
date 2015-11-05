# oim connectorserver functions

deploy_consrv_dwpldap() {

  local logdir=/var/log/fmw/connectorservers/dwpldap
  local appdir=/opt/fmw/products/connectorservers/dwpldap

  [ -a ${logdir} ] || mkdir -p ${logdir}
  [ -a ${appdir} ] || mkdir -p ${appdir}

}

