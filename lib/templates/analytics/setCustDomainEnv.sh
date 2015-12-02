# custom settings for domain
#        horst.kapfenberger@agoracon.at, 27.11.2015
# 
#   * file is sourced in setDomainEnv.sh
#   * production mode
#   * memory args
#
# if we set USER_MEM_ARGS those values will overrode all other memory 
# settings in setDomainEnv.sh. distinction only by server_name.
#
# Examples:
#   -Xms256m 
#   -Xmx512m
#   -XX:PermSize=128m
#   -XX:MaxPermSize=512m
#   -XX:CompileThreshold=8000
#   -XX:ReservedCodeCacheSize=256m

export PRODUCTION_MODE="true"
export      RBACX_HOME=__IAM_TOP__/config/analytics/oia
export OIM_CLIENT_HOME=__IAM_TOP__/config/analytics/oia/xellerate
export  APPSERVER_TYPE=wls

uma=""
case ${SERVER_NAME} in
AdminServer)
  uma="-Xms1024m -Xmx1536m -XX:MaxPermSize=512m"
  ;;
*oia*)
  uma="-Xms1g -Xmx2g -XX:MaxPermSize=1024m"
  EXTRA_JAVA_PROPERTIES+=" -Djava.naming.factory.initial=weblogic.jndi.WLInitialContextFactory"
  EXTRA_JAVA_PROPERTIES+=" -Djava.security.auth.login.config=${OIM_CLIENT_HOME}/config/authwl.conf"
  EXTRA_JAVA_PROPERTIES+=" -Djava.net.preferIPv4Stack=true"
  export EXTRA_JAVA_PROPERTIES
  ;;
esac

if [ "${uma}" == "" ]
then
  echo "WARNING: server name ${SERVER_NAME} unknown (bin/setDomainCustEnv.sh), no memory settings applied"
  echo
else
  USER_MEM_ARGS=${uma}
  export USER_MEM_ARGS
  echo "Memory settings defined in bin/setDomainCustEnv.sh:  ${uma}"
  echo
fi

