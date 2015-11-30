#  libuserenv.sh
#
#  copy user environment settings
#  ------------------------------
#

_cp_nodemanager()
{
  local _dir=${iam_top}/config/nodemanager/$(hostname -f)
  [[ -d ${_dir} ]] || return 0
  local _prop=nodemanager.properties
  local _start=startNodeManagerWrapper.sh

  [[ -f ${_dir}/${_prop}.orig ]] && return 0

  # properties
  mv ${_dir}/${_prop} ${_dir}/${_prop}.orig
  cp ${nodesrc}/${_prop} ${_dir}/${_prop}
  grep Custom ${_dir}/${_prop}.orig >>${_dir}/${_prop}

  # start script
  cp -b ${nodesrc}/${_start} ${_dir}/
  chmod 0755 ${_dir}/${_start}

  sed -i "s/__HOSTNAME__/$(hostname -f)/" ${_dir}/${_start} ${_dir}/${_prop}
  sed -i "s/__IAM_TOP__/${_iam_top}/"      ${_dir}/${_start} ${_dir}/${_prop}
  sed -i "s/__IAM_LOG__/${_iam_log}/"      ${_dir}/${_prop}
}

_replace_in_env()
{
  # general
  sed -i "s/__HOSTENV__/${_iam_hostenv}/" ${env}/*
  sed -i "s/__IAM_TOP__/${_iam_top}/"     ${env}/*
  sed -i "s/__IAM_TOP__/${_iam_top}/"     ${bin}/*
  sed -i "s/__IAM_LOG__/${_iam_log}/"     ${env}/*
  sed -i "s/__IAM_LOG__/${_iam_log}/"     ${bin}/*
  sed -i "s/__IL_APP_CONFIG__/${IL_APP_CONFIG}/" ${env}/*
  sed -i "s/__IL_APP_CONFIG__/${IL_APP_CONFIG}/" ${bin}/*
  # access - acc
  sed -i "s/__IDMPROV_IDMDOMAIN_ADMINSERVER_HOST__/${IDMPROV_IDMDOMAIN_ADMINSERVER_HOST}/"     ${env}/*
  sed -i "s/__IDMPROV_IDMDOMAIN_ADMINSERVER_HOST__/${IDMPROV_IDMDOMAIN_ADMINSERVER_HOST}/"     ${bin}/*
  sed -i "s/__IDMPROV_IDMDOMAIN_ADMINSERVER_PORT__/${IDMPROV_IDMDOMAIN_ADMINSERVER_PORT}/"     ${env}/*
  sed -i "s/__IDMPROV_IDMDOMAIN_ADMINSERVER_PORT__/${IDMPROV_IDMDOMAIN_ADMINSERVER_PORT}/"     ${bin}/*
  sed -i "s/__IDMPROV_OAM_PORT__/${IDMPROV_OAM_PORT}/" ${env}/*
  sed -i "s/__IDMPROV_OAM_PORT__/${IDMPROV_OAM_PORT}/" ${bin}/*
  # identity - oim
  sed -i "s/__IDMPROV_OIMDOMAIN_ADMINSERVER_HOST__/${IDMPROV_OIMDOMAIN_ADMINSERVER_HOST}/"     ${env}/*
  sed -i "s/__IDMPROV_OIMDOMAIN_ADMINSERVER_HOST__/${IDMPROV_OIMDOMAIN_ADMINSERVER_HOST}/"     ${bin}/*
  sed -i "s/__IDMPROV_OIMDOMAIN_ADMINSERVER_PORT__/${IDMPROV_OIMDOMAIN_ADMINSERVER_PORT}/"     ${env}/*
  sed -i "s/__IDMPROV_OIMDOMAIN_ADMINSERVER_PORT__/${IDMPROV_OIMDOMAIN_ADMINSERVER_PORT}/"     ${bin}/*
  sed -i "s/__IDMPROV_OIM_PORT__/${IDMPROV_OIM_PORT}/" ${env}/*
  sed -i "s/__IDMPROV_OIM_PORT__/${IDMPROV_OIM_PORT}/" ${bin}/*
  sed -i "s/__IDMPROV_SOA_PORT__/${IDMPROV_SOA_PORT}/" ${env}/*
  sed -i "s/__IDMPROV_SOA_PORT__/${IDMPROV_SOA_PORT}/" ${bin}/*
  # analytics - oia
  sed -i "s/__IDMPROV_OIADOMAIN_ADMINSERVER_HOST__/${IDMPROV_OIADOMAIN_ADMINSERVER_HOST}/"     ${env}/*
  sed -i "s/__IDMPROV_OIADOMAIN_ADMINSERVER_HOST__/${IDMPROV_OIADOMAIN_ADMINSERVER_HOST}/"     ${bin}/*
  sed -i "s/__IDMPROV_OIADOMAIN_ADMINSERVER_PORT__/${IDMPROV_OIADOMAIN_ADMINSERVER_PORT}/"     ${env}/*
  sed -i "s/__IDMPROV_OIADOMAIN_ADMINSERVER_PORT__/${IDMPROV_OIADOMAIN_ADMINSERVER_PORT}/"     ${bin}/*
  sed -i "s/__IDMPROV_OIA_PORT__/${IDMPROV_OIA_PORT}/" ${env}/*
  sed -i "s/__IDMPROV_OIA_PORT__/${IDMPROV_OIA_PORT}/" ${bin}/*
}

_cp_acc()
{
  # already done?
  [ -f ${env}/acc.env ] && return

  cp ${src}/bin/*access*      ${bin}/
  cp ${src}/bin/*nodemanager* ${bin}/
  cp ${src}/env/acc.env       ${env}/
  cp ${src}/env/access.prop   ${env}/
  sed -i "s/__DOMAIN_NAME__/${iam_domain_acc}/" ${env}/*
  _cp_nodemanager
  _replace_in_env
}

_cp_oim()
{
  # already done?
  [ -f ${env}/idm.env ] && return

  cp ${src}/bin/*identity*      ${bin}/
  cp ${src}/bin/*nodemanager*   ${bin}/
  cp ${src}/env/idm.env         ${env}/
  cp ${src}/env/idm-deplenv.env ${env}/
  cp ${src}/env/identity.prop   ${env}/
  cp ${src}/lib/deploy.py       ${lib}/
  sed -i "s/__DOMAIN_NAME__/${iam_domain_oim}/" ${env}/*
  _cp_nodemanager
  _replace_in_env
}

_cp_oia()
{
  # already done?
  [ -f ${env}/oia.env ] && return

  cp ${src}/bin/*analytics*     ${bin}/
  cp ${src}/env/oia.env         ${env}/
  cp ${src}/env/analytics.prop  ${env}/
  cp ${src}/env/rbacx.prop      ${env}/
  cp ${src}/lib/deploy-rbacx.py ${lib}/
  sed -i "s/__DOMAIN_NAME__/${iam_domain_oia}/" ${env}/*
  sed -i "s/__RBACX_HOME__/${iam_rbacx_home}/"  ${env}/*
  _cp_nodemanager
  _replace_in_env
}

_cp_oud()
{
  # already done?
  [ -f ${env}/dir.env ] && return

  cp ${src}/bin/*dir*            ${bin}/
  cp ${src}/env/dir.env          ${env}/
  cp ${src}/env/tools.properties ${env}/
  _replace_in_env
  sed -i "s/__HOSTNAME__/$(hostname -f)/" ${env}/*
  echo -n ${oudPwd} > ${crd}/oudadmin
}

_cp_web()
{
  # already done?
  [ -f ${env}/web.env ] && return

  cp ${src}/bin/*webtier* ${bin}/
  cp ${src}/env/web.env   ${env}/
  _replace_in_env
  
  # get the instance name
  local _ohspath=$(find ${INSTALL_LOCALCONFIG_DIR}/instances \
    -maxdepth 1 -type d -a -name 'ohs*')
  local _ohs=$(basename $_ohspath)

  sed -i "s/ohs1/${_ohs}/" ${env}/*
}

#  ------------------------------------------------
#  provisioning of user host environment
#  there shall be a common directory on shared storage
#  where envs for all products (selected in iam.config)
#  will be written to - called only once per installation
#
init_userenv()
{ 
      src=${DEPLOYER}/lib/templates/hostenv
  nodesrc=${DEPLOYER}/lib/templates/nodemanager
      env=${iam_hostenv}/.env
      bin=${iam_hostenv}/bin
      lib=${iam_hostenv}/lib
      crd=${iam_hostenv}/.creds

  # these variables will be used in sed command and must
  # be escaped before
    _iam_hostenv=$(echo ${iam_hostenv} | sed -e 's/[\/&]/\\&/g')
        _iam_top=$(echo ${iam_top}     | sed -e 's/[\/&]/\\&/g')
        _iam_log=$(echo ${iam_log}     | sed -e 's/[\/&]/\\&/g')
  _deployer_path=$(echo ${DEPLOYER}    | sed -e 's/[\/&]/\\&/g')
  # also used but scaping not necessary:
  # iam_domain_oim, iam_domain_acc

  for d in ${env} ${bin} ${lib} ${crd} ; do
    [[ -a ${d} ]] || mkdir -p ${d}
  done

  # common bin files
  for f in iam-memusage iam-monitor start-all stop-all ; do
    if ! [ -a ${f} ] ; then
      cp ${src}/bin/${f} ${bin}/
    fi
  done

  # common env files
  for f in common.env ; do
    if ! [ -a ~/.env/${f} ] ; then
      cp ${src}/env/${f} ${env}/
      sed -i "s/__DEPLOYER__/${_deployer_path}/" ${env}/${f}
    fi
  done

  exists_product identity  && _cp_oim
  exists_product access    && _cp_acc
  exists_product directory && _cp_oud
  exists_product web       && _cp_web
  exists_product analytics && _cp_oia

  return 0
}

#  ---------------------------------------------------
#  add sourcing of common.env (shared folder) on host
#
extend_bash_profile_on_host()
{
  src=${DEPLOYER}/lib/templates/hostenv
  env=${iam_hostenv}/.env
  bin=${iam_hostenv}/bin
  lib=${iam_hostenv}/lib
  crd=${iam_hostenv}/.creds

  # this variable will be used in sed command and must be escaped
  _iam_hostenv=$(echo ${iam_hostenv} | sed -e 's/[\/&]/\\&/g')

  # add the tools.property file to oud instance dir
  for d in ${iam_services}/instances/* ; do
    if [ -d ${d}/OUD ] ; then
      cp -b ~/.env/tools.properties ${d}/OUD/config/
    fi
  done

  # add sourcing to profile
  cat ${src}/env/bash_profile  >${HOME}/.bash_profile
  sed -i -e "s/__HOSTENV__/${_iam_hostenv}/g" ${HOME}/.bash_profile
}
