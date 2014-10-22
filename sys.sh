#!/bin/sh

#  System preparation script for Oracle Identity and Access Management
# 
#  This script will create a root script to execute before you continue 
#+ with the application installation. Read the README and change the 
#+ user-configuration according your needs.
#+
#+ Content of root script:
#+  * users and groups
#+  * base directory
#+  * system packages for fedora/redhat.
#

set -o errexit
set -o nounset

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

fedora_epel="${_DIR}/sys/redhat/epel-release-6-8.noarch.rpm"
ofile=${HOME}/root-script.sh

. ${_DIR}/lib/libcommon.sh
. ${_DIR}/lib/libsysprint.sh

for c in ${_DIR}/user-config/*.config ; do
  . ${c}
done
dbs_group=${dbs_group:-oinstall}
iam_group=${iam_group:-iam}

dbs_user=${dbs_user:-dbs}
iam_user=${iam_user:-iam}

# redirect to output file
exec 6>&1 ; exec > ${ofile}

echo "#!/bin/sh"
echo "#  execute as root user"
echo "if [ \$UID -ne 0 ] ; then echo \"ERROR: not root\" ; exit 77 ; fi"
echo "set -x"

# fusion     http://docs.oracle.com/html/E38978_01/r2_im_requirements.html
# database   http://docs.oracle.com/cd/E11882_01/install.112/e24326/toc.htm#BHCCADGD
#
set_sysctl_start

set_sysctl   'kernel.shmmax'                 '17179869184'
set_sysctl   'kernel.sem'                    '256 32000 100 142'

echo "# --- database specific start ----"
set_sysctl   'kernel.msgmnb'                 '65536'
set_sysctl   'kernel.msgmax'                 '65536'
set_sysctl   'kernel.shmall'                 '16777216'
set_sysctl   'kernel.shmmni'                 '4096'

set_sysctl   'fs.file-max'                   '6815744'
set_sysctl   'fs.aio-max-nr'                 '1048576'

set_sysctl   'net.ipv4.tcp_keepalive_time'   '1800'
set_sysctl   'net.ipv4.tcp_keepalive_intvl'  '30'
set_sysctl   'net.ipv4.tcp_keepalive_probes' '5'
set_sysctl   'net.ipv4.tcp_fin_timeout'      '30'
set_sysctl   'net.ipv4.ip_local_port_range'  '9000 65500'

set_sysctl   'net.core.rmem_default'         '262144'
set_sysctl   'net.core.rmem_max'             '4194304'
set_sysctl   'net.core.wmem_default'         '262144'
set_sysctl   'net.core.wmem_max'             '1048576'
echo "# --- database specific end ----"

set_sysctl_end
echo

activate_sysctl
echo

# --- Security Limits ---

# database
echo >> /etc/security/limits.d/91-database.conf <<-EOF
@dba       soft    nofile      65536
@dba       hard    nofile      65536
@dba       soft    stack       10240
EOF

# fusion
echo >> /etc/security/limits.d/91-fusion.conf <<-EOF
@fmwgroup  soft    nofile     150000
@fmwgroup  hard    nofile     150000
@fmwgroup  soft    nproc        2048
@fmwgroup  hard    nproc       16384
EOF

echo

# --- System Packages ---

# Fusion 64bit
packs_fusion64=(
  binutils
  compat-libcap1
  compat-libstdc++-33
  gcc
  gcc-c++
  glibc
  libaio
  libaio-devel
  libgcc
  libstdc++
  libstdc++-devel
  libXext
  libXtst
  make
  openmotif
  openmotif22
  redhat-lsb-core
  sysstat
  xorg-x11-utils
  xorg-x11-apps
  xorg-x11-xinit
  xorg-x11-server-Xorg
  xterm )

# Fusion needs additional 32bit libs
packs_fusion32=(
  compat-libstdc++-33.i686
  glibc-devel.i686
  glibc.i686
  libstdc++-devel.i686
  libstdc++.i686
  libXext.i686
  libXtst.i686
  libXi.i686 )

# database server and rcu
packs_database=(
  elfutils-libelf-devel
  glibc-devel
  ksh
  libaio-devel.i686
  libaio.i686 )

# additional
packs_utils=(
  nfs-utils
  unzip
  rlwrap
  tmux
  vim-enhanced )

update_repo
add_epel_rpm ${fedora_epel}
echo

add_packages packs_fusion64
echo
add_packages packs_fusion32
echo
add_packages packs_database
echo
add_packages packs_utils
echo

disable_service   'iptables'
disable_service   'ip6tables'

# --- Users Groups Directories ---

# groups     name             id
create_group "oinstall"       6001
create_group "dba"            6002
create_group ${iam_group}     6004
echo

# users      name           id    group   add-groups
create_user  ${dbs_user}    5001  "6001"  "6002" "500"      # database
create_user  ${iam_user}    5003  "6004"  "6001"            # oam, oim
echo

sudo_for     ${dbs_user}
sudo_for     ${iam_user}
echo

dir_for      ${dbs_app}    "${dbs_user}:${dbs_group}"
dir_for      ${iam_app}    "${iam_user}:${iam_group}"
dir_for      ${iam_log}    "${iam_user}:${iam_group}"
echo

echo
echo "set +x"

# get back stdout
exec 1>&6 6>&-

chmod +x ${ofile}

echo "
Script file has been generated: ${ofile}
Execute this script now with root permissions, then continue with next step.
"

exit 0

