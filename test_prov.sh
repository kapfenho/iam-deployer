#!/bin/sh

servers=( oud1 oud2 oim1 oim2 oam1 oam2 web1 web2 )

echo "*** Provisioning..."
#for step in preverify install preconfigure configure configure-secondary postconfigure startup validate
for step in preverify install 
do
  for srv in ${servers[@]}
  do
    echo "*** --> Starting ${step} on ${srv} at $(date)..."
    vagrant ssh ${srv} -- "sudo -u fmwuser -H -n /vagrant/testenv/prov.sh ${step}" >> /tmp/prov.log
    echo "*** --> Completed ${step} on ${srv} at $(date)"
  done
done

echo "*** Done at $(date)"

exit 0

