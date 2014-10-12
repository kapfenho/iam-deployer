#!/usr/bin/env bash

set -o errexit nounset

. ./env/dwp1/env.sh

#  preverify install preconfigure configure configure-secondary postconfigure startup validate
rm -f /tmp/prov.log

echo "*** Starting at $(date)"
echo "*** Cleaning..."

# c="rm -Rf ${lcmhome}/*"
# echo "---> ${c}"
# ${c}

echo "*** --> Completed reset once"

on_all /vagrant/lib/reset.sh

# for srv in ${servers[@]}
# do
#   vagrant ssh ${srv} -- "sudo -u fmwuser -H -n /vagrant/lib/reset.sh"
#   echo "*** --> Completed reset on ${srv}"
# done

exit 0

