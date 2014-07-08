#  iam deploy and config functions

#  deloy life cycle management (deployment wizard)
#
function deploy_lcm() {
  log "iam_deploy_lcm" "start"
  cd ${s_lcm}
  ./Disk1/runInstaller -silent \
    -jreLoc ${s_runjre} \
    -invPtrLoc /etc/oraInst.loc \
    -response ${_DIR}/user-config/lcm/lcm_install.rsp \
    -ignoreSysPrereqs \
    -nocheckForUpdates \
    -waitforcompletion

  log "iam_deploy_lcm" "software installed, now patching..."
  patch -b ${iam_mw_home}/lcm/provisioning/idm-provisioning-build/idm-common-preverify-build.xml \
    ${_DIR}/sys/redhat/centos6/idm-common-preverify-build.xml.patch

  log "iam_deploy_lcm" "done"
}

#  deploy step within life cycle manager wizard
#+ param 1: step name
#
function deploy() {
  log "deploy" "executing step ${1}..."
  (
    cd ${iam_app}/fmw/lcm/provisioning/bin
    ./runIAMDeployment.sh -responseFile ${_DIR}/user-config/iam/provisioning.rsp \
      -ignoreSysPrereqs true \
      -target ${1}
  )
  log "deploy" "finished step ${1}..."
}

