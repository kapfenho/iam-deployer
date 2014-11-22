#!/bin/sh

dst=/etc/rc.d/init.d
src=/vagrant/user-config/rc.d

set -o errexit nounset
set -x

case "$(hostname -s)" in
oim1)
  cp $src/functions-wls     $dst
  cp $src/iamnm             $dst
  cp $src/oim1/iamadmin     $dst
  cp $src/oim1/iamsoa       $dst
  cp $src/oim1/iamoim       $dst
  cp $src/oim1/wls-identity $dst
  chkconfig --add iamnm
  chkconfig --add iamadmin
  chkconfig --add iamsoa
  chkconfig --add iamoim
  ;;
oim2)
  cp $src/functions-wls     $dst
  cp $src/iamnm             $dst
  cp $src/oim2/iamsoa       $dst
  cp $src/oim2/iamoim       $dst
  cp $src/oim2/wls-identity $dst
  chkconfig --add iamnm
  chkconfig --add iamsoa
  chkconfig --add iamoim
  ;;
oam1)
  cp $src/functions-wls     $dst
  cp $src/iamnm             $dst
  cp $src/oam1/iamadmin     $dst
  cp $src/oam1/iamoam       $dst
  cp $src/oam1/wls-access   $dst
  chkconfig --add iamnm
  chkconfig --add iamadmin
  chkconfig --add iamoam
  ;;
oam2)
  cp $src/functions-wls     $dst
  cp $src/iamnm             $dst
  cp $src/oam2/iamoam       $dst
  cp $src/oam2/wls-access   $dst
  chkconfig --add iamnm
  chkconfig --add iamoam
  ;;
oud1)
  cp $src/oud1/iamdir       $dst
  chkconfig --add iamdir
  ;;
oud2)
  cp $src/oud2/iamdir       $dst
  chkconfig --add iamdir
  ;;
web1)
  cp $src/web1/iamweb       $dst
  chkconfig --add iamweb
  ;;
web2)
  cp $src/web2/iamweb       $dst
  chkconfig --add iamweb
  ;;
esac
set +x

