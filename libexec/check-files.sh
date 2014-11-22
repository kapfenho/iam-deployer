#!/bin/sh

dst=/etc/rc.d/init.d
src=/vagrant/user-config/rc.d

ds1=/home/fmwuser/.env
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
  check $src/iamnm             $dst
  check $src/oim1/iamadmin     $dst
  check $src/oim1/iamsoa       $dst
  check $src/oim1/iamoim       $dst
  check $src/oim1/wls-identity $dst

  check $sr1/oim/common.env    $ds1
  check $sr1/oim/identity.prop $ds1
  ;;
oim2)
  check $src/functions-wls     $dst
  check $src/iamnm             $dst
  check $src/oim2/iamsoa       $dst
  check $src/oim2/iamoim       $dst
  check $src/oim2/wls-identity $dst

  check $sr1/oim/common.env    $ds1
  check $sr1/oim/identity.prop $ds1
  ;;
oam1)
  check $src/functions-wls     $dst
  check $src/iamnm             $dst
  check $src/oam1/iamadmin     $dst
  check $src/oam1/iamoam       $dst
  check $src/oam1/wls-access   $dst

  check $sr1/oam/common.env    $ds1
  check $sr1/oim/access.prop   $ds1
  ;;
oam2)
  check $src/functions-wls     $dst
  check $src/iamnm             $dst
  check $src/oam2/iamoam       $dst
  check $src/oam2/wls-access   $dst

  check $sr1/oam/common.env    $ds1
  check $sr1/oim/access.prop   $ds1
  ;;
oud1)
  check $src/oud1/iamdir       $dst

  check $sr1/dir/common.env    $ds1
  check $sr1/dir/tools.properties $ds1
  ;;
oud2)
  check $src/oud2/iamdir       $dst

  check $sr1/dir/common.env    $ds1
  check $sr1/dir/tools.properties $ds1
  ;;
web1)
  check $src/web1/iamweb       $dst

  check $sr1/web/common.env    $ds1
  ;;
web2)
  check $src/web2/iamweb       $dst

  check $sr1/web/common.env    $ds1
  ;;
esac

