export   ORACLE_BASE=/appl/iam/fmw
export       MW_HOME=${ORACLE_BASE}/products/dir
unset        WL_HOME
export   ORACLE_HOME=${MW_HOME}/oud
unset  ORACLE_COMMON
export     JAVA_HOME=${MW_HOME}/jdk/current

unset         DOMAIN
unset    DOMAIN_HOME
unset     DOMAIN_LOG
export      INSTANCE=oud1
export  INSTANCE_DIR=/appl/iam/fmw/config/instances/${INSTANCE}
export     INST_HOME=/appl/iam/fmw/config/instances/${INSTANCE}/OUD
export      INST_LOG=/appl/logs/iam/oud1/logs

export          PATH=${INST_HOME}/bin:${JAVA_HOME}/bin:${DEF_PATH}
export             E=dir
