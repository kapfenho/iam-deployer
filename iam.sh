#!/bin/sh

set -o errexit
set -o nounset

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${_DIR}/lib/libcommon.sh
. ${_DIR}/lib/librcu.sh
. ${_DIR}/lib/libiam.sh
. ${_DIR}/user-config/iam.config

export JAVA_HOME=${s_runjdk}
export      PATH=${JAVA_HOME}/bin:${PATH}

umask ${iam_user_umask}

log "main" "start"

# set variables from provisioning config file
uc=${_DIR}/user-config/iam/provisioning.rsp

     s_repo=$(grep "INSTALL_INSTALLERS_DIR=" ${uc} | cut -d= -f2)
iam_mw_home=$(grep "COMMON_FMW_DIR="         ${uc} | cut -d= -f2)

# create_user_profile
add_vim_user_config

# deploy life cycle managment
deploy_lcm

# deployment and instance creation with lifecycle management
for step in preverify install preconfigure configure configure-secondary postconfigure startup validate
do
  deploy $step
done

# use urandom
for p in access dir identity web
do
  jdk_patch_config /appl/iam/fmw/products/$p/jdk6
done

for f in iam-dir iam-nodemanager iam-identity iam-access iam-webtier
do
  dest=/etc/init.d/$f
  [ -a $dest ] || sudo -n cp ${_DIR}/sys/redhat/rc.d/$f $dest
  sudo -n chmod 0755 $dest
  sudo -n chkconfig --add $f
done

# post installs from enterprise guide:
# patch_opss
# patch_oud
# patch_oud_config

log "main" "done"

exit 0

