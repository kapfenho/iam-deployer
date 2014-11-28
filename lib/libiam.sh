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
  local _p=$(mktemp /tmp/del.XXXXXX)
  echo "Montag11" > ${_p}
  local c="${idmtop}/config/instances/oud1/OUD/bin/dsconfig set-access-control-handler-prop"
        c="${c} --hostname $(hostname --long) --port 4444 --trustAll"
        c="${c} --bindDN cn=oudadmin --bindPasswordFile ${_p} --no-prompt"

  echo ${c} --remove global-aci:"(target=\"ldap:///cn=changelog\")(targetattr=\"*\")(version 3.0; acl \"External changelog access\"; deny (all) userdn=\"ldap:///anyone\";)"
  set +o errexit
  ${c} --remove global-aci:"(target=\"ldap:///cn=changelog\")(targetattr=\"*\")(version 3.0; acl \"External changelog access\"; deny (all) userdn=\"ldap:///anyone\";)"
  set -o errexit
  echo ${c} --add global-aci:"(target=\"ldap:///cn=changelog\")(targetattr=\"*\")(version 3.0; acl \"External changelog access\"; allow (read,search,compare,add,write,delete,export) groupdn=\"ldap:///cn=OIMAdministrators,cn=groups,dc=mycompany,dc=com\";)"
  ${c} --add global-aci:"(target=\"ldap:///cn=changelog\")(targetattr=\"*\")(version 3.0; acl \"External changelog access\"; allow (read,search,compare,add,write,delete,export) groupdn=\"ldap:///cn=OIMAdministrators,cn=groups,dc=mycompany,dc=com\";)"
  echo ${c} --add global-aci:"(targetcontrol="1.3.6.1.4.1.26027.1.5.4")(version 3.0; acl \"OIMAdministrators control access\"; allow(read)  groupdn=\"ldap:///cn=OIMAdministrators,cn=groups,dc=mycompany,dc=com\";)"
  ${c} --add global-aci:"(targetcontrol="1.3.6.1.4.1.26027.1.5.4")(version 3.0; acl \"OIMAdministrators control access\"; allow(read)  groupdn=\"ldap:///cn=OIMAdministrators,cn=groups,dc=mycompany,dc=com\";)"

  rm -f ${_p}
  log "patch_oud" "done"
}

patch_oud_config() {
  log "patch_oud_conf" "starting"
  sed -iorig -e '/1\.2\.840\.113556\.1\.4\.319/s/ldap:\/\/\/all/ldap:\/\/\/anyone/g' ${iam_app}/fmw/config/instances/oud1/OUD/config/config.ldif
  log "patch_oud_conf" "done"
}


