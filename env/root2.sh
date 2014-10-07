#!/bin/sh

set -x

rm -Rf /usr/fmw

install --owner=fmwuser --group=fmwgroup --mode=0770 --directory /opt/fmw               # configs
install --owner=fmwuser --group=fmwgroup --mode=0770 --directory /opt/fmw/products      # binaries

set +x

