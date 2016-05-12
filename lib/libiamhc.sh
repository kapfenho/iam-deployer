#  iam health check calls
#

_iamhc_create_properties()
{
  cat > ${1} <<-EOS
IDSTORE_HOST:${IDMPROV_OID_HOST}
IDSTORE_PORT:${DIR_PORT}
IDSTORE_BINDDN:${DIR_ADMIN_NAME}
IDSTORE_SSL_PORT:${DIR_SSL_PORT}
IDSTORE_GROUPSEARCHBASE:cn=Groups,${DIR_REALM_DN}
IDSTORE_USERSEARCHBASE:cn=Users,${DIR_REALM_DN}
IDSTORE_SYSTEMIDSEARCHBASE:${SYSTEM_IDS_CONTAINER}

OID_DB_HOST:
OID_DB_PORT:
OID_DB_SERVICE_NAME:
OID_DB_USER:
OID_DB_SYS_USER:
OID_DB_CONNECTION_STRING:

OAM_DB_HOST:${dbs_dbhost}
OAM_DB_PORT:${dbs_port}
OAM_DB_SERVICE_NAME:${iam_servicename}
OAM_DB_USER:${iam_oam_prefix}_OAM
OAM_DB_PASSWORD:${iam_oam_schema_pass}
OAM_DB_SYS_USER:sys
OAM_DB_SYS_PASSWORD:${iam_dba_pass}
OAM_DB_CONNECTION_STRING:${dbs_dbhost}:${dbs_port}@${iam_servicename}

OIM_DB_HOST:${dbs_dbhost}
OIM_DB_PORT:${dbs_port}
OIM_DB_SERVICE_NAME:${iam_servicename}
OIM_DB_USER:${iam_oim_prefix}_OIM
OIM_DB_PASSWORD:${iam_oam_schema_pass}
OIM_DB_SYS_USER:sys
OIM_DB_SYS_PASSWORD:${iam_dba_pass}
OIM_DB_CONNECTION_STRING:${dbs_dbhost}:${dbs_port}@${iam_servicename}

OMSM_DB_HOST:
OMSM_DB_PORT:
OMSM_DB_SERVICE_NAME:
OMSM_DB_USER:
OMSM_DB_CONNECTION_STRING:

OAM_WLS_ADMINSERVER_HOST:${IDMPROV_IDMDOMAIN_ADMINSERVER_HOST}
OAM_WLS_ADMINSERVER_PORT:${IDMPROV_IDMDOMAIN_ADMINSERVER_PORT}
OAM_WLSADMIN_USER:${WLSADMIN_NAME}
OAM_WLSADMIN_PASSWORD:${domaPwd}
OAM_WLS_ADMINSERVER_TRUSTSTORE:
OAM_WLS_ADMINSERVER_TRUSTSTORE_PASSPHRASE:${iam_pwd}

OIM_WLS_ADMINSERVER_HOST:${IDMPROV_OIMDOMAIN_ADMINSERVER_HOST}
OIM_WLS_ADMINSERVER_PORT:${IDMPROV_OIMDOMAIN_ADMINSERVER_PORT}
OIM_WLSADMIN_USER:${WLSADMIN_NAME}
OIM_WLSADMIN_PASSWORD:${domiPwd}
OIM_WLS_ADMINSERVER_TRUSTSTORE:
OIM_WLS_ADMINSERVER_TRUSTSTORE_PASSPHRASE:${iam_pwd}

ORACLE_HOME:${ORACLE_HOME}

SOASERVER_HOST:${IDMPROV_SOA_HOST}
OIMSERVER_HOST:${IDMPROV_OIM_HOST}
OIMSERVER_PORT:${IDMPROV_OIM_PORT}
OIMSERVER_SSL_PORT:
OIMADMIN_USERNAME:${OIMADMIN_NAME}
SOAADMIN_USERNAME:weblogic_idm
OIMSERVER_SERVER_TYPE:
SOASERVER_PORT:${IDMPROV_SOA_PORT}
SOASERVER_SSL_PORT:
OIMSERVER_INTERNALLOADBALANCERURL:
OIMSERVER_EXTERNALLOADBALANCERURL:
SOA_HOME:${iam_top}/products/identity/soa
TRUST_STORE:
TRUST_STORE_PASSPHRASE:
TRUST_STORE_TYPE:JKS

OUD_HOST:${IDMPROV_OID_HOST}
OUD_ADMINPORT:4444
OUD_ADMINUID:${DIR_ADMIN_NAME}
OUD_INSTANCE_HOME:${INSTALL_LOCALCONFIG_DIR}/instances/oud1


HTTP_PROXY_HOST:
HTTP_PROXY_PORT:
HTTP_PROXY_USERNAME:

HOST_TYPE:${HOST_TYPE}

INSTALL_PATH:

IDMPROV_CALL:true
EOS

  # truststore:
  #    admin: jdk/cacerts
  #    managed: .../config/keystores/....hostname.jks
  #
  # OAM_WLS_ADMINSERVER_TRUSTSTORE:${iam_top}/products/${product}/${shipped_jdk_dir}/jre/lib/security/cacerts
}


#  execute the health check program
#    param1: product (e.g. access)
#    param2: hc workdir where results are stored in
#    param3: health check filename
#
_iamhc_exec()
{
  ${iam_top}/products/${1}/iam/healthcheck/bin/idmhc.sh \
    -topology ${iam_lcmhome}/lcmconfig/topology/topology.xml \
    -manifest ${iam_top}/products/${1}/iam/healthcheck/config/${3} \
    -logDir "${2}" \
    -credconfig ${iam_lcmhome}/lcmconfig/credconfig \
    -inputfile "${2}/hc.properties"
}

#  interface for using functionatity, no prarameter needed
#
iamhc_check()
{
  local _infile _prod _wdir
  _type=""
  _prod=""
  _wdir=${iam_hc_workdir:-"/tmp"}/$(date "+%Y-%m-%d-%H-%M")

  mkdir -p ${_wdir}

  if [ -d "${INSTALL_LOCALCONFIG_DIR}/domains/${IDMPROV_ACCESS_DOMAIN}" ]
  then
    _type+=",OAM"
    [ -z "${_prod}" ] && _prod="access"
  fi
  if [ -d "${INSTALL_LOCALCONFIG_DIR}/domains/${IDMPROV_PRODUCT_IDENTITY_DOMAIN}" ]
  then
    _type+=",OIM"
    [ -z "${_prod}" ] && _prod="identity"
  fi
  if [ -d "${INSTALL_LOCALCONFIG_DIR}/instances/${OHS_INSTANCENAME}" ]
  then
    _type+=",WEB"
    [ -z "${_prod}" ] && _prod="web"
  fi
  if [ -d "${INSTALL_LOCALCONFIG_DIR}/instances/oud1" ]
  then
    _type+=",LDAP"
    [ -z "${_prod}" ] && _prod="dir"
  fi
  HOST_TYPE="${_type:1}"

  if [ "X${JAVA_HOME}" = "X" ]
  then
    export JAVA_HOME=${iam_top}/products/${_prod}/${shipped_jdk_dir}
    export PATH=${JAVA_HOME}/bin:${PATH}
  fi

  _iamhc_create_properties ${_wdir}/hc.properties

  _iamhc_exec ${_prod} ${_wdir} PostInstallChecks.xml

  if echo "${_type}" | grep -q "OAM" ; then
    _iamhc_exec "access" ${_wdir} PostInstallChecks_oam.xml
  fi

  if echo "${_type}" | grep -q "OIM" ; then
    _iamhc_exec "identity" ${_wdir} PostInstallChecks_oim.xml
  fi

}

