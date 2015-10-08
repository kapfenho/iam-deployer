#  wrapper for user config
#
#  load the iam provisioning variables and assign them to the 
#  variables used in the script
#

iam_config_rsp=${DEPLOYER}/user-config/iam/provisioning.rsp
lcm_config_rsp=${DEPLOYER}/user-config/lcm/lcm_install.rsp
grep -v -Ee '{' ${iam_config_rsp} | eval
. ${DEPLOYER}/user-config/iam.config


#  there are three categories of config values
#
#  1) config already in the two response files
#      lcm/lcm_install.rsp
#      iam/provisioning.rsp
#  2) default values if no config available
#      to override put config in iam.config
#  3) passwords
#      pwd are encrypted in response files and
#      need to be specified twice
#

:      ${iam_user_umask:="0007"}
  
:             ${iam_pwd:="Montag11"}
: ${iam_oim_schema_pass:=${iam_pwd}}
: ${iam_oam_schema_pass:=${iam_pwd}}
:        ${iam_dba_pass:=${iam_pwd}}
  
:              ${nmUser:=${NODEMANAGER_NAME}}
:               ${nmPwd:=${iam_pwd}}
:            ${domaUser:=${WLSADMIN_NAME}}
:             ${domaPwd:=${iam_pwd}}
:            ${domiUser:=${WLSADMIN_NAME}}
:             ${domiPwd:=${iam_pwd}}
:              ${oudPwd:=${iam_pwd}}
  
:              ${DO_IDM:="yes"}
:              ${DO_ACC:="yes"}
:              ${DO_WEB:="yes"}
:              ${DO_OUD:="yes"}
:              ${DO_BIP:="no"}
  
:              ${s_base:=${IL_INSTALLERDIR_LOCATION}}
:               ${s_lcm:=${s_base}/installers/idmlcm}
:          ${s_rcu_home:=${s_base}/installers/fmw_rcu/linux/rcuHome}
:            ${s_runjdk:=${s_base}/installers/jdk/jdk7}
:            ${s_runjre:=${s_runjdk}/jre}
: 
:             ${iam_top:=${IL_APP_BASE}}
:         ${iam_lcmhome:=${INSTALL_LCMHOME_DIR}}
:         ${iam_hostenv:=${iam_top}/home}
                 iam_lcm=$(grep "ORACLE_HOME=" ${lcm_config_rsp} | cut -d= -f2)
  
:      ${iam_orainv_ptr:=${iam_top}/etc/oraInst.loc}
:          ${iam_orainv:=${iam_top}/etc/oraInventory}
:      ${iam_orainv_grp:="oinstall"}
  
:              ${sc_env:="~/.env"}
:              ${sc_bin:="~/bin"}
:              ${sc_lib:="~/lib"}
:              ${sc_crd:="~/.cred"}
  
:          ${dbs_dbhost:=${OIM_SINGLE_DB_HOST}}
:            ${dbs_port:=${OIM_SINGLE_DB_PORT}}
:             ${iam_sid:=${OIM_DB_SERVICENAME}}
:      ${iam_oim_prefix:=${OIM_DB_SCHEMAPREFIX}}

#    ${iam_oam_prefix:=${OIM_DB_SCHEMAPREFIX}}
#    ${iam_bip_prefix:=${OIM_DB_SCHEMAPREFIX}}

#                TOPOLOGY_BASIC_HOST=iam7.agoracon.at
#                INSTALL_LCMHOME_DIR=/l/ora/lcm/lcmhome
#            INSTALL_LOCALCONFIG_DIR=/l/ora/services
#    IDMPROV_PRODUCT_IDENTITY_DOMAIN=iam_iam7
#              IDMPROV_ACCESS_DOMAIN=IAMAccessDomain
# IDMPROV_OIMDOMAIN_ADMINSERVER_PORT=7001
#                   IDMPROV_OIM_PORT=8005
#                   IDMPROV_OHS_PORT=7777
#                IDMPROV_OHS_SSLPORT=4443

