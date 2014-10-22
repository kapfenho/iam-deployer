#!/usr/bin/env bash

set -o errexit nounset
export deployer=/opt/install/dwpbank/iam-deployer
. ${deployer}/user-conf/env/env.sh
#  init done

rm -Rf ${idmtop}/products/*
rm -Rf ${idmtop}/config/*
rm -Rf ${idmtop}/local/*

sudo -n install --owner=fmwuser --group=fmwgroup --mode=0770 --directory /opt/fmw/products
sudo -n install --owner=fmwuser --group=fmwgroup --mode=0770 --directory /opt/fmw/config
sudo -n install --owner=fmwuser --group=fmwgroup --mode=0770 --directory /opt/fmw/config.local

#killall -u fmwuser
ps fux
ls -l /opt/fmw
