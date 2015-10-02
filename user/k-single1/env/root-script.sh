#!/bin/sh
#  execute as root user
if [ $UID -ne 0 ] ; then echo "ERROR: not root" ; exit 77 ; fi
set -x

ln -sf /usr/share/zoneinfo/Europe/Vienna /etc/localtime

echo "# customizations oracle start" >> /etc/sysctl.conf
sed -i -e "/kernel.shmmax/d" /etc/sysctl.conf ; echo "kernel.shmmax=17179869184" >> /etc/sysctl.conf
echo "kernel.sem=256 32000 100 142" >> /etc/sysctl.conf
echo "fs.file-max=6815744" >> /etc/sysctl.conf

# --- database specific start ----
sed -i -e "/kernel.msgmnb/d" /etc/sysctl.conf ; echo "kernel.msgmnb=65536" >> /etc/sysctl.conf
sed -i -e "/kernel.msgmax/d" /etc/sysctl.conf ; echo "kernel.msgmax=65536" >> /etc/sysctl.conf
sed -i -e "/kernel.shmall/d" /etc/sysctl.conf ; echo "kernel.shmall=16777216" >> /etc/sysctl.conf
echo "kernel.shmmni=4096" >> /etc/sysctl.conf
echo "fs.file-max=6815744" >> /etc/sysctl.conf
echo "fs.aio-max-nr=1048576" >> /etc/sysctl.conf
echo "net.ipv4.tcp_keepalive_time=1800" >> /etc/sysctl.conf
echo "net.ipv4.tcp_keepalive_intvl=30" >> /etc/sysctl.conf
echo "net.ipv4.tcp_keepalive_probes=5" >> /etc/sysctl.conf
echo "net.ipv4.tcp_fin_timeout=30" >> /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range=9000 65500" >> /etc/sysctl.conf
echo "net.core.rmem_default=262144" >> /etc/sysctl.conf
echo "net.core.rmem_max=4194304" >> /etc/sysctl.conf
echo "net.core.wmem_default=262144" >> /etc/sysctl.conf
echo "net.core.wmem_max=1048576" >> /etc/sysctl.conf
# --- database specific end ----

echo "# customizations oracle end" >> /etc/sysctl.conf

echo "NETWORKING_IPV6=no" >> /etc/sysconfig/network
echo "IPV6INIT=no" >> /etc/sysconfig/network

/sbin/sysctl -p

#   system packages
yum check-update
yum install -y epel-release
yum check-update
yum -y upgrade

#   64bit packages for all fusion apps
yum install -y \
    binutils \
    compat-libcap1 \
    compat-libstdc++-33 \
    gcc \
    gcc-c++ \
    glibc \
    libaio \
    libaio-devel \
    libgcc \
    libstdc++ \
    libstdc++-devel \
    libXext \
    libXtst \
    make \
    openmotif \
    openmotif22 \
    redhat-lsb-core \
    sysstat \
    xorg-x11-utils \
    xorg-x11-apps \
    xorg-x11-xinit \
    xorg-x11-server-Xorg \
    xterm

#   32bit packages for fusion apps
yum install -y \
    compat-libstdc++-33.i686 \
    glibc-devel.i686 \
    glibc.i686 \
    libstdc++-devel.i686 \
    libstdc++.i686 \
    libXext.i686 \
    libXtst.i686 \
    libXi.i686

#   only necessary for oracle database
yum install -y \
    elfutils-libelf-devel \
    glibc-devel \
    ksh \
    libaio-devel.i686 \
    libaio.i686

#   additional utilities
yum install -y \
    nfs-utils \
    unzip \
    rlwrap \
    tmux \
    telnet \
    nc \
    vim-enhanced

service iptables stop
service ip6tables stop

chkconfig iptables off
chkconfig ip6tables off

# --- users group dirs ---

groupadd -g 6100 fmwgroup
groupadd -g 6200 oinstall
groupadd -g 6201 dba

useradd -u 5200 -g 6200 -G vagrant,dba oracle
useradd -u 5100 -g 6100 -G vagrant,oinstall fmwuser
useradd -u 5101 -g 6100 oamadmin
useradd -u 5102 -g 6100 oimadmin
useradd -u 5103 -g 6100 webadmin
useradd -u 5104 -g 6100 dsadmin

echo "%fmwgroup  ALL=(ALL)  NOPASSWD: ALL" > /etc/sudoers.d/fmwgroup
chmod 440 /etc/sudoers.d/fmwgroup

echo "oracle  ALL=(ALL)  NOPASSWD: ALL" > /etc/sudoers.d/oracle
chmod 440 /etc/sudoers.d/oracle

cat >> /etc/security/limits.d/91-fusion.conf <<-EOF
@fmwgroup  soft    nofile     150000
@fmwgroup  hard    nofile     150000
@fmwgroup  soft    nproc       16384
@fmwgroup  hard    nproc       16384
oracle     soft    nofile      65536
oracle     hard    nofile      65536
oracle     soft    stack       10240
EOF

install  --owner=oracle  --group=oinstall --mode=0775 --directory /var/log/oracle           # logs (local)
install  --owner=oracle  --group=oinstall --mode=0775 --directory /opt/oracle               # products, config (shared, rw)
install  --owner=fmwuser --group=fmwgroup --mode=0775 --directory /var/log/fmw              # logs (local)
install  --owner=fmwuser --group=fmwgroup --mode=0775 --directory /l/ora            # products, config (shared, rw)
install  --owner=fmwuser --group=fmwgroup --mode=0775 --directory /l/ora/lcm        # life cycle manager
install  --owner=fmwuser --group=fmwgroup --mode=0775 --directory /l/ora/local      # local instance data
install  --owner=fmwuser --group=fmwgroup --mode=0775 --directory /mnt/oracle               # images (shared, ro)

# shared mount points must be munally added
# -----------------------------------------
echo "horst12:/Users/horst/Downloads/software/oracle /mnt/oracle  nfs  rw,bg,rsize=32768,wsize=32768  0 0" >> /etc/fstab
mount /mnt/oracle

echo "Red Hat Enterprise Linux Server release 6.7 (Santiago)" >>/etc/redhat-release

set +x
exit 0

