#!/bin/sh

rm -f /tmp/prov.log
vagrant ssh oud1 -- "sudo -u fmwuser -H -n /vagrant/testenv/lcm.sh" >> /tmp/prov.log
