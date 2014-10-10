#!/bin/sh
#  execute as root user
if [ $UID -ne 0 ] ; then echo "ERROR: not root" ; exit 77 ; fi
set -x

echo "# customizations oracle start" >> /etc/sysctl.conf
sed -i -e "/kernel.shmmax/d" /etc/sysctl.conf ; echo "kernel.shmmax=17179869184" >> /etc/sysctl.conf
echo "kernel.sem=256 32000 100 142" >> /etc/sysctl.conf

# --- database specific start ----
# sed -i -e "/kernel.msgmnb/d" /etc/sysctl.conf ; echo "kernel.msgmnb=65536" >> /etc/sysctl.conf
# sed -i -e "/kernel.msgmax/d" /etc/sysctl.conf ; echo "kernel.msgmax=65536" >> /etc/sysctl.conf
# sed -i -e "/kernel.shmall/d" /etc/sysctl.conf ; echo "kernel.shmall=16777216" >> /etc/sysctl.conf
# echo "kernel.shmmni=4096" >> /etc/sysctl.conf
# echo "fs.file-max=6815744" >> /etc/sysctl.conf
# echo "fs.aio-max-nr=1048576" >> /etc/sysctl.conf
# echo "net.ipv4.tcp_keepalive_time=1800" >> /etc/sysctl.conf
# echo "net.ipv4.tcp_keepalive_intvl=30" >> /etc/sysctl.conf
# echo "net.ipv4.tcp_keepalive_probes=5" >> /etc/sysctl.conf
# echo "net.ipv4.tcp_fin_timeout=30" >> /etc/sysctl.conf
# echo "net.ipv4.ip_local_port_range=9000 65500" >> /etc/sysctl.conf
# echo "net.core.rmem_default=262144" >> /etc/sysctl.conf
# echo "net.core.rmem_max=4194304" >> /etc/sysctl.conf
# echo "net.core.wmem_default=262144" >> /etc/sysctl.conf
# echo "net.core.wmem_max=1048576" >> /etc/sysctl.conf
# --- database specific end ----

echo "# customizations oracle end" >> /etc/sysctl.conf

/sbin/sysctl -p


yum check-update
yum -y upgrade
rpm -Uvh /vagrant/sys/redhat/epel-release-6-8.noarch.rpm
yum check-update

yum install -y binutils compat-libcap1 compat-libstdc++-33 gcc gcc-c++ glibc libaio libaio-devel libgcc libstdc++ libstdc++-devel libXext libXtst make openmotif openmotif22 redhat-lsb-core sysstat xorg-x11-utils xorg-x11-apps xorg-x11-xinit xorg-x11-server-Xorg xterm

yum install -y compat-libstdc++-33.i686 glibc-devel.i686 glibc.i686 libstdc++-devel.i686 libstdc++.i686 libXext.i686 libXtst.i686 libXi.i686

# yum install -y elfutils-libelf-devel glibc-devel ksh libaio-devel.i686 libaio.i686

yum install -y nfs-utils unzip rlwrap tmux vim-enhanced

chkconfig --del iptables
chkconfig --del ip6tables

# --- users group dirs ---

groupadd -g 6100 fmwgroup

useradd -u 5100 -g 6100 fmwuser
useradd -u 5101 -g 6100 oamadmin
useradd -u 5102 -g 6100 oimadmin
useradd -u 5103 -g 6100 webadmin
useradd -u 5104 -g 6100 dsadmin

echo "%fmwgroup  ALL=(ALL)  NOPASSWD: ALL" > /etc/sudoers.d/fmwgroup
chmod 440 /etc/sudoers.d/fmwgroup


install --owner=fmwuser --group=fmwgroup --mode=0770 --directory /app/releases/fmw      # vcs
install --owner=fmwuser --group=fmwgroup --mode=0770 --directory /opt/fmw               # configs
install --owner=fmwuser --group=fmwgroup --mode=0770 --directory /opt/fmw/products      # binaries
install --owner=fmwuser --group=fmwgroup --mode=0770 --directory /var/log/fmw           # logs


set +x
