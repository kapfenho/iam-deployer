#  libuserenv.sh
#
#  copy user environment settings
#  ------------------------------
#

_cp_nodemanager()
{
  local _d=${iam_top}/config/nodemanager/$(hostname -f)/
  local _nm=nodemanager.properties
  [ -a ${_d}/${_nm}.orig ] && return
  mv ${_d}/${_nm} ${_d}/${_nm}.orig
  cp ${nodesrc}/${_nm} ${_d}/${_nm}
  grep Custom ${_d}/${_nm}.orig >>${_d}/${_nm}
  cp -b ${nodesrc}/startNodeManagerWrapper.sh ${_d}/
  chmod 0755 ${_d}/startNodeManagerWrapper.sh
  sed -i "s/_HOST_/$(hostname -f)/" ${_d}/startNodeManagerWrapper.sh ${_d}/${_nm}
  sed -i "s/_IAMTOP_/${_top}/"      ${_d}/startNodeManagerWrapper.sh ${_d}/${_nm}
  sed -i "s/_IAMLOG_/${_log}/"      ${_d}/${_nm}
}

_cp_oim()
{
  [ "${idmhost}" != "yes" ] && return

  cp ${src}/bin/*identity*          ${bin}/
  cp ${src}/bin/*nodemanager*       ${bin}/
  cp ${src}/env/idm.env             ${env}/
  cp ${src}/env/idm-deplenv.env     ${env}/
  cp ${src}/env/identity.prop       ${env}/
  cp ${src}/env/imint.prop          ${env}/
  cp ${src}/lib/deploy.py           ${lib}/
  sed -i "s/_HOSTENV_/${_hostenv}/" ${env}/*
  sed -i "s/_IAMTOP_/${_top}/"      ${env}/*
  sed -i "s/_IAMTOP_/${_top}/"      ${bin}/*
  sed -i "s/_IAMLOG_/${_log}/"      ${env}/*
  sed -i "s/_IAMLOG_/${_log}/"      ${bin}/*
  sed -i "s/_HOST_/$(hostname -f)/" ${env}/*
  sed -i "s/_HOST_/$(hostname -f)/" ${bin}/*
  sed -i "s/_DOMAIN_/${IDMPROV_IDENTITY_DOMAIN}/" ${env}/*
  echo "start-identity" >>${startall}
  echo "stop-identity"  >>${stopall}
  _cp_nodemanager
}

_cp_oam()
{
  [ "${acchost}" != "yes" ] && return

  cp ${src}/bin/*access*            ${bin}/
  cp ${src}/bin/*nodemanager*       ${bin}/
  cp ${src}/env/acc.env             ${env}/
  cp ${src}/env/access.prop         ${env}/
  sed -i "s/_HOSTENV_/${_hostenv}/" ${env}/*
  sed -i "s/_IAMTOP_/${_top}/"      ${env}/*
  sed -i "s/_IAMTOP_/${_top}/"      ${bin}/*
  sed -i "s/_IAMLOG_/${_log}/"      ${env}/*
  sed -i "s/_IAMLOG_/${_log}/"      ${bin}/*
  sed -i "s/_HOST_/$(hostname -f)/" ${env}/*
  sed -i "s/_HOST_/$(hostname -f)/" ${bin}/*
  sed -i "s/_DOMAIN_/${IDMPROV_ACCESS_DOMAIN}/" ${env}/*
  echo "start-access" >>${startall}
  echo "stop-access"  >>${stopall}
  _cp_nodemanager
}

_cp_oud()
{
  [ "${oudhost}" != "yes" ] && return

  cp ${src}/bin/*dir*               ${bin}/
  cp ${src}/env/dir.env             ${env}/
  cp ${src}/env/tools.properties    ${env}/
  sed -i "s/_HOSTENV_/${_hostenv}/" ${env}/*
  sed -i "s/_IAMTOP_/${_top}/"      ${env}/*
  sed -i "s/_IAMLOG_/${_log}/"      ${env}/*
  sed -i "s/_HOST_/$(hostname -f)/" ${env}/*
}

_cp_web()
{
  [ "${webhost}" != "yes" ] && return

  cp ${src}/bin/*webtier*           ${bin}/
  cp ${src}/env/web.env             ${env}/
  sed -i "s/_HOSTENV_/${_hostenv}/" ${env}/*
  sed -i "s/_HOSTENV_/${_hostenv}/" ${bin}/*
  sed -i "s/_IAMTOP_/${_top}/"      ${env}/*
  sed -i "s/_IAMTOP_/${_top}/"      ${bin}/*
  sed -i "s/_IAMLOG_/${_log}/"      ${env}/*
  sed -i "s/_IAMLOG_/${_log}/"      ${bin}/*
  sed -i "s/_HOST_/$(hostname -f)/" ${env}/*
  sed -i "s/_HOST_/$(hostname -f)/" ${bin}/*
}

# create host specific start-all and stop-all scripts
#
_create_startall()
{
  fo=$(mktemp "orderXXXXXXXX")
  startall=~/bin/start-all
  stopall=~/bin/stop-all

  [ "${oudhost}" == "yes" ] && echo "dir"         >>${fo}
  [ "${idmhost}" == "yes" -o "${acchost}" == "yes" ] && \
                               echo "nodemanager" >>${fo}
  [ "${acchost}" == "yes" ] && echo "access"      >>${fo}
  [ "${idmhost}" == "yes" ] && echo "identity"    >>${fo}
  [ "${webhost}" == "yes" ] && echo "webtier"     >>${fo}

  echo "#!/bin/bash" > ${startall}
  cat ${fo} | while read l ; do
    echo "start-${l}" >>${startall}
  done

  echo "#!/bin/bash" > ${stopall}
  tac ${fo} | while read l ; do
    echo "stop-${l}" >>${stopall}
  done

  chmod 0755 ${startall} ${stopall}
  rm -f ${fo}
}


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
  ln -sf ${env} ~/.env
  ln -sf ${bin} ~/bin
  ln -sf ${lib} ~/lib
  ln -sf ${crd} ~/.cred
  
  cp  ${src}/bin/iam*                 ${bin}/
  cp  ${src}/env/common.env           ${env}/
  cat ${src}/env/bash_profile       > ${HOME}/.bash_profile
  sed -i "s/_HOSTENV_/${_hostenv}/"   ${HOME}/.bash_profile

  _create_startall

  _cp_oim
  _cp_oam
  _cp_oud
  _cp_web
}

