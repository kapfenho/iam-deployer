# create log area and link locations.  this script shall be run on each machine
#

#  -------------------------------------------------------------------------
#  private function - called by move_logs()
#
_mvlog()
{
  local src=${1}
  local dst=${2}
  if ! [ -a ${src} ] ; then
    return
  fi
  # check if already done
  if [ -h ${src} ] ; then
    warning "Already moved log dir ${src}"
  else
    mkdir -p "${dst}"
    # delete destination file if exsiting
    for f in ${dst}/* ; do
      rm -Rf "${f}"
    done
    # move all files to new destination
    for f in ${src}/* ; do
      mv "${f}" ${dst}/
    done
    # replace old location with soft link
    rm -Rf   ${src}
    ln -sf   ${dst} ${src}
  fi
}

#  --------------------------------------------------------------------------
#  public function - entry point
#  control flags: idm, acc, web, oud
#
move_logs()
{
  local _product=${1}
  dst=${iam_log}
  
  case ${_product} in
    identity)
      mkdir -p ${dst}/nodemanager
      _mvlog ${iam_top}/config/domains/${iam_domain_oim}/servers/AdminServer/logs       ${dst}/${iam_domain_oim}/AdminServer
      _mvlog ${iam_services}/domains/${iam_domain_oim}/servers/wls_soa1/logs            ${dst}/${iam_domain_oim}/wls_soa1
      _mvlog ${iam_services}/domains/${iam_domain_oim}/servers/wls_soa2/logs            ${dst}/${iam_domain_oim}/wls_soa2
      _mvlog ${iam_services}/domains/${iam_domain_oim}/servers/wls_oim1/logs            ${dst}/${iam_domain_oim}/wls_oim1
      _mvlog ${iam_services}/domains/${iam_domain_oim}/servers/wls_oim2/logs            ${dst}/${iam_domain_oim}/wls_oim2
      _mvlog ${iam_services}/domains/${iam_domain_oim}/servers/wls_bi1/logs             ${dst}/${iam_domain_oim}/wls_bi1
      _mvlog ${iam_services}/domains/${iam_domain_oim}/servers/wls_bi2/logs             ${dst}/${iam_domain_oim}/wls_bi2
      ;;
    access)
      mkdir -p ${dst}/nodemanager
      _mvlog ${iam_top}/config/domains/${iam_domain_acc}/servers/AdminServer/logs       ${dst}/${iam_domain_acc}/AdminServer
      _mvlog ${iam_services}/domains/${iam_domain_acc}/servers/wls_oam1/logs            ${dst}/${iam_domain_acc}/wls_oam1
      _mvlog ${iam_services}/domains/${iam_domain_acc}/servers/wls_oam2/logs            ${dst}/${iam_domain_acc}/wls_oam2
      _mvlog ${iam_services}/domains/${iam_domain_acc}/servers/wls_ama1/logs            ${dst}/${iam_domain_acc}/wls_ama1
      _mvlog ${iam_services}/domains/${iam_domain_acc}/servers/wls_ama2/logs            ${dst}/${iam_domain_acc}/wls_ama2
      ;;
    dir)
      mkdir -p ${dst}/${INSTANCE}
      _mvlog ${iam_instance_oud}/OUD/logs ${dst}/${INSTANCE}/logs
      ;;
    webtier)
      local _ohspath=$(find ${INSTALL_LOCALCONFIG_DIR}/instances \
        -maxdepth 1 -type d -a -name 'ohs*')
      local _ohs=$(basename $_ohspath)
      mkdir -p ${dst}/${_ohs}
      _mvlog ${iam_services}/instances/${_ohs}/auditlogs                    ${dst}/${_ohs}/auditlogs
      _mvlog ${iam_services}/instances/${_ohs}/diagnostics/logs/OHS/${_ohs} ${dst}/${_ohs}/logs
      _mvlog ${iam_services}/instances/${_ohs}/diagnostics/logs/OPMN/opmn   ${dst}/${_ohs}/opmn
      ;;
    \*)
      error "Move logs: product unkown"
      exit $ERROR_FILE_NOT_FOUND
  esac
}

