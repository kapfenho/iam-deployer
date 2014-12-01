export   ORACLE_BASE=/opt/fmw
export       MW_HOME=${ORACLE_BASE}/products/identity
export       WL_HOME=${MW_HOME}/wlserver_10.3
export   ORACLE_HOME=${MW_HOME}/iam
export ORACLE_COMMON=${MW_HOME}/oracle_common
export     JAVA_HOME=${MW_HOME}/jdk/current

export        DOMAIN=identity_test
export   DOMAIN_HOME=/opt/fmw/config/domains/${DOMAIN}
export    DOMAIN_LOG=/var/log/fmw/${DOMAIN}
unset       INSTANCE
unset      INST_HOME
unset       INST_LOG

export          PATH=${ORACLE_HOME}/bin:${JAVA_HOME}/bin:${DEF_PATH}
export             E=idm

alias wlst='${ORACLE_COMMON}/common/bin/wlst.sh -loadProperties ${HOME}/.env/identity.prop'

deploy() {
  . ${WL_HOME}/server/bin/setWLSEnv.sh
  java weblogic.WLST -loadProperties ~/.env/${1}.prop ${HOME}/lib/deploy.py
}

