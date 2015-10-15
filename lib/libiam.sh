#  iam deploy and config functions

wlst_nm_keys="nmConnect(username='${nmUser}', password='${nmPwd}',host=hostname,
port=nmPort, domainName=domName, domainDir=domDir, nmType='ssl')
storeUserConfig(userConfigFile=nmUC,userKeyFile=nmUK,nm='true')
y
exit()
"
wlst_acc_keys="connect(username='${domaUser}', password='${domaPwd}', url=domUrl)
storeUserConfig(userConfigFile=domUC,userKeyFile=domUK,nm='false')
y
exit()
"
wlst_idm_nm_keys="nmConnect(username='${nmUser}', password='${nmPwd}',host=hostname,
port=nmPort, domainName=domName, domainDir=domDir, nmType='ssl')
storeUserConfig(userConfigFile=nmUC,userKeyFile=nmUK,nm='true')
y
exit()
"
wlst_idm_keys="connect(username='${domiUser}', password='${domiPwd}',url=domUrl)
storeUserConfig(userConfigFile=domUC,userKeyFile=domUK,nm='false')
y
exit()
"


#  create ssh-keypair for host access
#  - param 1: path of shared directory for common key
#
gen_ssh_keypair()
{
  local _dest=${1}/id_rsa
  if [[ -a ${_dest} ]] ; then
    return WARN_DONE
  else
    ssh-keygen -t rsa -b 4096 -C "iam-deployer insecure key" \
      -N "" -f ${_dest}
  fi
}

#  copy the keypair to the standard locations and trust the same key
#  because all hosts will use the very same one during initialization
#  - param 1: path of shared directory with common key
#
deploy_ssh_keypair()
{
  newk=${1}/id_rsa
  destk=~/.ssh/id_rsa
  authk=~/.ssh/authorized_keys

  # check if there is already a key present
  if [[ -a ${destk} ]] ; then
    if [[ "$(cat ${destk} | shasum)" == "$(cat ${newk} | shasum)" ]] ; then
      # the common key is already there
      return $WARN_DONE
    else
      # an unkown key is there - stop and complain!
      return $ERR_FILE_EXISTS
    fi
  fi

  # standard setting in ssh...
  mkdir -p ~/.ssh && chmod 0700 ~/.ssh
  cp ${newk}     ${destk}
  cp ${newk}.pub ${destk}.pub

  [[ -a ${authk} ]] && cp -p ${authk} ${authk}-$(date +"%Y%m%d-%H%M%S")
  cat ${destk}.pub >> ${authk}
  chmod 0600 ${destk}
  chmod 0644 ${destk}.pub ${authk}
}


# quietly add list of hosts (passed as parameters) to ${HOME}/.ssh/known_hosts 
# file after this function is run, a list of known hosts will be prepared for 
# the current user@localhost.
#
# WARNING: this function is potentialy dangerous, because it adds a list of 
# known hosts without any checks from the administrator.
# 
add_known_hosts()
{
  for host in ${@};
  do
    echo "adding ${host} to ${HOME}/.ssh/known_hosts file."
    ssh-keyscan -t rsa ${host} >> ${HOME}/.ssh/known_hosts
    #ssh fmwuser@${host} -o "StrictHostKeyChecking no"
  done
}

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
  _wlst=""

  # check java version
  local _p=$(pgrep -fl AdminServer)
  if [[ ${_p} == *"jdk6"* ]];
  then
    echo JAVA
    _java_home=${iam_top}/products/${_domain}/jdk/jdk6
    _wlst+="JAVA_HOME=${_java_home}"
  fi

  # create identity domain key files
  if [ "${_domain}" == "identity" ];
  then
    log "Identity Domain: creating keyfiles for domain..."

    source ~/.env/idm.env
    _wlst+=" ${WL_HOME}/common/bin/wlst.sh"

    if ! [ -a ${iam_hostenv}/.creds/${iam_domain_oim}.key ] ; then
      echo "${wlst_idm_keys}" | \
      ${_wlst} -loadProperties ${iam_hostenv}/env/identity.prop
    fi
  fi

  # create access domain key files
  if [ "${_domain}" == "access" ];
  then
    log "Access Domain: creating keyfiles for domain..."

    source ~/.env/acc.env
    _wlst+=${WL_HOME}/common/bin/wlst.sh

    if ! [ -a ${iam_hostenv}/.creds/${iam_domain_acc}.key ] ; then
      echo "${wlst_acc_keys}" | \
        ${_wlst} -loadProperties ${iam_hostenv}/env/access.prop 
    fi
  fi
}
# create nodemanager keyfiles
#
create_nm_keyfiles()
{
  local _target=${1}
  local _wlst=""

  case ${_target} in
    identity)
      source ~/.env/idm.env
      ;;
    access)
      source ~/.env/acc.env
      ;;
    *)
      return ERR_FILE_NOT_FOUND
      ;;
  esac

  # check java version
  # dirname $(dirname $(readlink /proc/$(pgrep -f AdminServer)/exe))
  local _p="/proc/$(pgrep -f AdminServer)/exe"
  local _jh=$(dirname $(dirname $(readlink ${_p})))
  
  _jv=$(${_p} -version 2>&1)
  if [[ ${_jv} =~ "1\.6" ]];
  then
    export JAVA_HOME=${_jh}
    export PATH=${JAVA_HOME}/bin:${PATH}
  fi

  if ! [ -a ${iam_hostenv}/.creds/nm.key ] ; then
    echo "${wlst_idm_nm_keys}" | \
    ${WL_HOME}/common/bin/wlst.sh -loadProperties \
    ${iam_hostenv}/env/${_target}.prop
  fi
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


# run Oracle patch set assistant
# input: product name
# 
run_psa()
{
  local _product=${1}
  log "running PSA (Patch Set Assistant) for ${_product}..."

  ${ORACLE_HOME}/bin/psa \
    -response ${DEPLOYER}/user-config/iam/psa_${_product}.rsp \
    -logLevel WARNING \
    -logDir /tmp
}

# post installation configurations for IAM products
# input: domain name
# 
postinst()
{
  local _target=${1}

  case ${_target} in
    identity)
      log ""
      log "Identity Domain: configuring domain..."

      source ~/.env/idm.env
      ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOSTENV}/env/identity.prop \
        ${DEPLOYER}/lib/identity/idm-config.py
      log "Identity Domain: configuration steps done."
      ;;
    access)
      log ""
      log "Access Domain: configuring access domain..."

      source ~/.env/acc.env
      ${WL_HOME}/common/bin/wlst.sh -loadProperties ${HOSTENV}/env/access.prop \
        ${DEPLOYER}/lib/access/oam-config.py

      log "Access Domain: configuration steps done"
      ;;
    webtier)
      log "Webgate: fix installation bug"

      source ~/.env/web.env
      _webg=${iam_top}/products/web/webgate/webgate/ohs/config

      if [ -a ${_webg}/oblog_config_wg.xml -a ! -a ${_webg}/oblog_config.xml ] ; then
        cp ${_webg}/oblog_config_wg.xml ${_webg}/oblog_config.xml
      fi
      log "Webgate: done"
      ;;
  esac


}
