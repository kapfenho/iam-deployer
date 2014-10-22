#!/bin/sh

    ddir=/opt/fmw
   s_lcm=/mnt/oracle/iam-11.1.2.2/repo/installers/idmlcm
s_runjre=/mnt/oracle/iam-11.1.2.2/repo/installers/jdk/jdk7/jre

mkdir -p ${ddir}/lcm/lcmhome
mkdir -p ${ddir}/etc

cat > ${ddir}/etc/oraInst.loc <<-EOF 
inventory_loc=${ddir}/etc/oraInventory
inst_group=fmwgroup
EOF

cd ${s_lcm}
./Disk1/runInstaller -silent \
  -jreLoc ${s_runjre} \
  -invPtrLoc ${ddir}/etc/oraInst.loc \
  -response /vagrant/user-conf/lcm/lcm_install.rsp \
  -ignoreSysPrereqs \
  -nocheckForUpdates \
  -waitforcompletion


sed -i.orig 's/<antcall target=\"private-idm-preverify-os\"\/>/<!-- antcall target=\"private-idm-preverify-os\"\/ -->/' \
  /opt/fmw/lcm/lcm/provisioning/idm-provisioning-build/idm-common-preverify-build.xml

