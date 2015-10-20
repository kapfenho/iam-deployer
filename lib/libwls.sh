# wlst functions for deploying
#

#  create domain properties file ----------------------------------------
#
create_dom_prop() {
  local     propFile=${1}
  local       keyDir=${2}
  local       nmPort=${3}
  local      domName=${4}
  local       domDir=${5}
  local       admDir=${6}
  local domAdminPort=${7}

  local host=$(hostname -f)

  cat > ${propFile} <<-EOS
	hostname=${host}
	nmPort=${nmPort}
	domName=${domName}
	domDir=${domDir}
	admDir=${admDir}
	domAdminPort=${domAdminPort}
	domUrl=t3://${host}:${domAdminPort}
	nmUC=${keyDir}/nm.usr
	nmUK=${keyDir}/nm.key
	domUC=${keyDir}/${domName}.usr
	domUK=${keyDir}/${domName}.key
EOS
}


#  create nodemanger keyfiles -------------------------------------------
#
wlst_create_nm_keyfiles() {
  local  propFile=${1}
  local    nmUser=${2}
  local     nmPwd=${3}

  ${WL_HOME}/common/bin/wlst.sh -loadProperties ${propFile} <<-EOF
nmConnect(username='${nmUser}', password='${nmPwd}',host=hostname,
 port=nmPort, domainName=domName,domainDir=domDir, nmType='ssl')
storeUserConfig(userConfigFile=nmUC,userKeyFile=nmUK,nm='true')
y
exit()
EOF
}

#  create domain keyfiles -----------------------------------------------
#
wlst_create_dom_keyfiles() {
  local  propFile=${1}
  local   domUser=${2}
  local    domPwd=${3}

  ${WL_HOME}/common/bin/wlst.sh -loadProperties ${propFile} <<-EOF
connect(username="${domUser}", password="${domPwd}", url=domUrl)
storeUserConfig(userConfigFile=domUC,userKeyFile=domUK,nm="false")
y
exit()
EOF
}

#  deploy standard lib acStdLib for wlst
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

