export   ORACLE_BASE=/appexec/fmw
export       MW_HOME=${ORACLE_BASE}/products/dir
unset        WL_HOME
export   ORACLE_HOME=${MW_HOME}/oud
unset  ORACLE_COMMON
export     JAVA_HOME=${MW_HOME}/jdk/current

unset         DOMAIN
unset    DOMAIN_HOME
unset     DOMAIN_LOG
export      INSTANCE=oud1
export  INSTANCE_DIR=/opt/local/instances/${INSTANCE}
export     INST_HOME=/opt/local/instances/${INSTANCE}/OUD
export      INST_LOG=/var/logs/fmw/oud1/logs

export          PATH=${INST_HOME}/bin:${JAVA_HOME}/bin:${DEF_PATH}
export             E=dir
