# custom settings for domain
#        horst.kapfenberger@agoracon.at, 19.11.2014
# 
#   * file is sourced in setDomainEnv.sh
#   * production mode
#   * memory args
#
# if we set USER_MEM_ARGS those values will overrode all other memory 
# settings in setDomainEnv.sh. distinction only by server_name.
#
# before changes: parameter for all services
#   -Xms256m -Xmx512m -XX:CompileThreshold=8000 -XX:PermSize=128m -XX:MaxPermSize=512m

PRODUCTION_MODE="true"
export PRODUCTION_MODE

uma=""

case ${SERVER_NAME} in
AdminServer)
  uma="-Xms256m -Xmx512m -XX:MaxPermSize=512m"
  ;;
*oam*)
  uma="-Xms512m -Xmx1536m -XX:MaxPermSize=512m"
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


