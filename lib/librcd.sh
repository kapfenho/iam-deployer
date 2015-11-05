#!/bin/bash

# deploy rc.d scripts, see AUTOSTART file for more info

   dst=/etc/rc.d/init.d
dstcfg=/etc/weblogic

   src=/vagrant/user-config/rc.d

set -o errexit nounset
set -x

case "$(hostname -s)" in
oim1)
  cp $src/functions-wls      $dst
  cp $src/iam-node           $dst
  cp $src/oim1/iami-admin    $dst
  cp $src/oim1/iami-soa      $dst
  cp $src/oim1/iami-oim      $dst

  [ -d $dstcfg ] || mkdir -p $dstcfg
  cp $src/oim1/wls-identity  $dstcfg

  for s in iam-node iami-admin iami-soa iami-oim ; do
    chmod 0755 $dst/$s
    chkconfig --add $s
    chkconfig $s on
  done
  ;;
oim2)
  cp $src/functions-wls      $dst
  cp $src/iam-node           $dst
  cp $src/oim2/iami-soa      $dst
  cp $src/oim2/iami-oim      $dst

  [ -d $dstcfg ] || mkdir -p $dstcfg
  cp $src/oim1/wls-identity  $dstcfg

  for s in iam-node iami-soa iami-oim ; do
    chmod 0755 $dst/$s
    chkconfig --add $s
    chkconfig $s on
  done
  ;;
oam1)
  cp $src/functions-wls      $dst
  cp $src/iam-node           $dst
  cp $src/oam1/iama-admin    $dst
  cp $src/oam1/iama-oam      $dst

  [ -d $dstcfg ] || mkdir -p $dstcfg
  cp $src/oim1/wls-identity  $dstcfg

  for s in iam-node iama-admin iama-oam ; do
    chmod 0755 $dst/$s
    chkconfig --add $s
    chkconfig $s on
  done
  ;;
oam2)
  cp $src/functions-wls      $dst
  cp $src/iam-node           $dst
  cp $src/oam2/iama-oam      $dst

  [ -d $dstcfg ] || mkdir -p $dstcfg
  cp $src/oim1/wls-identity  $dstcfg

  for s in iam-node iama-oam ; do
    chmod 0755 $dst/$s
    chkconfig --add $s
    chkconfig $s on
  done
  ;;
oud1)
  cp $src/oud1/iam-dir       $dst
  chmod 0755 $dst/iam-dir
  chkconfig --add iam-dir
  chkconfig iam-dir on
  ;;
oud2)
  cp $src/oud2/iam-dir       $dst
  chmod 0755 $dst/iam-dir
  chkconfig --add iam-dir
  chkconfig iam-dir on
  ;;
web1)
  cp $src/web1/iam-web       $dst
  chmod 0755 $dst/iam-web
  chkconfig --add iam-web
  chkconfig iam-web on
  ;;
web2)
  cp $src/web2/iam-web       $dst
  chmod 0755 $dst/iam-web
  chkconfig --add iam-web
  chkconfig iam-web on
  ;;
esac
set +x

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

