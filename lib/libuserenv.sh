#  libuserenv.sh
#
#  copy user environment settings
#  ------------------------------
#

_cp_nodemanager()
{
  local _dir=${iam_top}/config/nodemanager/$(hostname -f)
  local _prop=nodemanager.properties
  local _start=startNodeManagerWrapper.sh

  [ -f ${_dir}/${_prop}.orig ] && return

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

_cp_oim()
{
  # already done?
  [ -f ${env}/idm.env ] && return

  cp ${src}/bin/*identity*          ${bin}/
  cp ${src}/bin/*nodemanager*       ${bin}/
  cp ${src}/env/idm.env             ${env}/
  cp ${src}/env/idm-deplenv.env     ${env}/
  cp ${src}/env/identity.prop       ${env}/
  cp ${src}/env/imint.prop          ${env}/
  cp ${src}/lib/deploy.py           ${lib}/
  sed -i "s/__HOSTENV__/${_iam_hostenv}/" ${env}/*
  sed -i "s/__IAM_TOP__/${_iam_top}/"      ${env}/*
  sed -i "s/__IAM_TOP__/${_iam_top}/"      ${bin}/*
  sed -i "s/__IAM_LOG__/${_iam_log}/"      ${env}/*
  sed -i "s/__IAM_LOG__/${_iam_log}/"      ${bin}/*
  sed -i "s/__HOSTNAME__/$(hostname -f)/" ${env}/*
  sed -i "s/__HOSTNAME__/$(hostname -f)/" ${bin}/*
  sed -i "s/__DOMAIN_NAME__/${iam_domain_oim}/" ${env}/*
  _cp_nodemanager
}

_cp_acc()
{
  # already done?
  [ -f ${env}/acc.env ] && return

  cp ${src}/bin/*access*            ${bin}/
  cp ${src}/bin/*nodemanager*       ${bin}/
  cp ${src}/env/acc.env             ${env}/
  cp ${src}/env/access.prop         ${env}/
  sed -i "s/__HOSTENV__/${_iam_hostenv}/" ${env}/*
  sed -i "s/__IAM_TOP__/${_iam_top}/"      ${env}/*
  sed -i "s/__IAM_TOP__/${_iam_top}/"      ${bin}/*
  sed -i "s/__IAM_LOG__/${_iam_log}/"      ${env}/*
  sed -i "s/__IAM_LOG__/${_iam_log}/"      ${bin}/*
  sed -i "s/__HOSTNAME__/$(hostname -f)/" ${env}/*
  sed -i "s/__HOSTNAME__/$(hostname -f)/" ${bin}/*
  sed -i "s/__DOMAIN_NAME__/${iam_domain_acc}/" ${env}/*
  _cp_nodemanager
}

_cp_oud()
{
  # already done?
  [ -f ${env}/dir.env ] && return

  cp ${src}/bin/*dir*               ${bin}/
  cp ${src}/env/dir.env             ${env}/
  cp ${src}/env/tools.properties    ${env}/
  sed -i "s/__HOSTENV__/${_iam_hostenv}/" ${env}/*
  sed -i "s/__IAM_TOP__/${_iam_top}/"      ${env}/*
  sed -i "s/__IAM_LOG__/${_iam_log}/"      ${env}/*
  sed -i "s/__HOSTNAME__/$(hostname -f)/" ${env}/*
  echo -n ${oudPwd} > ${crd}/oudadmin
}

_cp_web()
{
  # already done?
  [ -f ${env}/web.env ] && return

  cp ${src}/bin/*webtier*           ${bin}/
  cp ${src}/env/web.env             ${env}/
  sed -i "s/__HOSTENV__/${_iam_hostenv}/" ${env}/*
  sed -i "s/__HOSTENV__/${_iam_hostenv}/" ${bin}/*
  sed -i "s/__IAM_TOP__/${_iam_top}/"      ${env}/*
  sed -i "s/__IAM_TOP__/${_iam_top}/"      ${bin}/*
  sed -i "s/__IAM_LOG__/${_iam_log}/"      ${env}/*
  sed -i "s/__IAM_LOG__/${_iam_log}/"      ${bin}/*
  sed -i "s/__HOSTNAME__/$(hostname -f)/" ${env}/*
  sed -i "s/__HOSTNAME__/$(hostname -f)/" ${bin}/*
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
      env=${iam_hostenv}/env
      bin=${iam_hostenv}/bin
      lib=${iam_hostenv}/lib
      crd=${iam_hostenv}/.creds

  [[ -d ${env} ]] && return 0
 
  # these variables will be used in sed command and must
  # be escaped before
    _iam_hostenv=$(echo ${iam_hostenv} | sed -e 's/[\/&]/\\&/g')
        _iam_top=$(echo ${iam_top}     | sed -e 's/[\/&]/\\&/g')
        _iam_log=$(echo ${iam_log}     | sed -e 's/[\/&]/\\&/g')
  _deployer_path=$(echo ${DEPLOYER}    | sed -e 's/[\/&]/\\&/g')
  # also used but scaping not necessary:
  # iam_domain_oim, iam_domain_acc
  
  mkdir -p ${env} ${bin} ${lib} ${crd}
  
  cp  ${src}/bin/iam*                 ${bin}/
  cp  ${src}/env/common.env           ${env}/
  sed -i "s/__DEPLOYER__/${_deployer_path}/" ${env}/common.env

  # _create_startall

  do_idm && _cp_oim
  do_acc && _cp_acc
  do_oud && _cp_oud
  do_web && _cp_web
}

#  ---------------------------------------------------
#  add sourcing of common.env (shared folder) on host
#
extend_bash_profile_on_host()
{
  src=${DEPLOYER}/lib/templates/hostenv
  env=${iam_hostenv}/env
  bin=${iam_hostenv}/bin
  lib=${iam_hostenv}/lib
  crd=${iam_hostenv}/.creds

  # this variable will be used in sed command and must be escaped
  _iam_hostenv=$(echo ${iam_hostenv} | sed -e 's/[\/&]/\\&/g')

  [ -L ${sc_env} ] || ln -sf ${env} ${sc_env}
  [ -L ${sc_bin} ] || ln -sf ${bin} ${sc_bin}
  [ -L ${sc_lib} ] || ln -sf ${lib} ${sc_lib}
  [ -L ${sc_crd} ] || ln -sf ${crd} ${sc_crd}

  # add the tools.property file to oud instance dir
  for d in ${iam_services}/instances/* ; do
    if [ -d ${d}/OUD ] ; then
      cp -b ${iam_hostenv}/env/tools.properties ${d}/OUD/config/
    fi
  done

  # add sourcing to profile
  cat ${src}/env/bash_profile  >${HOME}/.bash_profile
  sed -i -e "s/__HOSTENV__/${_iam_hostenv}/g" ${HOME}/.bash_profile
}
