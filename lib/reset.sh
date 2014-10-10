#!/bin/sh

rm -Rf /opt/fmw/*

sudo -n install --owner=fmwuser --group=fmwgroup --mode=0770 --directory /opt/fmw/products
sudo -n install --owner=fmwuser --group=fmwgroup --mode=0770 --directory /opt/fmw/config
sudo -n install --owner=fmwuser --group=fmwgroup --mode=0770 --directory /opt/fmw/config.local
sudo -n install --owner=fmwuser --group=fmwgroup --mode=0770 --directory /opt/fmw/provisioning

#killall -u fmwuser
ps fux
#ls -l /opt/fmw
