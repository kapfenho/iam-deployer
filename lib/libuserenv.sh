#  libuserenv.sh
#
#  copy user environment settings
#  ------------------------------
#

_cp_nodemanager()
{
  local _host=$(hostname -f)
  local _dir=${iam_top}/config/nodemanager/${_host}
  local _prop=nodemanager.properties
  local _start=startNodeManagerWrapper.sh

  [ -f ${_dir}/${_prop}.orig ] && return 1

  # properties
  mv ${_dir}/${_prop} ${_dir}/${_prop}.orig
  cp ${nodesrc}/${_prop} ${_dir}/${_prop}
  grep Custom ${_dir}/${_prop}.orig >>${_dir}/${_prop}

  # start script
  cp -b ${nodesrc}/${_start} ${_dir}/
  chmod 0755 ${_dir}/${_start}

  sed -i "s/_HOST_/$(_host)/" ${_dir}/${_start} ${_dir}/${_prop}
  sed -i "s/_IAMTOP_/${iam_top}/"      ${_dir}/${_start} ${_dir}/${_prop}
  sed -i "s/_IAMLOG_/${iam_log}/"      ${_dir}/${_prop}
}

_cp_oim()
{
  [ "${idmhost}" != "yes" ] && return
  # already done?
  [ -f ${env}/idm.env ] && return 1

  cp ${src}/bin/*identity*          ${bin}/
  cp ${src}/bin/*nodemanager*       ${bin}/
  cp ${src}/env/idm.env             ${env}/
  cp ${src}/env/idm-deplenv.env     ${env}/
  cp ${src}/env/identity.prop       ${env}/
  cp ${src}/env/imint.prop          ${env}/
  cp ${src}/lib/deploy.py           ${lib}/
  sed -i "s/_HOSTENV_/${iam_hostenv}/" ${env}/*
  sed -i "s/_IAMTOP_/${iam_top}/"      ${env}/*
  sed -i "s/_IAMTOP_/${iam_top}/"      ${bin}/*
  sed -i "s/_IAMLOG_/${_log}/"      ${env}/*
  sed -i "s/_IAMLOG_/${_log}/"      ${bin}/*
  sed -i "s/_HOST_/$(hostname -f)/" ${env}/*
  sed -i "s/_HOST_/$(hostname -f)/" ${bin}/*
  sed -i "s/_DOMAIN_/${IDMPROV_IDENTITY_DOMAIN}/" ${env}/*
  _cp_nodemanager
}

_cp_oam()
{
  [ "${acchost}" != "yes" ] && return
  # already done?
  [ -f ${env}/acc.env ] && return 1

  cp ${src}/bin/*access*            ${bin}/
  cp ${src}/bin/*nodemanager*       ${bin}/
  cp ${src}/env/acc.env             ${env}/
  cp ${src}/env/access.prop         ${env}/
  sed -i "s/_HOSTENV_/${iam_hostenv}/" ${env}/*
  sed -i "s/_IAMTOP_/${iam_top}/"      ${env}/*
  sed -i "s/_IAMTOP_/${iam_top}/"      ${bin}/*
  sed -i "s/_IAMLOG_/${_log}/"      ${env}/*
  sed -i "s/_IAMLOG_/${_log}/"      ${bin}/*
  sed -i "s/_HOST_/$(hostname -f)/" ${env}/*
  sed -i "s/_HOST_/$(hostname -f)/" ${bin}/*
  sed -i "s/_DOMAIN_/${IDMPROV_ACCESS_DOMAIN}/" ${env}/*
  _cp_nodemanager
}

_cp_oud()
{
  [ "${oudhost}" != "yes" ] && return
  # already done?
  [ -f ${env}/dir.env ] && return 1

  cp ${src}/bin/*dir*               ${bin}/
  cp ${src}/env/dir.env             ${env}/
  cp ${src}/env/tools.properties    ${env}/
  sed -i "s/_HOSTENV_/${iam_hostenv}/" ${env}/*
  sed -i "s/_IAMTOP_/${iam_top}/"      ${env}/*
  sed -i "s/_IAMLOG_/${_log}/"      ${env}/*
  sed -i "s/_HOST_/$(hostname -f)/" ${env}/*
}

_cp_web()
{
  [ "${webhost}" != "yes" ] && return
  # already done?
  [ -f ${env}/web.env ] && return 1

  cp ${src}/bin/*webtier*           ${bin}/
  cp ${src}/env/web.env             ${env}/
  sed -i "s/_HOSTENV_/${iam_hostenv}/" ${env}/*
  sed -i "s/_HOSTENV_/${iam_hostenv}/" ${bin}/*
  sed -i "s/_IAMTOP_/${iam_top}/"      ${env}/*
  sed -i "s/_IAMTOP_/${iam_top}/"      ${bin}/*
  sed -i "s/_IAMLOG_/${_log}/"      ${env}/*
  sed -i "s/_IAMLOG_/${_log}/"      ${bin}/*
  sed -i "s/_HOST_/$(hostname -f)/" ${env}/*
  sed -i "s/_HOST_/$(hostname -f)/" ${bin}/*
}

# # create host specific start-all and stop-all scripts
# #
# _create_startall()
# {
#   fo=$(mktemp "orderXXXXXXXX")
#   startall=~/bin/start-all
#   stopall=~/bin/stop-all
# 
#   [ "${oudhost}" == "yes" ] && echo "dir"         >>${fo}
#   [ "${idmhost}" == "yes" -o "${acchost}" == "yes" ] && \
#                                echo "nodemanager" >>${fo}
#   [ "${acchost}" == "yes" ] && echo "access"      >>${fo}
#   [ "${idmhost}" == "yes" ] && echo "identity"    >>${fo}
#   [ "${webhost}" == "yes" ] && echo "webtier"     >>${fo}
# 
#   echo "#!/bin/bash" > ${startall}
#   cat ${fo} | while read l ; do
#     echo "start-${l}" >>${startall}
#   done
# 
#   echo "#!/bin/bash" > ${stopall}
#   tac ${fo} | while read l ; do
#     echo "stop-${l}" >>${stopall}
#   done
# 
#   chmod 0755 ${startall} ${stopall}
#   rm -f ${fo}
# }


init_userenv()
{
      src=${DEPLOYER}/lib/templates/hostenv
  nodesrc=${DEPLOYER}/lib/templates/nodemanager
  env=${iam_hostenv}/env
  bin=${iam_hostenv}/bin
  lib=${iam_hostenv}/lib
  crd=${iam_hostenv}/.creds

  
  _hostenv=$(echo ${iam_hostenv} | sed -e 's/[\/&]/\\&/g')
      _top=$(echo ${iam_top}     | sed -e 's/[\/&]/\\&/g')
      _log=$(echo ${iam_log}     | sed -e 's/[\/&]/\\&/g')
  
  mkdir -p ${env} ${bin} ${lib} ${crd}
  [ -L ${sc_env} ] || ln -sf ${env} ${sc_env}
  [ -L ${sc_env} ] || ln -sf ${bin} ${sc_bin}
  [ -L ${sc_env} ] || ln -sf ${lib} ${sc_lib}
  [ -L ${sc_env} ] || ln -sf ${crd} ${sc_crd}
  
  cp  ${src}/bin/iam*                 ${bin}/
  cp  ${src}/env/common.env           ${env}/
  cat ${src}/env/bash_profile       > ${HOME}/.bash_profile
  sed -i "s/_HOSTENV_/${iam_hostenv}/"   ${HOME}/.bash_profile

  _create_startall

  _cp_oim
  _cp_oam
  _cp_oud
  _cp_web
}

