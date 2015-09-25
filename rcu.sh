#!/bin/sh
#
#  oracle rcu wrapper
#  create or remove database schema for IAM
#
#  * Configuration in  user-config/iam.config
# 
#  * Create schemas
#      Execute without parameters
#        ./run-rcu.hs
#
#  * Drop schemas
#      specify any parameter
#        ./run-rcu.sh drop
#
#  http://docs.oracle.com/html/E38978_01/r2_im_requirements.htm#CIHEDGIH
#  horst.kapfenberger@agoracon.at, 2014-09-10
#  vim: set ft=sh :

set -o errexit nounset

. ${DEPLOYER}/user-config/iam.config
. ${DEPLOYER}/lib/libcommon2.sh
. ${DEPLOYER}/lib/librcu.sh

if [ -z ${DEPLOYER} ] ; then
  error "Environment variable DEPLOYER not set!"
  exit 80
fi

export DO_ACC DO_IDM DO_BIP

# -------------------------------------------------------
echo

if [ ${#} -gt 0 -a "${1}" == "-d" ]
then
  log "*** Dropping schemas ***"
  if [[ -t 1 ]]; then
    log "  press RETURN to continue or Ctrl-C to stop"
    read cont
  fi
  do_idm && rcu_drop_identity
  do_acc && rcu_drop_access
  do_bip && rcu_drop_bi_publisher
else
  log "*** Creating schemas ***"
  if [[ -t 1 ]]; then
    log "  press RETURN to continue or Ctrl-C to stop"
    read cont
  fi
  do_idm && rcu_identity
  do_acc && rcu_access
  do_bip && rcu_bi_publisher
fi

log "*** Schema actions finished. ***"

exit 0

