#!/bin/sh

# * copy user environment settings
# * copy wlst property files

src=/vagrant/user-config/hostenv
dst=${HOME}/.env

set -o errexit nounset
set -x

case "$(hostname -s)" in
*oim*)
  cp ${src}/oim/env/*               ${dst}/
  sed -i "s/_HOST_/$(hostname -f)/" ${dst}/identity.prop
  sed -i "s/_HOST_/$(hostname -f)/" ${dst}/imint.prop
  ;;
*oam*)
  cp ${src}/oam/*               ${dst}/
  sed -i "s/_HOST_/$(hostname -f)/" ${dst}/access.prop
  ;;
*oud*)
  cp ${src}/dir/common.env      ${dst}/
  cp ${src}/dir/tools.properies ${dst}/
  sed -i "s/_HOST_/$(hostname -f)/" ${dst}/tools.properties
  ;;
*idw*)
  cp ${src}/web/common.env      ${dst}/
  ;;
esac

