#  INST_HOME=/opt/poud/prod20140502/OUD
#  ORACLE_HOME=/opt/poud/oud_11gr2_11.1.2.0.0

export   ORACLE_BASE=/opt/poud
export       MW_HOME=${ORACLE_BASE}/oud_11gr2_11.1.2.0.0

unset        WL_HOME
export   ORACLE_HOME=${MW_HOME}
unset  ORACLE_COMMON
export     JAVA_HOME=/opt/fmw/products/dir/jdk/current

unset         DOMAIN
unset    DOMAIN_HOME
unset     DOMAIN_LOG
export      INSTANCE=prod20140502
export  INSTANCE_DIR=/opt/poud/${INSTANCE}
export     INST_HOME=/opt/poud/${INSTANCE}/OUD
unset       INST_LOG

export          PATH=${INST_HOME}/bin:${JAVA_HOME}/bin:${DEF_PATH}
export             E=poud
