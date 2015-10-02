#!/bin/bash -x
#
#  copy user environment settings
#

src=${DEPLOYER}/lib/templates/hostenv
nodesrc=${DEPLOYER}/lib/templates/nodemanager
env=${iam_hostenv}/env
bin=${iam_hostenv}/bin
lib=${iam_hostenv}/lib
crd=${iam_hostenv}/.creds

_hostenv=$(echo ${iam_hostenv} | sed -e 's/[\/&]/\\&/g')
    _top=$(echo ${iam_top}     | sed -e 's/[\/&]/\\&/g')
    _log=$(echo ${iam_log}     | sed -e 's/[\/&]/\\&/g')
# set -o errexit nounset

cp_nodemanager() {
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
cp_oim() {
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
  cp_nodemanager
}
cp_oam() {
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
  cp_nodemanager
}
cp_oud() {
  [ "${oudhost}" != "yes" ] && return

  cp ${src}/bin/*dir*               ${bin}/
  cp ${src}/env/dir.env             ${env}/
  cp ${src}/env/tools.properties    ${env}/
  sed -i "s/_HOSTENV_/${_hostenv}/" ${env}/*
  sed -i "s/_IAMTOP_/${_top}/"      ${env}/*
  sed -i "s/_IAMLOG_/${_log}/"      ${env}/*
  sed -i "s/_HOST_/$(hostname -f)/" ${env}/*
}
cp_web() {
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

set -x

mkdir -p ${env} ${bin} ${lib} ${crd}
ln -sf ${env} ~/.env
ln -sf ${bin} ~/bin
ln -sf ${lib} ~/lib
ln -sf ${crd} ~/.cred

cp  ${src}/bin/iam*                 ${bin}/
cp  ${src}/env/common.env           ${env}/
cat ${src}/env/bash_profile       > ${HOME}/.bash_profile
sed -i "s/_HOSTENV_/${_hostenv}/"   ${HOME}/.bash_profile

cp_oim
cp_oam
cp_oud
cp_web

# Case "$(hostname -s)" in
#   dwptoim[34]    ) cp_oim ; cp_oam ; cp_oud ; cp_web ;;
#   dwp[tp]oim[12] ) cp_oim ;;
#   dwp[tp]oam[12] ) cp_oam ;;
#   dwp[tp]oud[12] ) cp_oud ;;
#   dwp[tp]idw[12] ) cp_web ;;
# Esac

# set +x

