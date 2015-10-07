#  iam deploy and config functions

#  create oracle inventory pointer
#
create_orainvptr()
{
  if [[ ! -a ${iam_orainv_ptr} ]] ; then
    cat > ${iam_orainv_ptr} <<-EOS
      inventory_loc=${iam_orainv}
      inst_group=${iam_orainv_grp}
EOS
  fi
}


#  deloy life cycle management (deployment wizard)
#
deploy_lcm() {

  if ! [ -a ${iam_lcm}/provisioning ] ; then
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

  #  without this patch the weblogic installation will use require approx. 1300 MB free
  #  space available in /tmp. We want the environment variable TMPDIR tpo be used.
  #
  local patchfile=${iam_lcm}/provisioning/idm-provisioning-build/idm-common-build.xml

  if ! grep -qe 'java.io.tmpdir' ${patchfile} >/dev/null
  then
    patch -b ${patchfile} <<EOS
78a79
>                                                    <arg value="-Djava.io.tmpdir=${iam_top}" />
EOS
    log "LCM has been patched to use differen tempdir for Weblogic installation"
  else
    log "LCM patching skipped, already done"
  fi
}

#  deploy step within life cycle manager wizard
#+ param 1: step name
#
deploy() {
  (
    cd ${iam_lcm}/provisioning/bin
    ./runIAMDeployment.sh -responseFile ${DEPLOYER}/user-config/iam/provisioning.rsp \
      -ignoreSysPrereqs true \
      -target ${1}
  )
}

deploy_on_all() {
  
  log "Deployment step ${1} +++ starting on localhost..."
  deploy ${1}
  log "Deployment step ${1} +++ completed on localhost"

  for h in ${provhosts[@]}
  do
    log "Deployment step ${1} +++ starting on ${h}..."
    ssh ${h} -- ${DEPLOYER}/user-config/env/prov.sh ${1}
    log "Deployment step ${1} +++ completed on ${h}"
  done
  log "Deployment step ${1} completed"
}

# post install task: patching of OPSS database instances
#
patch_opss() {
  local _log=$(mktemp -d /tmp/psa_log_XXXXXX)
  log "Post install 1: patching access  opss"
  log "logs in ${_log}"

  ${iam_top}/products/access/iam/bin/psa \
    -response ${DEPLOYER}/user-config/iam/psa_access.rsp \
    -logLevel WARNING \
    -logDir ${_log}

  log "Post install 2: patching identity opss"
  log "logs in ${_log}"

  ${iam_top}/products/identity/iam/bin/psa \
    -response ${_DIR}/user-config/iam/psa_identity.rsp \
    -logLevel WARNING \
    -logDir ${_log}

}

