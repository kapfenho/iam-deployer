#!/bin/sh
#  execute as root user
if [ $UID -ne 0 ] ; then echo "ERROR: not root" ; exit 77 ; fi
set -x

ln -fs /usr/share/zoneinfo/Europe/Vienna /etc/localtime

#  http://docs.oracle.com/database/121/LADBI/app_manual.htm#CIHGDACA
#
#  semmsl            250   /proc/sys/kernel/sem  250 32000 100 128
#  semmns          32000
#  semopm            100
#  semmni            128
#
#  shmall    40 % of physical memory in pages (of 4KB)
#                          /proc/sys/kernel/shmall
#
#  shmmax    50 % of physical memory in bytes
#                          /proc/sys/kernel/shmmax
#
#  shmmni           4096   /proc/sys/kernel/shmmni
# 
#  panic_on_oops       1   /proc/sys/kernel/panic_on_oops
#
#  file-max      6815744   /proc/sys/fs/file-max
#
#  aio-max-nr    1048576   /proc/sys/fs/aio-max-nr
#
#  ip_local_port_range 9000 - 65500
#                          /proc/sys/net/ipv4/ip_local_port_range
#
#  rmem_default   262144   /proc/sys/net/core/rmem_default
#  rmem_max      4194394   /proc/sys/net/core/rmem_max
#  wmem_default   262144   /proc/sys/net/core/wmem_default
#  wmem_max      1048576   /proc/sys/net/core/wmem_max
#
cat >> /etc/sysctl.conf <<-EOS
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 4294967295
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
EOS

#echo "NETWORKING_IPV6=no" >> /etc/sysconfig/network
#echo "IPV6INIT=no" >> /etc/sysconfig/network

/sbin/sysctl -p

#   system packages
yum check-update
yum install -y epel-release
yum check-update
yum -y upgrade

yum install -y  binutils.x86_64 \
                compat-libcap1.x86_64 \
                compat-libstdc++-33.x86_64 \
                gcc.x86_64 \
                gcc-c++.x86_64 \
                glibc.x86_64 \
                glibc-devel.x86_64 \
                ksh.x86_64 \
                libaio.x86_64 \
                libaio-devel.x86_64 \
                libgcc.x86_64 \
                libstdc++.x86_64 \
                libstdc++-devel.x86_64 \
                libXi.x86_64 \
                libXtst.x86_64 \
                make.x86_64 \
                sysstat.x86_64

yum install -y  glibc.i686 \
                glibc-devel.i686 \
                libaio.i686 \
                libgcc.i686 \
                libstdc++.i686 \
                libstdc++-devel.i686 \
                libXi.i686 \
                libXtst.i686 \
                libaio-devel.i686

#   additional utilities
yum install -y  nfs-utils \
                unzip \
                rlwrap \
                tmux \
                telnet \
                nc \
                vim-enhanced \
                git


# --- users group dirs ---

groupadd -g 6200 oinstall
groupadd -g 6201 dba

useradd -u 5200 -g 6200 -G dba oracle

echo "oracle  ALL=(ALL)  NOPASSWD: ALL" > /etc/sudoers.d/oracle
chmod 440 /etc/sudoers.d/oracle

cat >> /etc/security/limits.d/90-oracle.conf <<-EOF
oracle     soft    nofile      65536
oracle     hard    nofile      65536
oracle     soft    nproc       16384
oracle     hard    nproc       16384
oracle     soft    stack       10240
EOF

install  --owner=oracle  --group=oinstall --mode=0775 --directory /var/log/oracle        # logs (local)
install  --owner=oracle  --group=oinstall --mode=0775 --directory /opt/oracle            # products, config (shared, rw)
install  --owner=fmwuser --group=fmwgroup --mode=0775 --directory /mnt/oracle            # images (shared, ro)

# shared mount points must be manually added
#echo "nyx:/export/oracle /mnt/oracle  nfs  rw,bg,hard,nointr,proto=udp,vers=3,timeo=300,rsize=32768,wsize=32768  0 0" >> /etc/fstab
echo "nyx:/export/oracle /mnt/oracle  nfs  rw,bg,hard,nointr  0 0" >> /etc/fstab

mount /mnt/oracle

cp /etc/redhat-release /root/redhat-release.orig
echo "Red Hat Enterprise Linux Server release 7.1 (Maipo)" >>/etc/redhat-release

set +x
exit 0
