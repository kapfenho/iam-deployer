#!/bin/bash

# compare the deployed files with the repo version

   dst=/etc/rc.d/init.d
dstcfg=/etc/weblogic
   ds1=${HOME}/.env

   src=/vagrant/user-config/rc.d
   sr1=/vagrant/user-config/hostenv

set -o errexit nounset

check() {
  _d=${2}/$(basename ${1})
  if ! cmp ${1} ${_d} ; then
    echo "${_d}"
  fi
}

case "$(hostname -s)" in
oim1)
  check $src/functions-wls     $dst
  check $src/iam-node          $dst
  check $src/oim1/iami-admin   $dst
  check $src/oim1/iami-soa     $dst
  check $src/oim1/iami-oim     $dst
  check $src/oim1/wls-identity $dstcfg

  check $sr1/oim/common.env    $ds1
  check $sr1/oim/identity.prop $ds1
  ;;
oim2)
  check $src/functions-wls     $dst
  check $src/iam-node          $dst
  check $src/oim2/iami-soa     $dst
  check $src/oim2/iami-oim     $dst
  check $src/oim2/wls-identity $dstcfg

  check $sr1/oim/common.env    $ds1
  check $sr1/oim/identity.prop $ds1
  ;;
oam1)
  check $src/functions-wls     $dst
  check $src/iam-node          $dst
  check $src/oam1/iama-admin   $dst
  check $src/oam1/iama-oam     $dst
  check $src/oam1/wls-access   $dstcfg

  check $sr1/oam/common.env    $ds1
  check $sr1/oim/access.prop   $ds1
  ;;
oam2)
  check $src/functions-wls     $dst
  check $src/iam-node          $dst
  check $src/oam2/iama-oam     $dst
  check $src/oam2/wls-access   $dstcfg

  check $sr1/oam/common.env    $ds1
  check $sr1/oim/access.prop   $ds1
  ;;
oud1)
  check $src/oud1/iam-dir      $dst

  check $sr1/dir/common.env    $ds1
  check $sr1/dir/tools.properties $ds1
  ;;
oud2)
  check $src/oud2/iam-dir      $dst

  check $sr1/dir/common.env    $ds1
  check $sr1/dir/tools.properties $ds1
  ;;
web1)
  check $src/web1/iam-web      $dst

  check $sr1/web/common.env    $ds1
  ;;
web2)
  check $src/web2/iam-web      $dst

  check $sr1/web/common.env    $ds1
  ;;
esac

