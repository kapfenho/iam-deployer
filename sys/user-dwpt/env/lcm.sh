#!/usr/bin/env bash

set -o errexit nounset
export deployer=/opt/install/dwpbank/iam-deployer
. ${deployer}/user-conf/env/env.sh
#  init done

mkdir -p ${idmtop}/lcm/lcmhome
mkdir -p ${idmtop}/etc

cat > ${idmtop}/etc/oraInst.loc <<-EOF 
inventory_loc=${idmtop}/etc/oraInventory
inst_group=fmwgroup
EOF

cd ${s_lcm}
./Disk1/runInstaller -silent \
  -jreLoc ${s_runjre} \
  -invPtrLoc ${idmtop}/etc/oraInst.loc \
  -response ${deployer}/user-conf/lcm/lcm_install.rsp \
  -ignoreSysPrereqs \
  -nocheckForUpdates \
  -waitforcompletion


sed -i.orig 's/<antcall target=\"private-idm-preverify-os\"\/>/<!-- antcall target=\"private-idm-preverify-os\"\/ -->/' \
  ${idmtop}/lcm/lcm/provisioning/idm-provisioning-build/idm-common-preverify-build.xml

