export   ORACLE_BASE=/appl/iam/fmw
export       MW_HOME=${ORACLE_BASE}/products/identity
export       WL_HOME=${MW_HOME}/wlserver_10.3
export   ORACLE_HOME=${MW_HOME}/iam
export ORACLE_COMMON=${MW_HOME}/oracle_common
export     JAVA_HOME=${MW_HOME}/jdk6
export        DOMAIN=IAMGovernanceDomain
export   DOMAIN_HOME=/appl/iam/fmw/config/domains/${DOMAIN}
export    DOMAIN_LOG=${DOMAIN_HOME}                                            
export ORACLE_COMMON=/appl/iam/fmw/products/identity/oracle_common/
export      ANT_HOME=/appl/iam/fmw/products/identity/modules/org.apache.ant_1.7.1/
export OIM_ORACLE_HOME=/appl/iam/fmw/products/identity/iam/
export      APP_SERVER=weblogic

unset       INSTANCE
unset      INST_HOME
unset       INST_LOG

export          PATH=${ORACLE_HOME}/bin:${JAVA_HOME}/bin:${DEF_PATH}:${ANT_HOME}bin
export             E=idm
