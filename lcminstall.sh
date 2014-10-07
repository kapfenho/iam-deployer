#!/bin/sh

rm -Rf /tmp/prov.log /mnt/oracle/shared/idmlcm/*

vagrant ssh oud1 -- "sudo -u fmwuser -H -n /vagrant/env/lcm.sh" >> /tmp/prov.log
