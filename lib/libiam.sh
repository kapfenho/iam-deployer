#  iam deploy and config functions

#  helper funcitons for product selection
#
do_idm() {
  local _ret
  case "${DO_IDM}" in
    YES|yes|1)
      _ret=0;;
    *)
      _ret=1;;
  esac
  return $_ret
}
do_acc() {
  local _ret
  case "${DO_ACC}" in
    YES|yes|1)
      _ret=0;;
    *)
      _ret=1;;
  esac
  return $_ret
}
do_bip() {
  local _ret
  case "${DO_BIP}" in
    YES|yes|1)
      _ret=0;;
    *)
      _ret=1;;
  esac
  return $_ret
}
do_web() {
  local _ret
  case "${DO_WEB}" in
    YES|yes|1)
      _ret=0;;
    *)
      _ret=1;;
  esac
  return $_ret
}
do_oud() {
  local _ret
  case "${DO_OUD}" in
    YES|yes|1)
      _ret=0;;
    *)
      _ret=1;;
  esac
  return $_ret
}

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
deploy_lcm()
{
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
deploy()
{
  (
    cd ${iam_lcm}/provisioning/bin
    ./runIAMDeployment.sh -responseFile ${DEPLOYER}/user-config/iam/provisioning.rsp \
      -ignoreSysPrereqs true \
      -target ${1}
  )
}

deploy_on_all()
{
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

# deployment and instance creation with lifecycle management
# in PS2 Release we also need to patch JDK with custom random pool
#
iam_prov ()
{
  for step in preverify install
  do
    deploy_on_all $step
  done

  # use urandom
  do_idm && jdk_patch_config ${iam_top}/products/identity/jdk6
  do_acc && jdk_patch_config ${iam_top}/products/access/jdk6
  do_oud && jdk_patch_config ${iam_top}/products/dir/jdk6
  do_web && jdk_patch_config ${iam_top}/products/web/jdk6
  #for p in access dir identity web
  #do
  #    do_${p} && jdk_patch_config ${iam_top}/products/${p}/jdk6
  #done

  for step in preconfigure configure configure-secondary postconfigure startup validate
  do
    deploy_on_all $step
  done
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

# create domain keyfiles
#
create_domain_keyfiles()
{
  _domain=${1}

  # check java version
  _p=$(pgrep -f ${_domain}/servers/AdminServer)
  ${_p} -version 2>&1|grep -q "1.6"
  
  if [ "$?" == "0" ];
  then
    _java_home=${iam_top}/products/${_domain}/jdk/jdk6
    _wlst="JAVA_HOME=${_java_home} ${WL_HOME}/common/bin/wlst.sh"
  else
    _wlst=${WL_HOME}/common/bin/wlst.sh
  fi

  if [ "${_domain}" == "access" ];
  then
    log "Access Domain: creating keyfiles for domain..."

    if ! [ -a ${iam_hostenv}/.creds/${iam_domain_acc}.key ] ; then
      ${_wlst} -loadProperties ${iam_hostenv}/env/access.prop <<-EOF
connect(username="${domaUser}", password="${domaPwd}", url=domUrl)
storeUserConfig(userConfigFile=domUC,userKeyFile=domUK,nm="false")
y
exit()
EOF
    fi
  elif [ "${_domain}" == "identity" ];
  then
    log "Identity Domain: creating keyfiles for domain..."

    if ! [ -a ${iam_hostenv}/.creds/${iam_domain_oim}.key ] ; then
      ${_wlst} -loadProperties ${iam_hostenv}/env/identity.prop <<-EOF
      connect(username="${domiUser}", password="${domiPwd}", url=domUrl)
      storeUserConfig(userConfigFile=domUC,userKeyFile=domUK,nm="false")
      y
      exit()
      EOF
    fi
  fi
}
# create nodemanager keyfiles
#
create_nm_keyfiles()
{
  _domain=${1}
  # check java version
  _p=$(pgrep -f ${_domain}/servers/AdminServer)
  ${_p} -version 2>&1|grep -q "1.6"
  
  if [ "$?" == "0" ];
  then
    _java_home=${iam_top}/products/${_domain}/jdk/jdk6
    _wlst="JAVA_HOME=${_java_home} ${WL_HOME}/common/bin/wlst.sh"
  else
    _wlst=${WL_HOME}/common/bin/wlst.sh
  fi

  log "Identity Domain: creating nodemanager keyfiles..."

  if ! [ -a ${iam_hostenv}/.creds/nm.key ] ; then
    ${_wlst} -loadProperties ${iam_hostenv}/env/identity.prop <<-EOF
    nmConnect(username='${nmUser}', password='${nmPwd}',host=hostname,
    port=nmPort, domainName=domName, domainDir=domDir, nmType='ssl')
    storeUserConfig(userConfigFile=nmUC,userKeyFile=nmUK,nm='true')
    y
    exit()
    EOF
    log "Access Domain: creating nodemanager keyfiles..."
  fi

  if ! [ -a ${iam_hostenv}/.creds/nm.key ] ; then
    ${_wlst} -loadProperties ${iam_hostenv}/env/access.prop <<-EOF
    nmConnect(username='${nmUser}', password='${nmPwd}',host=hostname,
    port=nmPort, domainName=domName, domainDir=domDir, nmType='ssl')
    storeUserConfig(userConfigFile=nmUC,userKeyFile=nmUK,nm='true')
    y
    exit()
    EOF
  fi
}

remote_create_nm_keyfiles()
{
  _host=${1}
  _domain=${2}
  if [ "${_domain}" == identity ];
  then
    _cmd="idm; "
  else
    _cmd="acc; "
  fi
  _cmd+="source ${DEPLOYER}/lib/libiam.sh; "
  _cmd+="create_nm_keyfiles ${_domain}"
  
  ssh ${_host} -- ${_cmd} 
}

#  remove installation directories populated by LCM
#  if $iam_remove_lcm is set to "yes" also remove all LCM dirs
#  Always returms 0
#
remove_files()
{
    echo "/bin/rm -Rf ${iam_top}/products/* \
        ${iam_top}/config/* \
        ${iam_services}/* \
        ${iam_top}/*.lck \
        ${iam_top}/lcm/lcmhome/provisioning/phaseguards/* \
        ${iam_top}/lcm/lcmhome/provisioning/provlocks/* \
        ${iam_top}/lcm/lcmhome/provisioning/logs/"

    if [ "${iam_remove_lcm}" == "yes" ] ; then
        echo "rm -Rf ${iam_top}/lcm/* \
            ${iam_top}/etc/*"
    fi
}


