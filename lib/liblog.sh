# create log area and link locations.  this script shall be run on each machine
#

#  -------------------------------------------------------------------------
#  private function - called by move_logs()
#
_mvlog()
{
  local src=${1}
  local dst=${2}
  if [ ! -a ${src} ] ; then
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
#  control flags: idmhost, acchost, webhost, oudhost
#
move_logs()
{
  oudins=oud1
  ohsins=ohs1

  dst=${iam_log}
  idmdom=${IDMPROV_IDENTITY_DOMAIN}
  accdom=${IDMPROV_ACCESS_DOMAIN}
  
  if [ -z ${idmdom} ] ; then
    error "Env variable IDMPROV_IDENTITY_DOMAIN not defined"
    exit 81
  fi
  
  if [ "${idmhost}" == "yes" ] ; then
    mkdir -p ${dst}/nodemanager
    _mvlog ${iam_top}/config/domains/${idmdom}/servers/AdminServer/logs           ${dst}/${idmdom}/AdminServer
    _mvlog ${iam_top}/services/domains/${idmdom}/servers/wls_soa1/logs            ${dst}/${idmdom}/wls_soa1
    _mvlog ${iam_top}/services/domains/${idmdom}/servers/wls_soa2/logs            ${dst}/${idmdom}/wls_soa2
    _mvlog ${iam_top}/services/domains/${idmdom}/servers/wls_oim1/logs            ${dst}/${idmdom}/wls_oim1
    _mvlog ${iam_top}/services/domains/${idmdom}/servers/wls_oim2/logs            ${dst}/${idmdom}/wls_oim2
  fi
  if [ "${acchost}" == "yes" ] ; then
    mkdir -p ${dst}/nodemanager
    _mvlog ${iam_top}/config/domains/${accdom}/servers/AdminServer/logs           ${dst}/${accdom}/AdminServer
    _mvlog ${iam_top}/services/domains/${accdom}/servers/wls_oam1/logs            ${dst}/${accdom}/wls_oam1
    _mvlog ${iam_top}/services/domains/${accdom}/servers/wls_oam2/logs            ${dst}/${accdom}/wls_oam2
  fi
  if [ "${oudhost}" == "yes" ] ; then
    mkdir -p ${dst}/${oudins}
    _mvlog ${iam_top}/services/instances/${oudins}/OUD/logs                       ${dst}/${oudins}/logs
  fi
  if [ "${webhost}" == "yes" ] ; then
    mkdir -p ${dst}/${ohsins}
    _mvlog ${iam_top}/services/instances/${ohsins}/auditlogs                      ${dst}/${ohsins}/auditlogs
    _mvlog ${iam_top}/services/instances/${ohsins}/diagnostics/logs/OHS/${ohsins} ${dst}/${ohsins}/logs
    _mvlog ${iam_top}/services/instances/${ohsins}/diagnostics/logs/OPMN/opmn     ${dst}/${ohsins}/opmn
  fi
}
