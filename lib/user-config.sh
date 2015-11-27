#  wrapper for user config
#
#  load the iam provisioning variables and assign them to the 
#  variables used in the script
#
iam_config_rsp=${DEPLOYER}/user-config/iam/provisioning.rsp
lcm_config_rsp=${DEPLOYER}/user-config/lcm/lcm_install.rsp

getvar() {
  eval $(grep ${1} ${iam_config_rsp}) 2>/dev/null || true
}

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

getvar DT_SINGLEHOST
getvar IDMPROV_ACCESS_DOMAIN
getvar IDMPROV_LBR_OIMADMIN_HOST
getvar IDMPROV_LBR_OIMINTERNAL_HOST
getvar IDMPROV_LBR_SSO_HOST
getvar IDMPROV_OIMDOMAIN_ADMINSERVER_HOST
getvar IDMPROV_OIMDOMAIN_ADMINSERVER_PORT
getvar IDMPROV_OIM_HOST
getvar IDMPROV_OIM_PORT
getvar IDMPROV_PRODUCT_IDENTITY_DOMAIN
getvar IDMPROV_SECOND_OIM_HOST
getvar IDMPROV_SECOND_OIM_PORT
getvar IDMPROV_SECOND_SOA_HOST
getvar IDMPROV_SECOND_SOA_PORT
getvar IDMPROV_SOA_HOST
getvar IDMPROV_SOA_PORT
getvar IL_APP_BASE
getvar IL_INSTALLERDIR_LOCATION
getvar INSTALL_LCMHOME_DIR
getvar INSTALL_LOCALCONFIG_DIR
getvar NODEMANAGER_NAME
getvar OHS_INSTANCENAME
getvar OIM_DB_SCHEMAPREFIX
getvar OIM_DB_SERVICENAME
getvar OIM_SINGLE_DB_HOST
getvar OIM_SINGLE_DB_PORT
getvar WLSADMIN_NAME
getvar WLSADMIN_NAME


:          ${iam_user_umask:="0007"}
:          ${iam_orainv_grp:="oinstall"}
:        ${iam_oia_dos2unix:="NO"}
    
:                 ${iam_pwd:="Montag11"}
:     ${iam_oim_schema_pass:=${iam_pwd}}
:     ${iam_oam_schema_pass:=${iam_pwd}}
:     ${iam_bip_schema_pass:=${iam_pwd}}
:     ${iam_oia_schema_pass:=${iam_pwd}}
:            ${iam_dba_pass:=${iam_pwd}}
:                   ${nmPwd:=${iam_pwd}}
:                 ${domaPwd:=${iam_pwd}}
:                 ${domiPwd:=${iam_pwd}}
:                  ${oudPwd:=${iam_pwd}}
:               ${oiaWlUser:="Weblogic"}
:                ${oiaWlPwd:=${iam_pwd}}
:         ${domiAdminServer:="AdminServer"}
:         ${domaAdminServer:="AdminServer"}
:         ${domlAdminServer:="AdminServer"}
:        ${IDMPROV_OIA_HOST:=${IDMPROV_OIM_HOST}}
: ${IDMPROV_SECOND_OIA_HOST:=${IDMPROV_SECOND_OIM_HOST}}
:        ${IDMPROV_OIA_PORT:="7310"}
: ${IDMPROV_SECOND_OIA_PORT:="7310"}
#

# --------- user must not set this
            iam_top=${IL_APP_BASE}
        iam_lcmhome=${INSTALL_LCMHOME_DIR}
       iam_services=${INSTALL_LOCALCONFIG_DIR}
        iam_hostenv=${HOME}
     
             nmUser=${NODEMANAGER_NAME}
           domaUser=${WLSADMIN_NAME}
           domiUser=${WLSADMIN_NAME}
   
: ${iam_orainv_ptr:=${iam_top}/lcm/oraInst.loc}
:     ${iam_orainv:=${iam_top}/lcm/oraInventory}

             s_base=${IL_INSTALLERDIR_LOCATION}
              s_lcm=${s_base}/installers/idmlcm
:    ${s_rcu_home:="${s_base}/installers/fmw_rcu/linux/rcuHome"}
:         ${s_wls:="${s_base}/installers/weblogic/wls_generic.jar"}
:      ${s_runjdk:="${s_base}/installers/jdk/jdk6"}
:      ${s_runjre:="${s_runjdk}/jre"}
      
         dbs_dbhost=${OIM_SINGLE_DB_HOST}
           dbs_port=${OIM_SINGLE_DB_PORT}
            iam_sid=${OIM_DB_SERVICENAME}
     iam_oim_prefix=${OIM_DB_SCHEMAPREFIX}

     iam_domain_oim=${IDMPROV_PRODUCT_IDENTITY_DOMAIN}
     iam_domain_acc=${IDMPROV_ACCESS_DOMAIN}
   iam_instance_ohs=${OHS_INSTANCENAME}

   # get oud instance name dynamically, always local dirctory
for d in ${iam_services}/instances/* ; do
  [[ "${d}" =~ "ohs" ]] && continue
  iam_instance_oud=${d}
  break
done

iam_lcm=$(grep "ORACLE_HOME=" ${lcm_config_rsp} | cut -d= -f2)


#    ${iam_oam_prefix:=${OIM_DB_SCHEMAPREFIX}}
#    ${iam_bip_prefix:=${OIM_DB_SCHEMAPREFIX}}
#                TOPOLOGY_BASIC_HOST=iam7.agoracon.at
# IDMPROV_OIMDOMAIN_ADMINSERVER_PORT=7001
#                   IDMPROV_OIM_PORT=8005
#                   IDMPROV_OHS_PORT=7777
#                IDMPROV_OHS_SSLPORT=4443

