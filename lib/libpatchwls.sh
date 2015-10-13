# the patches correct bugs of the default configuration:
#   * several concurrent jvm memory options are stated
#   * jvm runs in client mode (dev and prod mode)
#   * jvm options are not jdk7 compatible
#

patch_wls_bin()
{
  if [ "${1}" == "" ] ; then
    error "ERROR: Parameter missing"
    exit 0
  fi
  
  local _p=${1}
  local _src=${DEPLOYER}/lib/weblogic

  # wl_home
  if grep -e 'PRODUCTION_MODE="true"' ${iam_top}/${_p}/wlserver_10.3/common/bin/commEnv.sh >/dev/null ; then
    log "WL_HOME already patch, nothing to do"
  else
    patch -b ${iam_top}/${_p}/common/bin/commEnv.sh <${_src}/weblogic/commEnv.sh.patch
    log "WL_HOME patched: ${iam_top}/${_p}"
  fi
}

patch_wls_domain()
{
  if [ "${1}" == "" ] ; then
    error "ERROR: Parameter missing"
    exit 0
  fi

  local _domain=${1}
  local _src=${DEPLOYER}/lib/${_domain}

  # admin domain
  if ! [ -a ${ADMIN_HOME}/bin/setCustDomainEnv.sh ]; then
    cp ${_src}/domain/setCustDomainEnv.sh ${ADMIN_HOME}/bin/
  fi

  if ! grep setCustDomainEnv ${ADMIN_HOME}/bin/setDomainEnv.sh >/dev/null 2>&1 ; then
    patch -b ${ADMIN_HOME}/bin/setDomainEnv.sh <${_src}//domain/setDomainEnv.sh.patch
    log "ADMIN_HOME patched: ${ADMIN_HOME}"
  fi

  # local domain
  if ! [ -a ${WRK_HOME}/bin/setCustDomainEnv.sh ]; then
    cp ${_src}/domain/setCustDomainEnv.sh ${WRK_HOME}/bin/
  fi

  if ! grep setCustDomainEnv ${WRK_HOME}/bin/setDomainEnv.sh >/dev/null 2>&1 ; then
    patch -b ${WRK_HOME}/bin/setDomainEnv.sh <${_src}/domain/setDomainEnv.sh.patch
    log "WRK_HOME patched: ${WRK_HOME}"
  fi
}
