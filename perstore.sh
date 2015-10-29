#!/bin/sh


set -o errexit
#set -o nounset

           DEPLOYER=/home/fmwuser/iam-deployer
        ORACLE_BASE=/l/ora/products
        DOMAIN_HOME=/l/ora/services/oia_iamvs
           OIA_BASE=${ORACLE_BASE}/analytics
      
# globals
   export JAVA_HOME=${OIA_BASE}/jdk
#export JAVA_OPTIONS="${JAVA_OPTIONS} -Xmx2048m -Xms2048m -Djava.net.preferIPv4Stack=true"
        export PATH=${PATH}:${JAVA_HOME}/bin
            WL_HOME=${OIA_BASE}/wlserver_10.3


config_perstore=${DEPLOYER}/lib/wlst/configure_perstore.py

#
# Create OIA WLS Domain JDBC Persistent store
CLASSPATH="${CLASSPATHSEP}${FMWLAUNCH_CLASSPATH}${CLASSPATHSEP}"
CLASSPATH+="${DERBY_CLASSPATH}${CLASSPATHSEP}${DERBY_TOOLS}${CLASSPATHSEP}"
CLASSPATH+="${POINTBASE_CLASSPATH}${CLASSPATHSEP}${POINTBASE_TOOLS}"
JVM_ARGS="-Dprod.props.file='${WL_HOME}'/.product.properties \
          ${WLST_PROPERTIES} ${JVM_D64} \
          -Xms256m \
          -Xmx1024m \
          -XX:PermSize=128m \
          -Dweblogic.management.confirmKeyfileCreation=true \
          ${CONFIG_JVM_ARGS}"


source ${WL_HOME}/server/bin/setWLSEnv.sh
eval '"${JAVA_HOME}/bin/java"' ${JVM_ARGS} weblogic.WLST \
     -skipWLSModuleScanning ${config_perstore}
 
