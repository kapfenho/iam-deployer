#  iam deploy and config functions ---------------------------------
#  source it

#  load user env file {common,idm,acc} - if not there 
#  exit with error
#
load_userenv()
{
  local _f=~/.env/${1}.env
  if [[ -a ${_f} ]] ; then
    source ${_f}
    if ! [ -d ${JAVA_HOME} ] ; then
      # in case jdk is not moved yet
      export JAVA_HOME=${MW_HOME}/jdk6
      export PATH=${JAVA_HOME}/bin:${PATH}
    fi
  else
    error "User env file ${_f} not existing. Please run task userenv before!"
    exit $ERROR_FILE_NOT_FOUND
  fi
}

#  create ssh-keypair for host access
#  - param 1: path of shared directory for common key
#
gen_ssh_keypair()
{
  local _dest=${1}/id_rsa
  if [[ -a ${_dest} ]] ; then
    return 0
  else
    ssh-keygen -t rsa -b 4096 -C "iam-deployer insecure key" \
      -N "" -f ${_dest}
  fi
}

# quietly add list of hosts (passed as parameters) to ${HOME}/.ssh/known_hosts 
# file after this function is run, a list of known hosts will be prepared for 
# the current user@localhost.
# 
add_known_hosts()
{
  for host in ${provhosts[@]} ; do
    log "adding ${host} to known_hosts"
    ssh-keyscan -t rsa ${host} >> ${HOME}/.ssh/known_hosts
  done
}

#  copy the keypair to the standard locations and trust the same key
#  because all hosts will use the very same one during initialization
#  - param 1: path of shared directory with common key
#
deploy_ssh_keypair()
{
  local newk=${1}/id_rsa
  local destk=~/.ssh/id_rsa
  local authk=~/.ssh/authorized_keys
  local known=~/.ssh/known_hosts

  # check if there is already a key present
  # if [[ -a ${destk} ]] ; then
  #   if [[ "$(cat ${destk} | sha256sum)" == "$(cat ${newk} | sha256sum)" ]] ; then
  #     # the common key is already there
  #     return $WARN_DONE
  #   else
  #     # an unkown key is there - stop and complain!
  #     return $ERR_FILE_EXISTS
  #   fi
  # fi

  # standard setting in ssh...
  mkdir -p ~/.ssh && chmod 0700 ~/.ssh
  cp ${newk}     ${destk}
  cp ${newk}.pub ${destk}.pub

  # include localhost in known_hosts and authorized_keys
  [[ -a ${authk} ]] && cp -p ${authk} ${authk}-$(date +"%Y%m%d-%H%M%S")
  [[ -a ${known} ]] && cp -p ${known} ${known}-$(date +"%Y%m%d-%H%M%S")
  echo "localhost $(cat /etc/ssh/ssh_host_rsa_key.pub)" >> ${known}
  cat ${destk}.pub >> ${authk}
  chmod 0600 ${known} ${destk}
  chmod 0644 ${authk} ${destk}.pub

  add_known_hosts
}


#  helper funcitons for product selection
#  vendor products: identity, access, web, directory
#  user products:   bip
#  in case products directory not found exit run
#
exists_product()
{
  local _prod=${1}

  [[ -a ${iam_top}/products          ]] || \
    exit   $ERROR_FILE_NOT_FOUND

  [[ -a ${iam_top}/products/${_prod} ]] || \
    return $ERROR_FILE_NOT_FOUND

  return 0
}

