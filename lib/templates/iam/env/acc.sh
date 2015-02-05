export   ORACLE_BASE=/appl/iam/fmw
export       MW_HOME=${ORACLE_BASE}/products/access
export       WL_HOME=${MW_HOME}/wlserver_10.3
export   ORACLE_HOME=${MW_HOME}/iam
export ORACLE_COMMON=${MW_HOME}/oracle_common
export     JAVA_HOME=${MW_HOME}/jdk6

export        DOMAIN=accdev
export   DOMAIN_HOME=/appl/iam/fmw/config/domains/${DOMAIN}
export    DOMAIN_LOG=${DOMAIN_HOME}                                            
unset       INSTANCE
unset      INST_HOME
unset       INST_LOG

export          PATH=${ORACLE_HOME}/bin:${JAVA_HOME}/bin:${DEF_PATH}
export             E=acc
