#!/bin/sh

WLS_HOME=_IAMTOP_/products/identity/wlserver_10.3
NM_HOME=_IAMTOP_/config/nodemanager/_HOST_
JAVA_OPTIONS="-DNodeManagerHome=${NM_HOME} ${JAVA_OPTIONS}"
#JAVA_OPTIONS="-Dweblogic.security.SSL.enableJSSE=true ${JAVA_OPTIONS}"

export JAVA_OPTIONS WLS_HOME NM_HOME
exec ${WLS_HOME}/server/bin/startNodeManager.sh

