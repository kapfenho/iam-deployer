#  iam deploy and config functions

#  deloy life cycle management (deployment wizard)
#
deploy_lcm() {
  log "iam_deploy_lcm" "start"
  cd ${s_lcm}

  if ! [ -a ${lcm}/provisioning ]
  then
    ./Disk1/runInstaller -silent \
      -jreLoc ${s_runjre} \
      -invPtrLoc /etc/oraInst.loc \
      -response ${_DIR}/user-config/lcm/lcm_install.rsp \
      -ignoreSysPrereqs \
      -nocheckForUpdates \
      -waitforcompletion
  fi

  log "iam_deploy_lcm" "software installed, now patching..."

  dfile=${lcm}/provisioning/idm-provisioning-build/idm-common-preverify-build.xml

  if ! [ -a ${dfile}.orig ]
  then
    sed -i.orig 's/<antcall target=\"private-idm-preverify-os\"\/>/<!-- antcall target=\"private-idm-preverify-os\"\/ -->/' \
      ${dfile}
  fi

  log "iam_deploy_lcm" "done"
}

#  deploy step within life cycle manager wizard
#+ param 1: step name
#
deploy() {
  log "deploy" "executing step ${1}..."
  (
    cd ${lcm}/provisioning/bin
    ./runIAMDeployment.sh -responseFile ${_DIR}/user-config/iam/provisioning.rsp \
      -ignoreSysPrereqs true \
      -target ${1}
  )
  log "deploy" "finished step ${1}..."
}

patch_opss() {
  local _log=$(mktemp -d /tmp/psa_log_XXXXXX)
  log "patch_opss" "logs in ${_log}"
  log "patch_opss" "patching access  opss"

  ${idmtop}/products/access/iam/bin/psa \
    -response ${_DIR}/user-config/iam/psa_access.rsp \
    -logLevel WARNING \
    -logDir ${_log}

  log "patch_opss" "patching identity opss"

  ${idmtop}/products/identity/iam/bin/psa \
    -response ${_DIR}/user-config/iam/psa_identity.rsp \
    -logLevel WARNING \
    -logDir ${_log}

  log "patch_opss" "patching done"
}

patch_oud() {
  log "patch_oud" "starting"
  local c="${idmtop}/config/instances/oud1/OUD/bin/dsconfig set-access-control-handler-prop"

  p1='--remove global-aci:"(target=\"ldap:///cn=changelog\")(targetattr=\"*\")(version 3.0; acl \"External changelog access\"; deny  (all)  userdn=\"ldap:///anyone\";)"'
  p2='--add    global-aci:"(target=\"ldap:///cn=changelog\")(targetattr=\"*\")(version 3.0; acl \"External changelog access\"; allow (read,search,compare,add,write,delete,export) groupdn=\"ldap:///cn=OIMAdministrators,cn=groups,dc=agoracon,dc=at\";)"'
  p3='--add    global-aci:"(targetcontrol="1.3.6.1.4.1.26027.1.5.4")(version 3.0; acl \"OIMAdministrators control access\";    allow (read) userdn=\"ldap:///anyone\";)"' 

  echo "command 1:  ${p1}" ; ${c} ${p1}
  echo "command 2:  ${p2}" ; ${c} ${p2}
  echo "command 3:  ${p3}" ; ${c} ${p3}

  log "patch_oud" "done"
}
# old
# ds-cfg-global-aci: (targetcontrol="
# 1.3.6.1.1.12 || 
# 1.3.6.1.1.13.1 || 
# 1.3.6.1.1.13.2 || 
# 1.2.840.113556.1.4.319 || 
# 1.2.826.0.1.3344810.2.3 || 
# 2.16.840.1.113730.3.4.18 || 
# 2.16.840.1.113730.3.4.9 || 
# 1.2.840.113556.1.4.473 || 
# 1.3.6.1.4.1.42.2.27.9.5.9") (version 3.0; acl "Authenticated users control access"; allow(read) userdn="ldap:///all";)
# # new
# ds-cfg-global-aci: (targetcontrol="
# 2.16.840.1.113730.3.4.2 || 
# 2.16.840.1.113730.3.4.17 || 
# 2.16.840.1.113730.3.4.19 || 
# 1.3.6.1.4.1.4203.1.10.2 || 
# 1.3.6.1.4.1.42.2.27.8.5.1 || 
# 2.16.840.1.113730.3.4.16 || 
# 2.16.840.1.113894.1.8.31 || 
# 1.2.840.113556.1.4.319") (version 3.0; acl "Anonymous control access"; allow(read) userdn="ldap:///anyone";)

# patch_oud_config() {
#   log "patch_oud_conf" "starting"
#   sed -iorig -e '/1\.2\.840\.113556\.1\.4\.319/s/ldap:\/\/\/all/ldap:\/\/\/anyone/g' ${iam_app}/fmw/config/instances/oud1/OUD/config/config.ldif
#   log "patch_oud_conf" "done"
# }


