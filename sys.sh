#!/bin/sh

# Installation script for Oracle Identity and Access Management
# 
# This procedure will create the root script to execute before the
#+software installation.  You need to modify etc/configs.sh to
#+your needs.  Content of the root scripts:
#+ * user and group
#+ * base directory
#+ * system packages for fedora/redhat.
#

set -o errexit
set -o nounset

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

fedora_epel="${_DIR}/sys/redhat/epel-release-6-8.noarch.rpm"
ofile=${HOME}/root-script.sh

. ${_DIR}/lib/files.sh
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

set_sysctl_start
set_sysctl   'kernel.msgmnb'                 '65536'
set_sysctl   'kernel.msgmnb'                 '65536'
set_sysctl   'kernel.msgmax'                 '65536'
set_sysctl   'kernel.shmmax'                 '17179869184'
set_sysctl   'kernel.shmall'                 '16777216'
set_sysctl   'kernel.shmmni'                 '4096'
set_sysctl   'kernel.sem'                    '250 32000 100 128'

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
set_sysctl_end
echo

activate_sysctl
echo

set_limit         '*          soft    nofile       2048' 
set_limit         '*          hard    nofile       8192' 
set_limit         '@oracle    soft    nofile      65536'
set_limit         '@oracle    hard    nofile      65536'
set_limit         '@oracle    soft    stack       10240'
set_limit         '@iam       soft    nofile     150000'
set_limit         '@iam       soft    nofile     150000'
set_proc_limit    '*          soft    nproc        2048' 
set_proc_limit    '*          hard    nproc       16384' 
echo

packs=(
    binutils.x86_64
    compat-libcap1.x86_64
    compat-libstdc++-33.i686
    compat-libstdc++-33.x86_64
    elfutils-libelf-devel.x86_64
    gcc-c++.x86_64
    gcc.x86_64
    glibc-devel.i686
    glibc-devel.x86_64
    glibc.x86_64
    glibc.i686
    ksh.x86_64
    libaio-devel.i686
    libaio-devel.x86_64
    libaio.x86_64
    libaio.i686
    libgcc.x86_64
    libstdc++-devel.i686
    libstdc++-devel.x86_64
    libstdc++.i686
    libstdc++.x86_64
    libXext.i686
    libXtst.i686
    libXi.i686
    make.x86_64
    openmotif.x86_64
    openmotif22.x86_64
    redhat-lsb-core.x86_64
    sysstat.x86_64
    unixODBC-devel
    nfs-utils
    unzip
    rlwrap
    vim-enhanced )

add_epel_rpm ${fedora_epel}
echo

add_packages packs
echo

disable_service   'iptables'
disable_service   'ip6tables'

add_vim_features_p

#echo "mount -t nfs -o nolock,proto=tcp,port=2049 nyx:/instora /mnt/orainst"
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

