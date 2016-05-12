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
  local wlsoia=""
  local wlsadm=""

  log "Generating OHS config files"
  log "Creating backup archive of original files"

  # backup config
  [[ -a ${bak} ]] || \
    tar --create --gzip --directory=${dst}/.. --file=${bak} ${dst}

  local files=( _app-oim
                _app-oimadmin
                _app-soa
                _app-oam
                _wls-iamdomain
                _wls-oamdomain
                _ssl
                iamadmin.conf
                oamadmin.conf
                idminternal.conf
                sso.conf )

  log "Replacing SSL files"
  cp -f ${src}/ssl.conf ${dst}/

  log "Replacing virtual host files"
  rm -f ${dst}/moduleconf/*
  for f in ${files[@]} ; do
    [ -f ${src}/moduleconf/${f} ] && cp -f ${src}/moduleconf/${f} ${dst}/moduleconf/
  done

  log "Deploying load balancer health check files"
  cp -f ${src}/htdocs/probe.down.html ${dst}/htdocs/
  cp -f ${src}/htdocs/probe.up.html   ${dst}/htdocs/
  cp -f ${src}/htdocs/probe.up.html   ${dst}/htdocs/probe.html

  log "Adjust files to environment hosts"
  # adminserver iam
  wlsdom1+="WebLogicHost ${IDMPROV_OIMDOMAIN_ADMINSERVER_HOST}\\"$'\n'
  wlsdom1+="        WebLogicPort ${IDMPROV_OIMDOMAIN_ADMINSERVER_PORT}"
  # adminserver oia
  wlsdom2+="WebLogicHost ${IDMPROV_OIADOMAIN_ADMINSERVER_HOST}\\"$'\n'
  wlsdom2+="        WebLogicPort ${IDMPROV_OIADOMAIN_ADMINSERVER_PORT}"
  # adminserver oia
  wlsdom3+="WebLogicHost ${IDMPROV_IDMDOMAIN_ADMINSERVER_HOST}\\"$'\n'
  wlsdom3+="        WebLogicPort ${IDMPROV_IDMDOMAIN_ADMINSERVER_PORT}"

  if [ "${DT_SINGLEHOST}" == "true" ] ; then
    # oam
    wlsoam+="WebLogicHost $(hostname -f)\\"$'\n'
    wlsoam+="        WebLogicPort ${IDMPROV_OAM_PORT}"
    # oim
    wlsoim+="WebLogicHost $(hostname -f)\\"$'\n'
    wlsoim+="        WebLogicPort ${IDMPROV_OIM_PORT}"
    # soa
    wlssoa+="WebLogicHost $(hostname -f)\\"$'\n'
    wlssoa+="        WebLogicPort ${IDMPROV_SOA_PORT}"
    # bip
    wlsbip+="WebLogicHost $(hostname -f)\\"$'\n'
    wlsbip+="        WebLogicPort ${IDMPROV_BIP_PORT}"
    # oia
    wlsoia+="WebLogicHost $(hostname -f)\\"$'\n'
    wlsoia+="        WebLogicPort ${IDMPROV_OIA_PORT}"
  else
    # oam cluster
    wlsoam+="WebLogicCluster "
    wlsoam+="${IDMPROV_OAM_HOST}:"
    wlsoam+="${IDMPROV_OAM_PORT},"
    wlsoam+="${IDMPROV_SECOND_OAM_HOST}:"
    wlsoam+="${IDMPROV_SECOND_OAM_PORT}"
    # oim cluster
    wlsoim+="WebLogicCluster "
    wlsoim+="${IDMPROV_OIM_HOST}:"
    wlsoim+="${IDMPROV_OIM_PORT},"
    wlsoim+="${IDMPROV_SECOND_OIM_HOST}:"
    wlsoim+="${IDMPROV_SECOND_OIM_PORT}"
    # soa cluster
    wlssoa+="WebLogicCluster "
    wlssoa+="${IDMPROV_SOA_HOST}:"
    wlssoa+="${IDMPROV_SOA_PORT},"
    wlssoa+="${IDMPROV_SECOND_SOA_HOST}:"
    wlssoa+="${IDMPROV_SECOND_SOA_PORT}"
    # bip cluster
    wlsbip+="WebLogicCluster "
    wlsbip+="${IDMPROV_BIP_HOST}:"
    wlsbip+="${IDMPROV_BIP_PORT},"
    wlsbip+="${IDMPROV_SECOND_BIP_HOST}:"
    wlsbip+="${IDMPROV_SECOND_BIP_PORT}"
    # oia cluster
    wlsoia+="WebLogicCluster "
    wlsoia+="${IDMPROV_OIA_HOST}:"
    wlsoia+="${IDMPROV_OIA_PORT},"
    wlsoia+="${IDMPROV_SECOND_OIA_HOST}:"
    wlsoia+="${IDMPROV_SECOND_OIA_PORT}"
  fi

  # now we do the substi thing, in place
  #
  for f in ${files[@]} ; do
    [ -f ${dst}/moduleconf/${f} ] && \
    sed -i -e "s/__WLS_VH_FRONTEND__/${IDMPROV_LBR_SSO_HOST}/g" \
           -e "s/__WLS_VH_IDMINTERNAL__/${IDMPROV_LBR_OIMINTERNAL_HOST}/g" \
           -e "s/__WLS_VH_IAMADMIN__/${IDMPROV_LBR_OIMADMIN_HOST}/g" \
           -e "s/__WLS_VH_OIAADMIN__/${IDMPROV_LBR_OIAADMIN_HOST}/g" \
           -e "s/__WLS_IAMADMINSERVER__/${wlsdom1}/g" \
           -e "s/__WLS_OIAADMINSERVER__/${wlsdom2}/g" \
           -e "s/__WLS_IDMADMINSERVER__/${wlsdom3}/g" \
           -e "s/__WLS_OIA__/${wlsoia}/g" \
           -e "s/__WLS_OAM__/${wlsoam}/g" \
           -e "s/__WLS_OIM__/${wlsoim}/g" \
           -e "s/__WLS_BIP__/${wlsbip}/g" \
           -e "s/__WLS_SOA__/${wlssoa}/g" ${dst}/moduleconf/${f}
  done

}

