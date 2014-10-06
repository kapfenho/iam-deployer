#!/bin/sh

servers=( oud1 oud2 oim1 oim2 oam1 oam2 web1 web2 )

#  preverify install preconfigure configure configure-secondary postconfigure startup validate
rm -f /tmp/prov.log

echo "*** Starting at $(date)"
echo "*** Cleaning..."

vagrant ssh oud1 -- "sudo -u fmwuser -H -n /vagrant/testenv/resetonce.sh"
echo "*** --> Completed reset once"

for srv in ${servers[@]}
do
  vagrant ssh ${srv} -- "sudo -u fmwuser -H -n /vagrant/testenv/reset.sh"
  echo "*** --> Completed reset on ${srv}"
done

exit 0

