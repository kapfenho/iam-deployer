# web frontend reverse proxy functions

# private helper function for substitution of all weblogic connection 
# placeholders.
#
_prov_connections() {
  local cf=${1}
  sed -e "s/PROV_CONN_OIMADM/${PROV_CONN_OIMADM}/g" \
      -e "s/PROV_CONN_OAMADM/${PROV_CONN_OAMADM}/g" \
      -e "s/PROV_CONN_OIM/${PROV_CONN_OIM}/g" \
      -e "s/PROV_CONN_SOA/${PROV_CONN_SOA}/g" \
      -e "s/PROV_CONN_OAM/${PROV_CONN_OAM}/g" \
      -i.a ${cf}
}

# generate the ohs/apache config files
#    httpd.conf
#    sso-base.conf
#    sso.conf
#    moduleconf/idm.conf
#    moduleconf/oimadm.conf
#    moduleconf/oamadm.conf
#    moduleconf/idminternal.conf
#    moduleconf/sso.conf
#
# param 1: output directory, directory of httpd.conf
# param 2: full qualified hostname of webserver
#
generate_httpd_config() {
  outdir=${1}
  webhost=${2}

  . ${DEPLOYER}/user-config/iam.config

  [ -a ${outdir}/moduleconf ] || mkdir -p ${outdir}/moduleconf

  cf=$(mktemp /tmp/vhostconfig-XXXXXX)

  sed "s/PROV_HEADER_IDM/${PROV_HEADER_IDM}/g" \
    ${DEPLOYER}/lib/templates/web/moduleconf/idm.conf > ${cf}
  _prov_connections ${cf}
  cat ${cf} > ${outdir}/moduleconf/idm.conf
  
  sed "s/PROV_HEADER_OAMADM/${PROV_HEADER_OAMADM}/g" \
    ${DEPLOYER}/lib/templates/web/moduleconf/oamadm.conf > ${cf}
  _prov_connections ${cf}
  cat ${cf} > ${outdir}/moduleconf/oamadm.conf
  
  sed "s/PROV_HEADER_OIMADM/${PROV_HEADER_OIMADM}/g" \
    ${DEPLOYER}/lib/templates/web/moduleconf/oimadm.conf > ${cf}
  _prov_connections ${cf}
  cat ${cf} > ${outdir}/moduleconf/oimadm.conf
  
  sed "s/PROV_HEADER_IDMINTERNAL/${PROV_HEADER_IDMINTERNAL}/g" \
    ${DEPLOYER}/lib/templates/web/moduleconf/idminternal.conf > ${cf}
  _prov_connections ${cf}
  cat ${cf} > ${outdir}/moduleconf/idminternal.conf

  sed "s/PROV_HEADER_SSO/${PROV_HEADER_SSO}/g" \
    ${DEPLOYER}/lib/templates/web/moduleconf/sso.conf > ${cf}
  _prov_connections ${cf}
  cat ${cf} > ${outdir}/moduleconf/sso.conf

  sed "s/^ServerName.*/ServerName ${webhost}/g" \
    ${DEPLOYER}/lib/templates/web/httpd.conf >${outdir}/httpd.conf

  for f in ssl-base.conf ssl.conf ; do
    cp ${DEPLOYER}/lib/templates/web/${f} ${outdir}/${f}
  done

  rm -f ${cf}
}

