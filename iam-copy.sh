#!/bin/sh

echo "*** Provisioning... at $(date)"

vagrant ssh oud1 -- "sudo tar cfz /mnt/oracle/shared/p-oud.tar.gz /opt/fmw/products/" >> /tmp/prov.log
vagrant ssh oud2 -- "sudo tar xfz /mnt/oracle/shared/p-oud.tar.gz --directory=/"      >> /tmp/prov.log

vagrant ssh oim1 -- "sudo tar cfz /mnt/oracle/shared/p-oim.tar.gz /opt/fmw/products/" >> /tmp/prov.log
vagrant ssh oim2 -- "sudo tar xfz /mnt/oracle/shared/p-oim.tar.gz --directory=/"      >> /tmp/prov.log

vagrant ssh oam1 -- "sudo tar cfz /mnt/oracle/shared/p-oam.tar.gz /opt/fmw/products/" >> /tmp/prov.log
vagrant ssh oam2 -- "sudo tar xfz /mnt/oracle/shared/p-oam.tar.gz --directory=/"      >> /tmp/prov.log

vagrant ssh web1 -- "sudo tar cfz /mnt/oracle/shared/p-web.tar.gz /opt/fmw/products/" >> /tmp/prov.log
vagrant ssh web2 -- "sudo tar xfz /mnt/oracle/shared/p-web.tar.gz --directory=/"      >> /tmp/prov.log

echo "*** Done at $(date)"

exit 0

