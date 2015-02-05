export   ORACLE_BASE=/appl/iam/fmw
export       MW_HOME=${ORACLE_BASE}/products/dir
unset        WL_HOME
export   ORACLE_HOME=${MW_HOME}/oud
unset  ORACLE_COMMON
export     JAVA_HOME=${MW_HOME}/jdk/current

unset         DOMAIN
unset    DOMAIN_HOME
unset     DOMAIN_LOG
export      INSTANCE=play1
export  INSTANCE_DIR=/appl/iam/play/${INSTANCE}
export     INST_HOME=/appl/iam/play/${INSTANCE}/OUD
export      INST_LOG=/appl/iam/play/${INSTANCE}/logs

export          PATH=${INST_HOME}/bin:${JAVA_HOME}/bin:${DEF_PATH}
export             E=play1
