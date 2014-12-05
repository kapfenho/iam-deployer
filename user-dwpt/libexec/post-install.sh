#!/bin/sh

# post install tasks:
#   * patch OPSS
#   * patch OUD permissions
#
# IMPORTANT: task user-env must be executed before
#

set -o errexit nounset

. /opt/fmw/iam-deployer/user-config/env/env.sh

#_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# _DIR=/vagrant
# 
# . ${_DIR}/user-config/iam.config
# . ${_DIR}/lib/libcommon.sh
# . ${_DIR}/lib/libjdk.sh
# . ${_DIR}/lib/libiam.sh
# 
# export JAVA_HOME=${s_runjdk}
# export      PATH=${JAVA_HOME}/bin:${PATH}

_patch_opss() {

  ${idmtop}/products/access/iam/bin/psa \
    -response ${deployer}/user-config/iam/psa_access.rsp \
    -logLevel WARNING \
    -logDir /tmp

  ${idmtop}/products/identity/iam/bin/psa \
    -response ${deployer}/user-config/iam/psa_identity.rsp \
    -logLevel WARNING \
    -logDir /tmp
}


_patch_oud() {
  local c="dsconfig set-access-control-handler-prop --hostname $(hostname --long) --no-prompt -X"

  ${c} --remove global-aci:"(target=\"ldap:///cn=changelog\")(targetattr=\"*\")(version 3.0; acl \"External changelog access\"; deny (all) userdn=\"ldap:///anyone\";)"
  ${c} --add    global-aci:"(target=\"ldap:///cn=changelog\")(targetattr=\"*\")(version 3.0; acl \"External changelog access\"; allow (read,search,compare,add,write,delete,export) groupdn=\"ldap:///cn=OIMAdministrators,cn=groups,dc=agoracon,dc=at\";)"
  # ${c} --add    global-aci:"(targetcontrol="1.3.6.1.4.1.26027.1.5.4")(version 3.0; acl \"OIMAdministrators control access\";    allow (read) userdn=\"ldap:///anyone\";)"

}

_patch_oud_config() {
  log "patch_oud_conf" "starting"
  sed -iorig -e '/1\.2\.840\.113556\.1\.4\.319/s/ldap:\/\/\/all/ldap:\/\/\/anyone/g' ${INSTANCE_DIR}/OUD/config/config.ldif
  log "patch_oud_conf" "done"
}

# post installs from enterprise guide:
# _patch_opss
_patch_oud
# _patch_oud_config

exit 0