#  create oracle inventory pointer
#
create_orainvptr()
{
  if ! [ -a ${iam_orainv_ptr} ] ; then
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

    [[ -n "${LD_LIBRARY_PATH}" ]] && LD_LIBRARY_PATH_OLD=${LD_LIBRARY_PATH}
    ORACLE_HOME=
    LD_LIBRARY_PATH=

      
    log "Deploying LCM..."

    ${s_lcm}/Disk1/runInstaller -silent \
      -jreLoc ${s_runjre} \
      -invPtrLoc ${iam_orainv_ptr} \
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

#  provision step within life cycle manager wizard
#+ param 1: step name
#
lcmstep()
{
  local _action=${1}

  if [ "${_action}" == "unblock" ] ; then

    for d in ${iam_top}/products/* ; do
      [[ -a ${d}/jdk6 ]] && jdk_patch_config ${d}/jdk6
    done

  else
    if [ -f ${iam_lcmhome}/provisioning/logs/$(hostname -f)/runIAMDeployment-${_action}.log ] ; then
      log "Provisioning step ${_action} already done"
      return
    fi
    local _rsp=${DEPLOYER}/user-config/iam/provisioning.rsp

    export JAVA_HOME=${s_runjdk}
    export PATH=${JAVA_HOME}/bin:${PATH}

    ${iam_lcm}/provisioning/bin/runIAMDeployment.sh -responseFile ${_rsp} \
      -ignoreSysPrereqs true \
      -target ${_action}
  fi
}

# prov_on_all()
# {
#   # log "Deployment step ${1} +++ starting on localhost..."
#   # deploy ${1}
#   # log "Deployment step ${1} +++ completed on localhost"
# 
#   for h in ${provhosts[@]}
#   do
#     log "Deployment step ${1} +++ starting on ${h}..."
#     ssh ${h} -- ${DEPLOYER}/user-config/env/prov.sh ${1}
#     log "Deployment step ${1} +++ completed on ${h}"
#   done
#   log "Deployment step ${1} completed"
# }

# deployment and instance creation with lifecycle management
# in PS2 Release we also need to patch JDK with custom random pool
#
# iam_prov ()
# {
#   for step in preverify install
#   do
#     deploy_on_all $step
#   done
# 
#   # use urandom
#   do_idm && jdk_patch_config ${iam_top}/products/identity/jdk6
#   do_acc && jdk_patch_config ${iam_top}/products/access/jdk6
#   do_oud && jdk_patch_config ${iam_top}/products/dir/jdk6
#   do_web && jdk_patch_config ${iam_top}/products/web/jdk6
# 
#   for step in preconfigure configure configure-secondary postconfigure startup validate
#   do
#     deploy_on_all $step
#   done
# }

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

#  check what jdk the process with id uses, if it uses jdk6
#  change our environment to use the same one
#    param1: pid
#
use_jdk_of_proc() {
  local _pid=${1}
  local _prog="/proc/${_pid}/exe"
  local _jhome=$(dirname $(dirname $(readlink ${_prog})))

  # version output goes to stderr
  if ${_prog} -version 2>&1 | grep -q -e '1\.6' ; then
    # running process uses jdk6, we need to use the same one
    export JAVA_HOME=${_jhome}
    export PATH=${JAVA_HOME}/bin:${PATH}
  fi
}


#  create domain keyfiles for user ----------------------------------
#  parameters are used from opt_ variables:
#    $opt_u: username
#    $opt_p: password
#    $opt_w: domain properties file
# 
create_domain_keyfile()
{
  local  _domUC=$(grep   "domUC=" ${opt_w} | cut -d= -f2)
  local _domain=$(grep "domName=" ${opt_w} | cut -d= -f2)

  # check if userfile already exists
  if [ -a ${_domUC} ] ; then
    log "Domain keyfile creation skipped"
  else
    # set the jdk env of running process
    # TODO: check if found
    use_jdk_of_proc $(pgrep -f "Dweblogic\.Name=AdminServer.*${_domain}")

    log "Creating Domain keyfiles for domain ${_domain}..."

    local _wlst="connect(username='${opt_u}',password='${opt_p}',url=domUrl)
storeUserConfig(userConfigFile=domUC,userKeyFile=domUK,nm='false')
y
exit()
"

    echo "${_wlst}" | ${WL_HOME}/common/bin/wlst.sh -loadProperties ${opt_w}
    [[ $? -eq 0 ]] || exit $ERROR_WLST

    log "Finished creating domain keyfiles"

  fi
}

#  create nodemanager keyfiles for user -----------------------------
#  parameters are used from opt_ variables:
#    $opt_u: username
#    $opt_p: password
#    $opt_w: domain properties file
#
create_nodemanager_keyfile()
{
  local _nmUC=$(grep  "nmUC=" ${opt_w} | cut -d= -f2)

  # check if file already exists
  if [ -a ${_nmUC} ] ; then
    log "Nodemanager keyfile creation skipped"
  else
    # set the jdk env of running process
    # TODO: check if found
    use_jdk_of_proc $(pgrep -f "DListenPort=5556")

    log "Creating nodemanager keyfiles..."

    local _wlst="nmConnect(username='${opt_u}',password='${opt_p}',host=acGetFQDN(),port=nmPort,domainName=domName,domainDir=domDir,nmType='ssl')
storeUserConfig(userConfigFile=nmUC,userKeyFile=nmUK,nm='true')
y
exit()
"
    echo "${_wlst}" | ${WL_HOME}/common/bin/wlst.sh -loadProperties ${opt_w}
    [[ $? -eq 0 ]] || exit $ERROR_WLST

    log "Finished creating domain keyfiles"

  fi
}

#  remove installation directories populated by LCM
#  if $iam_remove_lcm is set to "yes" also remove all LCM dirs
#  Always returns 0
#
remove_iam()
{
  opt_incl_lcm=${1}

  rm -Rf ${iam_top}/products/* \
    ${iam_top}/config/* \
    ${iam_services}/* \
    ${iam_top}/*.lck \
    ${iam_top}/lcm/lcmhome/provisioning/phaseguards/* \
    ${iam_top}/lcm/lcmhome/provisioning/provlocks/* \
    ${iam_top}/lcm/lcmhome/provisioning/logs/

  if [ -n "${opt_incl_lcm}" ] ; then
    rm -Rf ${iam_top}/lcm/*
  fi
}

#  remove hostenvironment: ~/{bin,lib,.env,.creds}
#  Always returns 0
#
remove_env()
{
  #  bin
  for f in $(ls ${DEPLOYER}/lib/templates/hostenv/bin/) ; do
    rm -f ~/bin/${f}
  done
  rmdir ~/bin 2>/dev/null || true
  #  lib
  for f in $(ls ${DEPLOYER}/lib/templates/hostenv/lib/) ; do
    rm -f ~/lib/${f}
  done
  rmdir ~/lib 2>/dev/null || true
  #  env
  for f in $(ls ${DEPLOYER}/lib/templates/hostenv/env/) ; do
    rm -f ~/.env/${f}
  done
  rmdir ~/.env 2>/dev/null || true
  #  cred
  rm -Rf ~/.cred 
}


#  run Oracle patch set assistant
#  param1: product name
# 
run_psa()
{
  local _product=${1}
  log "running PSA (Patch Set Assistant) for ${_product}..."

  echo "PSA:"
  echo "${ORACLE_HOME}"
  ${ORACLE_HOME}/bin/psa \
    -response ${DEPLOYER}/user-config/iam/psa_${_product}.rsp \
    -logLevel WARNING \
    -logDir /tmp
}

#  apply custom config to domain ------------------------------------
#
config_identity()
{
  log ""
  log "Identity Domain: configuring domain..."

  ${WL_HOME}/common/bin/wlst.sh -loadProperties ~/.env/identity.prop \
    ${DEPLOYER}/lib/identity/idm-config.py

  log "Identity Domain: configuration steps done."
}

#  apply custom config to domain ------------------------------------
#
config_access()
{
  log ""
  log "Access Domain: configuring access domain..."

  ${WL_HOME}/common/bin/wlst.sh -loadProperties ~/.env/access.prop \
    ${DEPLOYER}/lib/access/oam-config.py

  log "Access Domain: configuration steps done"
}

#  fix bug shipped with release
# 
config_webtier()
{
  log "Webgate: fix installation bug"

  _webg=${iam_top}/products/web/webgate/webgate/ohs/config

  if [ -a ${_webg}/oblog_config_wg.xml -a ! -a ${_webg}/oblog_config.xml ] ; then
    cp ${_webg}/oblog_config_wg.xml ${_webg}/oblog_config.xml
  fi
  log "Webgate: done"
}


oia_dom_prop()
{
  local _propfile_template=${DEPLOYER}/user-config/oia/createdom-${1}-template.prop
  local _propfile=${iam_top}/etc/createdom-${1}.prop
  #propfile=$(mktemp /tmp/oia-domain-prop-XXXXXXX)
  cp ${_propfile_template} ${_propfile}
  
  _iam_top=$(echo ${iam_top} | sed -e 's/[\/&]/\\&/g')
  
  sed -i "s/__DOMAIN_NAME__/${iam_domain_oia}/"         ${_propfile}
  sed -i "s/__IAM_TOP__/${_iam_top}/"                    ${_propfile}
  sed -i "s/__IAM_OIA_HOST1__/${iam_oia_host1}/"        ${_propfile}
  sed -i "s/__IAM_OIA_HOST2__/${iam_oia_host2}/"        ${_propfile}
  sed -i "s/__IAM_OIA_DBUSER__/${iam_oia_dbuser}/"      ${_propfile}
  sed -i "s/__IAM_OIA_DBPWD__/${iam_oia_schema_pass}/"  ${_propfile}
  sed -i "s/__DBS_HOSTNAME__/${dbs_dbhost}/"            ${_propfile}
  sed -i "s/__IAM_SERVICENAME__/${iam_servicename}/"    ${_propfile}
}
# create weblogic domain for OIA including:
# nodemanager, boot properties, datasources, managed server
# 
oia_wlst_exec()
{
  # create domain or deploy OIA application
  local _operation=${1}

  case ${_operation} in
    wlstdom)
      local _start_wlst=${DEPLOYER}/lib/weblogic/wlst/create_oia_domain.py
      ;;
    oia)
      local _start_wlst=${DEPLOYER}/lib/weblogic/wlst/deploy_oia_app.py
      ;;
    *)
      exit $ERROR_FILE_NOT_FOUND
      ;;
  esac

  local _wls_dom_template=${WL_HOME}/common/templates/domains/wls.jar
  local _user_prop=${iam_top}/etc/createdom-${2}.prop

  JAVA_OPTIONS="${JAVA_OPTIONS} -Xmx2048m -Xms2048m -Djava.net.preferIPv4Stack=true"
  JVM_ARGS="-Dprod.props.file='${WL_HOME}'/.product.properties \
    -Dweblogic.management.confirmKeyfileCreation=true \
     ${CONFIG_JVM_ARGS}"
  source ${WL_HOME}/server/bin/setWLSEnv.sh
  set -x
  eval '"${JAVA_HOME}/bin/java"' ${JVM_ARGS} weblogic.WLST \
    -skipWLSModuleScanning ${_start_wlst} \
                           ${_wls_dom_template} \
                           ${oiaWlUser} \
                           ${oiaWlPwd} \
                           ${_user_prop}
  set +x
}

oia_rdeploy()
{
  _action=${1}

  pack=$WL_HOME/common/bin/pack.sh
  unpack=$WL_HOME/common/bin/unpack.sh
  template_loc=/l/ora/products
  template_name=oia_iamv2_template

  case ${_action} in
    pack)
      ${pack} -managed=true \
        -domain=${DOMAIN_HOME} \
        -template=${template_loc}/${template_name}.jar \
        -template_name=${template_name}
      ;;
    unpack)
      ${unpack} -domain=${DOMAIN_HOME} \
                -app_dir=${DOMAIN_HOME} \
                -template=${template_loc}/${template_name}.jar \
      ;;
    *)
      exit $ERROR_FILE_NOT_FOUND
      ;;
  esac

  # ./pack.sh -managed=true 
  #           -domain=/l/ora/services/domains/oia_iamv2
  #           -template=/tmp/oia_iamv2_template.jar 
  #           -template_name="oia_iamv2_template"

}
# unpack OIA instance
#
oia_explode()
{
  # conflicting libs
  c_libs[0]=jrf-api.jar
  c_libs[1]=stax-1.2.0.jar
  c_libs[2]=stax-api-1.0.1.jar
  c_libs[3]=tools.jar
  c_libs[4]=ucp.jar
  c_libs[5]=xfire-all-1.2.5.jar


  if [ -a "${MW_HOME}" ]
  then
    unzip -q ${s_oia}/app-archive/${oia_name} -d ${RBACX_HOME}

    mv ${RBACX_HOME}/sample/* ${RBACX_HOME}
    rm -rf ${RBACX_HOME}/sample

    mkdir ${RBACX_HOME}/{_rbacx_orig,rbacx}
    cp ${RBACX_HOME}/rbacx.war ${RBACX_HOME}/_rbacx_orig
    cd ${RBACX_HOME}/rbacx ; jar -xf ../rbacx.war ; rm ../rbacx.war

    # copy libraries needed by OIA
    cp ${s_oia}/ext/*.jar ${RBACX_HOME}/rbacx/WEB-INF/lib/

    # Remove conflicting libs
    #
    for lib in ${c_libs[@]}; do
      rm ${RBACX_HOME}/rbacx/WEB-INF/lib/${lib}
    done
    echo "Done unpacking OIA."
    echo ""
  else
    log "Analytics: ${MW_HOME} does not exist. Please install WLS first."
  fi
}

# Apply rbacx configurations by patching the OOTB rbacx instance
# with the changes from a preconfigured rbacx instance
# 
# deployment type:
# 0 - single instance
# 1 - clustered
#
oia_appconfig()
{
  deployment_type=${1}

  cd ${RBACX_HOME}
  if [ "${deployment_type}" == "single" ]
  then
    echo "Patching RBACX_HOME for single instance deployment.."
    patch -p1 --silent < ${DEPLOYER}/user-config/oia/rbacx_single.patch
  elif [ "${deployment_type}" == "cluster" ]
  then
    echo "Patching RBACX_HOME for cluster deployment.."
    patch -p1 --silent < ${DEPLOYER}/user-config/oia/rbacx_cluster.patch
  fi
  echo "Done patching RBACX_HOME."
  echo ""

  # Encrypt OIMJDBC Password
  java -jar ${RBACX_HOME}/rbacx/WEB-INF/lib/vaau-commons-crypt.jar \
    -encryptProperty \
    -cipherKeyProperties ${RBACX_HOME}/conf/cipherKey.properties \
    -propertyFile ${RBACX_HOME}/conf/oimjdbc.properties \
    -propertyName oim.jdbc.password
  echo "Encrypted OIM JDBC Password"


}
# OIM-OIA integration steps
#
oia_oim_integrate()
{
  # oim server libs
  oim_lib[0]=xlCrypto.jar
  oim_lib[1]=wlXLSecurityProviders.jar
  oim_lib[2]=xlAuthentication.jar
  oim_lib[3]=xlLogger.jar

  # design console libs
  dc_lib[0]=xlAPI.jar
  dc_lib[1]=xlCache.jar
  dc_lib[2]=xlDataObjectBeans.jar
  dc_lib[3]=xlDataObjects.jar
  dc_lib[4]=xlUtils.jar
  dc_lib[5]=xlVO.jar
  dc_lib[6]=oimclient.jar
  dc_lib[7]=iam-platform-utils.jar

  local _oia_lib=${RBACX_HOME}/rbacx/WEB-INF/lib

  # copy OIM designconsole and server libraries to OIA
  for lib in ${oim_lib[@]}; do
    cp ${OIM_MW_HOME}/iam/server/lib/${lib} ${_oia_lib}
  done

  for lib in ${dc_lib[@]}; do
    cp ${OIM_MW_HOME}/iam/designconsole/lib/${lib} ${_oia_lib}
  done

  cp ${OIM_MW_HOME}/oracle_common/modules/oracle.jrf_11.1.1/jrf-api.jar ${_oia_lib}

  cp ${OIM_WL_HOME}/server/lib/wlfullclient.jar ${_oia_lib}

  # copy designconsole config to OIA
  mkdir -p ${RBACX_HOME}/xellerate
  cp -R ${OIM_MW_HOME}/iam/designconsole/config ${RBACX_HOME}/xellerate

  # patching workflow configurations
  cd ${RBACX_HOME}
  patch -p0 --silent < ${DEPLOYER}/user-config/oia/rbacx_workflow.patch
}

# configure OIA weblogic domain
# 
oia_domconfig()
{
  # setDomainEnv.sh patch
  cd ${DOMAIN_HOME}/bin
  patch -p0 < ${DEPLOYER}/user-config/oia/oia_setdomenv.patch
}

# install weblogic server
#
weblogic_install()
{
  local _product_home=${1}

  if ! [ -a "${iam_top}/products/${_product_home}/wlserver_10.3" ] ; then
    echo "Installing Weblogic Server..."
    java -d64 -jar ${s_wls} \
      -mode=silent \
      -silent_xml=${DEPLOYER}/user-config/wls/wls_install.xml
  else
    echo "Skipped: Weblogic server installation"
  fi
}

#  deploy standard lib acStdLib for wlst ----------------------------
#  param1: product namem (identity,access)
#
wlst_copy_libs ()
{
  local _target=${1}
  local _dest=${iam_top}/products/${_target}/wlserver_10.3/common/wlst

  if [[ -d ${_dest} ]] ; then
    cp -f ${DEPLOYER}/lib/weblogic/wlst/common/* ${_dest}/
    log "WLST standard lib copied to ${_target} WebLogic"
  else
    error "Could not find directory ${_dest}"
    exit $ERROR_FILE_NOT_FOUND
  fi
}

# the patches correct bugs of the default configuration:  -----------
#   * several concurrent jvm memory options are stated
#   * jvm runs in client mode (dev and prod mode)
#   * jvm options are not jdk7 compatible
#
patch_wls_bin()
{
  if [ "${1}" == "" ] ; then
    error "ERROR: Parameter missing"
    exit 0
  fi

  local _p=${1}
  local _src=${DEPLOYER}/lib/weblogic

  # wl_home
  if grep -e 'PRODUCTION_MODE="true"' ${iam_top}/products/${_p}/wlserver_10.3/common/bin/commEnv.sh >/dev/null ; then
    log "WL_HOME already patch, nothing to do"
  else
    patch -b ${iam_top}/products/${_p}/wlserver_10.3/common/bin/commEnv.sh <${_src}/commEnv.sh.patch
    log "WL_HOME patched: ${iam_top}/${_p}"
  fi
}

patch_wls_domain()
{
  if [ "${1}" == "" ] ; then
    error "ERROR: Parameter missing"
    exit $ERROR_SYNTAX_ERROR
  fi

  local _src=${DEPLOYER}/lib/${1}

  # admin domain
  if ! [ -a ${ADMIN_HOME}/bin/setCustDomainEnv.sh ]; then
    cp ${_src}/domain/setCustDomainEnv.sh ${ADMIN_HOME}/bin/
  fi

  if ! grep setCustDomainEnv ${ADMIN_HOME}/bin/setDomainEnv.sh >/dev/null 2>&1 ; then
    patch -b ${ADMIN_HOME}/bin/setDomainEnv.sh <${_src}/domain/setDomainEnv.sh.patch
    log "ADMIN_HOME patched: ${ADMIN_HOME}"
  fi

  # local domain
  if ! [ -a ${WRK_HOME}/bin/setCustDomainEnv.sh ]; then
    cp ${_src}/domain/setCustDomainEnv.sh ${WRK_HOME}/bin/
  fi

  if ! grep setCustDomainEnv ${WRK_HOME}/bin/setDomainEnv.sh >/dev/null 2>&1 ; then
    patch -b ${WRK_HOME}/bin/setDomainEnv.sh <${_src}/domain/setDomainEnv.sh.patch
    log "WRK_HOME patched: ${WRK_HOME}"
  fi
}

# create log area and link locations.  this script shall be run on each machine
#

#  -------------------------------------------------------------------------
#  private function - called by move_logs()
#
_mvlog()
{
  local src=${1}
  local dst=${2}
  if ! [ -a ${src} ] ; then
    return
  fi
  # check if already done
  if [ -h ${src} ] ; then
    warning "Already moved log dir ${src}"
  else
    mkdir -p "${dst}"
    # delete destination file if exsiting
    for f in ${dst}/* ; do
      rm -Rf "${f}"
    done
    # move all files to new destination
    for f in ${src}/* ; do
      mv "${f}" ${dst}/
    done
    # replace old location with soft link
    rm -Rf   ${src}
    ln -sf   ${dst} ${src}
  fi
}

#  --------------------------------------------------------------------------
#  public function - entry point
#  control flags: idm, acc, web, oud
#
move_logs()
{
  local _product=${1}
  oudins=oud1
  ohsins=ohs1

  dst=${iam_log}
  idmdom=${iam_domain_oim}
  accdom=${iam_domain_acc}

  if [ -z ${idmdom} ] ; then
    error "Env variable IDMPROV_IDENTITY_DOMAIN not defined"
    exit 81
  fi

  case ${_product} in
    idm)
      mkdir -p ${dst}/nodemanager
      _mvlog ${iam_top}/config/domains/${idmdom}/servers/AdminServer/logs           ${dst}/${idmdom}/AdminServer
      _mvlog ${iam_top}/services/domains/${idmdom}/servers/wls_soa1/logs            ${dst}/${idmdom}/wls_soa1
      _mvlog ${iam_top}/services/domains/${idmdom}/servers/wls_soa2/logs            ${dst}/${idmdom}/wls_soa2
      _mvlog ${iam_top}/services/domains/${idmdom}/servers/wls_oim1/logs            ${dst}/${idmdom}/wls_oim1
      _mvlog ${iam_top}/services/domains/${idmdom}/servers/wls_oim2/logs            ${dst}/${idmdom}/wls_oim2
      ;;
    acc)
      mkdir -p ${dst}/nodemanager
      _mvlog ${iam_top}/config/domains/${accdom}/servers/AdminServer/logs           ${dst}/${accdom}/AdminServer
      _mvlog ${iam_top}/services/domains/${accdom}/servers/wls_oam1/logs            ${dst}/${accdom}/wls_oam1
      _mvlog ${iam_top}/services/domains/${accdom}/servers/wls_oam2/logs            ${dst}/${accdom}/wls_oam2
      ;;
    dir)
      mkdir -p ${dst}/${oudins}
      _mvlog ${iam_top}/services/instances/${oudins}/OUD/logs                       ${dst}/${oudins}/logs
      ;;
    web)
      mkdir -p ${dst}/${ohsins}
      _mvlog ${iam_top}/services/instances/${ohsins}/auditlogs                      ${dst}/${ohsins}/auditlogs
      _mvlog ${iam_top}/services/instances/${ohsins}/diagnostics/logs/OHS/${ohsins} ${dst}/${ohsins}/logs
      _mvlog ${iam_top}/services/instances/${ohsins}/diagnostics/logs/OPMN/opmn     ${dst}/${ohsins}/opmn
      ;;
  esac
}

