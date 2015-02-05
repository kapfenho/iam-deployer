export   ORACLE_BASE=/appl/iam/fmw
export       MW_HOME=${ORACLE_BASE}/products/web
unset        WL_HOME
export   ORACLE_HOME=${MW_HOME}/ohs
export ORACLE_COMMON=${MW_HOME}/oracle_common
export     JAVA_HOME=${MW_HOME}/jdk6

unset         DOMAIN
unset    DOMAIN_HOME
unset     DOMAIN_LOG
export      INSTANCE=ohs1
export     INST_HOME=/appl/iam/fmw/config/instances/${INSTANCE}
export      INST_LOG=${INST_HOME}/diagnostics/logs/OHS/ohs1

export          PATH=${INST_HOME}/bin:${JAVA_HOME}/bin:${DEF_PATH}
export             E=web
