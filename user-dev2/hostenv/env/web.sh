export   ORACLE_BASE=/appexec/fmw
export       MW_HOME=${ORACLE_BASE}/products/web
unset        WL_HOME
export   ORACLE_HOME=${MW_HOME}/ohs
export ORACLE_COMMON=${MW_HOME}/oracle_common
export     JAVA_HOME=${MW_HOME}/jdk/current

unset         DOMAIN
unset    DOMAIN_HOME
unset     DOMAIN_LOG
export      INSTANCE=ohs1
export     INST_HOME=/opt/local/instances/${INSTANCE}
export      INST_LOG=/var/log/fmw/${INSTANCE}

export          PATH=${INST_HOME}/bin:${JAVA_HOME}/bin:${DEF_PATH}
export             E=web
