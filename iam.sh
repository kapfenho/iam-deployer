#!/bin/sh

set -o errexit
set -o nounset

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${_DIR}/lib/files.sh
. ${_DIR}/lib/libcommon.sh
. ${_DIR}/lib/librcu.sh
. ${_DIR}/lib/libiam.sh
. ${_DIR}/user-config/iam.config

export JAVA_HOME=${s_runjdk}
export      PATH=${JAVA_HOME}/bin:${PATH}

umask ${iam_user_umask}

log "main" "start"

# set variables from provisioning config file
local uc=${_DIR}/user-config/iam/provisioning.rsp

     s_repo=$(grep "INSTALL_INSTALLERS_DIR=" ${uc} | cut -d= -f2)
      s_lcm=$(grep "INSTALL_LCMHOME_DIR="    ${uc} | cut -d= -f2)
iam_mw_home=$(grep "COMMON_FMW_DIR="         ${uc} | cut -d= -f2)
   s_runjre=${s_repo}/jdk/jdk6/jre

get_variables
create_user_profile
add_vim_user_config

# deploy life cycle managment
deploy_lcm

# deployment and instance creation with lifecycle management
for step in preverify install preconfigure configure configure-secondary postconfigure startup validate ; do
  deploy $step
done

for p in access dir identity web ; do
  jdk_patch_config /appl/iam/fmw/products/$p/jdk6
done

patch_opss
patch_oud
patch_oud_config

# post installs from enterprise guide:
#
# http://docs.oracle.com/cd/E40329_01/doc.1112/e48618/postprov.htm#CHDGABDA

# fixes:
# a) weblogic user

# install:
# * oud:
#     /mnt/orainst/iam-11.1.2.2/repo/installers/oud/Disk1/install/linux64/oraparam.ini
#     PREREQ_CONFIG_LOCATION= 
#     swap space down
#   rolled back and used:
#     + patch for os and lins
#     + manually patches swap space req

log "main" "done"

# all steps:
# * install
# * preconfigure
# * configure
# * configure-secondary
# * postconfigure
# * startup
# * validate

exit 0

