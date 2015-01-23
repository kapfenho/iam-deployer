#!/bin/sh

# post install tasks:
#   * patch OPSS
#   * patch OUD permissions
#
# IMPORTANT: task user-env must be executed before
#

set -o errexit nounset

#_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# _DIR=/vagrant
# 
# . ${_DIR}/user-config/iam.config
# . ${_DIR}/lib/libcommon.sh
# . ${_DIR}/lib/libjdk.sh
# . ${_DIR}/lib/libiam.sh

#export JAVA_HOME=${s_runjdk}
#export      PATH=${JAVA_HOME}/bin:${PATH}
#
#umask ${iam_user_umask}


_patch_opss() {
  /opt/fmw/products/access/iam/bin/psa \
    -response /vagrant/user-config/iam/psa_access.rsp \
    -logLevel WARNING \
    -logDir /tmp

  /opt/fmw/products/identity/iam/bin/psa \
    -response /vagrant/user-config/iam/psa_identity.rsp \
    -logLevel WARNING \
    -logDir /tmp
}

_patch_oud() {
  local c="dsconfig set-access-control-handler-prop -X --hostname $(hostname --long) --no-prompt"

  ${c} --remove global-aci:"(target=\"ldap:///cn=changelog\")(targetattr=\"*\")(version 3.0; acl \"External changelog access\"; deny (all) userdn=\"ldap:///anyone\";)"
  ${c} --add    global-aci:"(target=\"ldap:///cn=changelog\")(targetattr=\"*\")(version 3.0; acl \"External changelog access\"; allow (read,search,compare,add,write,delete,export) groupdn=\"ldap:///cn=OIMAdministrators,cn=groups,dc=dwpbank,dc=net\";)"
  echo "Dont forget to correct 1.2.840.113556.1.4.319!"
  echo
}

# set variables from provisioning config file
# uc=${_DIR}/user-config/iam/provisioning.rsp
# 
#      s_repo=$(grep "INSTALL_INSTALLERS_DIR=" ${uc} | cut -d= -f2)
# iam_mw_home=$(grep "COMMON_FMW_DIR="         ${uc} | cut -d= -f2)

# post installs from enterprise guide:
# _patch_opss
_patch_oud

exit 0

