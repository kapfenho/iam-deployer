#!/bin/bash

set -o errexit nounset

. ${DEPLOYER}/user-config/iam.config
. ${DEPLOYER}/lib/env.sh
. ${DEPLOYER}/lib/libcommon2.sh

flog=/tmp/prov-$(date "+%Y%m%d-%H%M").log

# echo "*** LCM" | tee $flog
# 
# on oud1 "/vagrant/env/${ENV}/lcm.sh" | tee -a $flog

echo "*** Provisioning..." | tee -a $flog

for step in preverify install ; do
  for srv in ${servers[@]} ; do
    echo "*** --> Starting ${step} on ${srv} at $(date)..." | tee -a $flog
    on ${srv} "${DEPLOYER}/user-conf/env/prov.sh ${step}" >> $flog

    if [[ $? -ne 0 ]] ; then
      echo "*** Error in this step ***" | tee -a $flog
      exit 77
    fi
    echo "*** --> Completed ${step} on ${srv} at $(date)" | tee -a $flog
  done
done

echo "*** --> Fixing perf problem at $(date)" | tee -a $flog

for p in access identity dir ; do
  on oim1 "sed -i.orig 's/securerandom\.source=file:\/dev\/urandom/securerandom\.source=file:\/dev\/\.\/urandom/g' ${iam_top}/products/${p}/jdk6/jre/lib/security/java.security" | tee -a $flog
done

echo "*** Prov 2 at $(date)" | tee -a $flog

for step in preconfigure configure configure-secondary postconfigure startup validate ; do
  for srv in ${servers[@]} ; do
    echo "*** --> Starting ${step} on ${srv} at $(date)..." | tee -a $flog
    on ${srv} "/vagrant/user-conf/env/prov.sh ${step}" | tee -a $flog

    if [[ $? -ne 0 ]] ; then
      echo "*** Error in this step ***" | tee -a $flog
      exit 77
    fi
    echo "*** --> Completed ${step} on ${srv} at $(date)" | tee -a $flog
  done
done

echo "*** Done at $(date)" | tee -a $flog
exit 0

