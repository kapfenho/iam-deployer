#!/bin/sh

WLS_HOME=/opt/fmw/products/access/wlserver_10.3
NM_HOME=/opt/fmw/config/nodemanager/iam0.dwpbank.net
JAVA_OPTIONS="-DNodeManagerHome=${NM_HOME} ${JAVA_OPTIONS}"
#JAVA_OPTIONS="-Dweblogic.security.SSL.enableJSSE=true ${JAVA_OPTIONS}"

export JAVA_OPTIONS WLS_HOME NM_HOME
exec ${WLS_HOME}/server/bin/startNodeManager.sh

