#  iam deploy and config functions

#  deloy life cycle management (deployment wizard)
#
deploy_lcm() {

  if ! [ -a ${lcm}/provisioning ] ; then
    log "Deploying LCM..."

    ${s_lcm}/Disk1/runInstaller -silent \
      -jreLoc ${s_runjre} \
      -invPtrLoc ${orainst_loc} \
      -response ${DEPLOYER}/user-config/lcm/lcm_install.rsp \
      -ignoreSysPrereqs \
      -nocheckForUpdates \
      -waitforcompletion

    log "LCM has been installed"
  else
    warning "Skipped: LCM installation, already here"
  fi

  local dfile=${lcm}/provisioning/idm-provisioning-build/idm-common-preverify-build.xml

  if ! [ -a ${dfile}.orig ] ; then
    log "Patching provisioning build plan"
    sed -i.orig 's/<antcall target=\"private-idm-preverify-os\"\/>/<!-- antcall target=\"private-idm-preverify-os\"\/ -->/' \
      ${dfile}
    log "Provisioning file patched"
  else
    warning "Skipped: patching of build file, already done"
  fi
}

#  deploy step within life cycle manager wizard
#+ param 1: step name
#
deploy() {
  log "Deployment: executing step ${1}..."
  (
    cd ${lcm}/provisioning/bin
    ./runIAMDeployment.sh -responseFile ${DEPLOYER}/user-config/iam/provisioning.rsp \
      -ignoreSysPrereqs true \
      -target ${1}
  )
  log "Deployment: step ${1} completed"
}

# post install task: patching of OPSS database instances
#
patch_opss() {
  local _log=$(mktemp -d /tmp/psa_log_XXXXXX)
  log "Post install 1: patching access  opss"
  log "logs in ${_log}"

  ${idmtop}/products/access/iam/bin/psa \
    -response ${DEPLOYER}/user-config/iam/psa_access.rsp \
    -logLevel WARNING \
    -logDir ${_log}

  log "Post install 2: patching identity opss"
  log "logs in ${_log}"

  ${idmtop}/products/identity/iam/bin/psa \
    -response ${_DIR}/user-config/iam/psa_identity.rsp \
    -logLevel WARNING \
    -logDir ${_log}

}

