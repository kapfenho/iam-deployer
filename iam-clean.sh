#!/usr/bin/env bash

set -o errexit nounset
. ./user-conf/env/env.sh

rm -f /tmp/prov.log

# on ${servers[0]} "...reset once..."
# vagrant ssh oud1 -- 'sudo /vagrant/lib/resetonce.sh'

# for h in ${servers[@]}
# do
#   vagrant ssh $h -- 'sudo /vagrant/lib/reset.sh'
# done

exit 0

