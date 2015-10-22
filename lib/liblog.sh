# create log area and link locations.  this script shall be run on each machine
#

#  -------------------------------------------------------------------------
#  private function - called by move_logs()
#
_mvlog()
{
  local src=${1}
  local dst=${2}
  if [[ ! -a ${src} ]] ; then
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
      ;;
    access)
      mkdir -p ${dst}/nodemanager
      _mvlog ${iam_top}/config/domains/${iam_domain_acc}/servers/AdminServer/logs       ${dst}/${iam_domain_acc}/AdminServer
      _mvlog ${iam_services}/domains/${iam_domain_acc}/servers/wls_oam1/logs            ${dst}/${iam_domain_acc}/wls_oam1
      _mvlog ${iam_services}/domains/${iam_domain_acc}/servers/wls_oam2/logs            ${dst}/${iam_domain_acc}/wls_oam2
      ;;
    dir)
      mkdir -p ${dst}/${iam_instance_oud}
      _mvlog ${iam_services}/instances/${iam_instance_oud}/OUD/logs                     ${dst}/${iam_instance_oud}/logs
      ;;
    webtier)
      mkdir -p ${dst}/${iam_instance_ohs}
      _mvlog ${iam_services}/instances/${iam_instance_ohs}/auditlogs                    ${dst}/${iam_instance_ohs}/auditlogs
      _mvlog ${iam_services}/instances/${iam_instance_ohs}/diagnostics/logs/OHS/${iam_instance_ohs} ${dst}/${iam_instance_ohs}/logs
      _mvlog ${iam_services}/instances/${iam_instance_ohs}/diagnostics/logs/OPMN/opmn   ${dst}/${iam_instance_ohs}/opmn
      ;;
    \*)
      error "Move logs: product unkown"
      exit $ERROR_FILE_NOT_FOUND
  esac
}

