#!/bin/sh
#
#  copy user environment settings
#

src=${DEPLOYER}/lib/templates/hostenv
env=${HOME}/.env
bin=${HOME}/bin
lib=${HOME}/lib
crd=${HOME}/.creds

set -o errexit nounset

cp_oim() {
  cp ${src}/bin/*identity*          ${bin}/
  cp ${src}/bin/*nodemanager*       ${bin}/
  cp ${src}/env/idm.env             ${env}/
  cp ${src}/env/idm-deplenv.env     ${env}/
  cp ${src}/env/identity.prop       ${env}/
  cp ${src}/env/imint.prop          ${env}/
  cp ${src}/lib/deploy.py           ${lib}/
  sed -i "s/_HOST_/$(hostname -f)/" ${env}/*
  sed -i "s/_HOST_/$(hostname -f)/" ${bin}/*
  sed -i "s/_DOMAIN_/${IDMPROV_IDENTITY_DOMAIN}/" ${env}/*
}
cp_oam() {
  cp ${src}/bin/*access*            ${bin}/
  cp ${src}/bin/*nodemanager*       ${bin}/
  cp ${src}/env/acc.env             ${env}/
  cp ${src}/env/access.prop         ${env}/
  sed -i "s/_HOST_/$(hostname -f)/" ${env}/*
  sed -i "s/_HOST_/$(hostname -f)/" ${bin}/*
  sed -i "s/_DOMAIN_/${IDMPROV_ACCESS_DOMAIN}/" ${env}/*
}
cp_oud() {
  cp ${src}/bin/*dir*               ${bin}/
  cp ${src}/env/dir.env             ${env}/
  cp ${src}/env/tools.properties    ${env}/
  sed -i "s/_HOST_/$(hostname -f)/" ${env}/*
}
cp_web() {
  cp ${src}/bin/*webtier*           ${bin}/
  cp ${src}/env/web.env             ${env}/
}

set -x

mkdir -p ${env} ${bin} ${lib} ${crd}

cp  ${src}/bin/iam*                 ${bin}/
cp  ${src}/env/common.env           ${env}/
cat ${src}/env/bash_profile >> ${HOME}/.bash_profile

case "$(hostname -s)" in
  dwptoim[34]    ) cp_oim ; cp_oam ; cp_oud ; cp_web ;;
  dwp[tp]oim[12] ) cp_oim ;;
  dwp[tp]oam[12] ) cp_oam ;;
  dwp[tp]oud[12] ) cp_oud ;;
  dwp[tp]idw[12] ) cp_web ;;
esac

set +x

