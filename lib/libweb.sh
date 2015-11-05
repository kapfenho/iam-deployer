# web frontend reverse proxy functions

#  generate the ohs/apache config files. we introduce a more modular 
#  approach here and replace the original files - after creating a 
#  backup. the templates need to be filled with the virtual hostnames 
#  and the connections to the app servers.
#
httpd_config() {
  # backup original configs
  local src=${DEPLOYER}/lib/templates/web
  local dst=${INST_HOME}/config/OHS/${INSTANCE}
  local bak=${dst}-orig.tgz
  local wlsoim=""
  local wlssoa=""
  local wlsadm=""

  log "Generating OHS config files"
  log "Creating backup archive of original files"

  # backup config
  [[ -a ${bak} ]] || \
    tar --create --gzip --directory=${dst}/.. --file=${bak} ${dst}

  local files=( app-oim.conf
                app-oimadmin.conf
                app-soa.conf
                iam-admin.conf
                iam-backend.conf
                iam-frontend.conf
                sslvh.conf )

  log "Replacing SSL files"
  cp -f ${src}/ssl.conf ${dst}/

  log "Replacing virtual host files"
  for f in ${files[@]} ; do
    cp -f ${src}/moduleconf/${f} ${dst}/moduleconf/
  done

  log "Deploying load balancer health check files"
  cp -f ${src}/htdocs/probe.down.html ${dst}/htdocs/
  cp -f ${src}/htdocs/probe.up.html   ${dst}/htdocs/
  cp -f ${src}/htdocs/probe.up.html   ${dst}/htdocs/probe.html

  log "Adjust files to environment hosts"
  # adminserver
  wlsadm+="        WebLogicHost ${IDMPROV_OIMDOMAIN_ADMINSERVER_HOST}"$'\n'
  wlsadm+="        WebLogicPort ${IDMPROV_OIMDOMAIN_ADMINSERVER_PORT}"

  # prepare the substitution values, in mod_wls clusters use 
  # different syntax
  #
  if [ "${DT_SINGLEHOST}" == "true" ] ; then
    # oim
    wlsoim+="        WebLogicHost $(hostname -f)"$'\n'
    wlsoim+="        WebLogicPort ${IDMPROV_OIM_PORT}"
    # soa
    wlssoa+="        WebLogicHost $(hostname -f)"$'\n'
    wlssoa+="        WebLogicPort ${IDMPROV_SOA_PORT}"
  else
    # oim cluster
    wlsoim+="        WebLogicCluster "
    wlsoim+="${IDMPROV_OIM_HOST}:"
    wlsoim+="${IDMPROV_OIM_PORT},"
    wlsoim+="${IDMPROV_SECOND_OIM_HOST}:"
    wlsoim+="${IDMPROV_SECOND_OIM_PORT}"
    # soa cluster
    wlssoa+="        WebLogicCluster "
    wlssoa+="${IDMPROV_SOA_HOST}:"
    wlssoa+="${IDMPROV_SOA_PORT},"
    wlssoa+="${IDMPROV_SECOND_SOA_HOST}:"
    wlssoa+="${IDMPROV_SECOND_SOA_PORT}"
  fi

  # now we do the substi thing, in place
  #
  for fn in ${files[@]} ; do
    f=${dst}/moduleconf/${fn}
    sed -i "s/__WLS_VH_FRONTEND__/${IDMPROV_LBR_SSO_HOST}/g" ${f}
    sed -i "s/__WLS_VH_BACKEND__/${IDMPROV_LBR_OIMINTERNAL_HOST}/g" ${f}
    sed -i "s/__WLS_VH_ADMIN__/${IDMPROV_LBR_OIMINTERNAL_HOST}/g" ${f}

    sed -i "s/__WLS_ADMINSERVER__/${wlsadm}/g" ${f}
    sed -i "s/__WLS_OIM__/${wlsoim}/g" ${f}
    sed -i "s/__WLS_SOA__/${wlssoa}/g" ${f}
  done


}

