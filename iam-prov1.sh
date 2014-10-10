#!/usr/bin/env bash

set -o errexit nounset

. ./env/dwp1/env.sh

echo "*** Provisioning..."

for step in preverify install 
do
  for srv in ${servers[@]}
  do
    echo "*** --> Starting ${step} on ${srv} at $(date)..."

    # vagrant ssh ${srv} -- "sudo -u fmwuser -H -n /vagrant/env/prov.sh ${step}" >> /tmp/prov.log
    on ${srv} "/vagrant/env/${ENV}/prov.sh ${step}" >> /tmp/prov.log

    if [[ $? -ne 0 ]]
    then
      echo "*** Error in this step ***"
      exit 77
    fi
    echo "*** --> Completed ${step} on ${srv} at $(date)"
  done
done

echo "*** Done at $(date)"

exit 0

