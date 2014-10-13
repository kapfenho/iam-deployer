#!/usr/bin/env bash

set -o errexit nounset

. ./env/dwp1/env.sh

rm -f /tmp/prov.log

vagrant ssh oud1 -- 'sudo /vagrant/lib/resetonce.sh'

for h in ${servers[@]}
do
  vagrant ssh $h -- 'sudo /vagrant/lib/reset.sh'
done

exit 0

