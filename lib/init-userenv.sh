#!/bin/sh

# * copy user environment settings
# * copy wlst property files

set -o errexit nounset
set -x

src=/vagrant/user-config/hostenv
dst=${HOME}/.env

case "$(hostname -s)" in
oim1)
oim2)
  cp ${src}/oim/common.env      ${dst}/
  cp ${src}/oim/identity.prop   ${dst}/
  sed -i "s/_HOST_/$(hostname -f)/" ${dst}/identity.prop
  ;;
oam1)
oam2)
  cp ${src}/oam/common.env      ${dst}/
  cp ${src}/oam/access.prop     ${dst}/
  sed -i "s/_HOST_/$(hostname -f)/" ${dst}/access.prop
  ;;
oud1)
oud2)
  cp ${src}/dir/common.env      ${dst}/
  cp ${src}/dir/tools.properies ${dst}/
  sed -i "s/_HOST_/$(hostname -f)/" ${dst}/tools.properties
  ;;
web1)
web2)
  cp ${src}/web/common.env      ${dst}/
  ;;
esac

