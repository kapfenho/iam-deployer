#!/bin/sh

rm -Rf /opt/fmw/products/*
rm -Rf /opt/fmw/config/*
rm -Rf /opt/fmw/config.local/*

sudo -n install --owner=fmwuser --group=fmwgroup --mode=0770 --directory /opt/fmw/products
sudo -n install --owner=fmwuser --group=fmwgroup --mode=0770 --directory /opt/fmw/config
sudo -n install --owner=fmwuser --group=fmwgroup --mode=0770 --directory /opt/fmw/config.local

#killall -u fmwuser
ps fux
ls -l /opt/fmw
