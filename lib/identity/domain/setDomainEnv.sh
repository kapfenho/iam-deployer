#!/bin/sh

# WARNING: This file is created by the Configuration Wizard.
# Any changes to this script may be lost when adding extensions to this configuration.

# --- Start Functions ---

BP=100
SP=$BP

pushd()
{
	if [ -z "$1" ]
	then
		return
	fi

	SP=`expr $SP - 1`
	eval _stack$SP=`pwd`
	cd $1
	return
}

popd()
{
	if [ $SP -eq $BP ]
	then
		return
	fi
	eval cd \${_stack$SP}
	SP=`expr $SP + 1`
	return
}


# --- End Functions ---

# *************************************************************************
# This script is used to setup the needed environment to be able to start Weblogic Server in this domain.
# 
# This script initializes the following variables before calling commEnv to set other variables:
# 
# WL_HOME         - The BEA home directory of your WebLogic installation.
# JAVA_VM         - The desired Java VM to use. You can set this environment variable before calling
#                   this script to switch between Sun or BEA or just have the default be set. 
# JAVA_HOME       - Location of the version of Java used to start WebLogic
#                   Server. Depends directly on which JAVA_VM value is set by default or by the environment.
# USER_MEM_ARGS   - The variable to override the standard memory arguments
#                   passed to java.
# PRODUCTION_MODE - The variable that determines whether Weblogic Server is started in production mode.
# DOMAIN_PRODUCTION_MODE 
#                 - The variable that determines whether the workshop related settings like the debugger,
#                   testconsole or iterativedev should be enabled. ONLY settable using the 
#                   command-line parameter named production
#                   NOTE: Specifying the production command-line param will force 
#                          the server to start in production mode.
# 
# Other variables used in this script include:
# SERVER_NAME     - Name of the weblogic server.
# JAVA_OPTIONS    - Java command-line options for running the server. (These
#                   will be tagged on to the end of the JAVA_VM and
#                   MEM_ARGS)
# 
# For additional information, refer to "Managing Server Startup and Shutdown for Oracle WebLogic Server"
# (http://download.oracle.com/docs/cd/E23943_01/web.1111/e13708/overview.htm).
# *************************************************************************

COMMON_COMPONENTS_HOME="/opt/fmw/products/identity/oracle_common"
export COMMON_COMPONENTS_HOME


OES_ORACLE_HOME="/opt/fmw/products/identity/iam/oes/"
export OES_ORACLE_HOME


APM_ORACLE_HOME="/opt/fmw/products/identity/iam/apm/"
export APM_ORACLE_HOME


OIM_ORACLE_HOME="/opt/fmw/products/identity/iam"
export OIM_ORACLE_HOME


APPLICATIONS_DIRECTORY="/opt/fmw/config/domains/identity_test/applications"
export APPLICATIONS_DIRECTORY


ORACLE_HOME="/opt/fmw/products/identity/iam/"
export ORACLE_HOME


WL_HOME="/opt/fmw/products/identity/wlserver_10.3"
export WL_HOME

BEA_JAVA_HOME="/opt/fmw/products/identity/jdk/current"
export BEA_JAVA_HOME

SUN_JAVA_HOME=""
export SUN_JAVA_HOME

UMS_ORACLE_HOME="/opt/fmw/products/identity/soa"
export UMS_ORACLE_HOME


if [ "${POST_CLASSPATH}" != "" ] ; then
	POST_CLASSPATH="${OES_ORACLE_HOME}/oes-server-manifest.jar${CLASSPATHSEP}${POST_CLASSPATH}"
	export POST_CLASSPATH
else
	POST_CLASSPATH="${OES_ORACLE_HOME}/oes-server-manifest.jar"
	export POST_CLASSPATH
fi


SOA_ORACLE_HOME="/opt/fmw/products/identity/soa"
export SOA_ORACLE_HOME


if [ "${JAVA_VENDOR}" = "Oracle" ] ; then
	JAVA_HOME="${BEA_JAVA_HOME}"
	export JAVA_HOME
else
	if [ "${JAVA_VENDOR}" = "Sun" ] ; then
		JAVA_HOME="${SUN_JAVA_HOME}"
		export JAVA_HOME
	else
		JAVA_VENDOR="Oracle"
		export JAVA_VENDOR
		JAVA_HOME="/opt/fmw/products/identity/jdk/current"
		export JAVA_HOME
	fi
fi

# We need to reset the value of JAVA_HOME to get it shortened AND 
# we can not shorten it above because immediate variable expansion will blank it

JAVA_HOME="${JAVA_HOME}"
export JAVA_HOME

SAMPLES_HOME="${WL_HOME}/samples"
export SAMPLES_HOME

DOMAIN_HOME="/opt/fmw/config/domains/identity_test"
export DOMAIN_HOME

LONG_DOMAIN_HOME="/opt/fmw/config/domains/identity_test"
export LONG_DOMAIN_HOME

if [ "${DEBUG_PORT}" = "" ] ; then
	DEBUG_PORT="8453"
	export DEBUG_PORT
fi

if [ "${SERVER_NAME}" = "" ] ; then
	SERVER_NAME="AdminServer"
	export SERVER_NAME
fi

DERBY_FLAG="false"
export DERBY_FLAG

enableHotswapFlag=""
export enableHotswapFlag

PRODUCTION_MODE="true"
export PRODUCTION_MODE

doExitFlag="false"
export doExitFlag
verboseLoggingFlag="false"
export verboseLoggingFlag
while [ $# -gt 0 ]
do
	case $1 in
	nodebug)
		debugFlag="false"
		export debugFlag
		;;
	production)
		DOMAIN_PRODUCTION_MODE="true"
		export DOMAIN_PRODUCTION_MODE
		;;
	notestconsole)
		testConsoleFlag="false"
		export testConsoleFlag
		;;
	noiterativedev)
		iterativeDevFlag="false"
		export iterativeDevFlag
		;;
	noLogErrorsToConsole)
		logErrorsToConsoleFlag="false"
		export logErrorsToConsoleFlag
		;;
	noderby)
		DERBY_FLAG="false"
		export DERBY_FLAG
		;;
	doExit)
		doExitFlag="true"
		export doExitFlag
		;;
	noExit)
		doExitFlag="false"
		export doExitFlag
		;;
	verbose)
		verboseLoggingFlag="true"
		export verboseLoggingFlag
		;;
	enableHotswap)
		enableHotswapFlag="-javaagent:${WL_HOME}/server/lib/diagnostics-agent.jar"
		export enableHotswapFlag
		;;
	*)
		PROXY_SETTINGS="${PROXY_SETTINGS} $1"
		export PROXY_SETTINGS
		;;
	esac
	shift
done


MEM_DEV_ARGS=""
export MEM_DEV_ARGS

if [ "${DOMAIN_PRODUCTION_MODE}" = "true" ] ; then
	PRODUCTION_MODE="${DOMAIN_PRODUCTION_MODE}"
	export PRODUCTION_MODE
fi

if [ "${PRODUCTION_MODE}" = "true" ] ; then
	debugFlag="false"
	export debugFlag
	testConsoleFlag="false"
	export testConsoleFlag
	iterativeDevFlag="false"
	export iterativeDevFlag
	logErrorsToConsoleFlag="false"
	export logErrorsToConsoleFlag
fi

# If you want to override the default Patch Classpath, Library Path and Path for this domain,
# Please uncomment the following lines and add a valid value for the environment variables
# set PATCH_CLASSPATH=[myPatchClasspath] (windows)
# set PATCH_LIBPATH=[myPatchLibpath] (windows)
# set PATCH_PATH=[myPatchPath] (windows)
# PATCH_CLASSPATH=[myPatchClasspath] (unix)
# PATCH_LIBPATH=[myPatchLibpath] (unix)
# PATCH_PATH=[myPatchPath] (unix)

. ${WL_HOME}/common/bin/commEnv.sh

. ${DOMAIN_HOME}/bin/setSOADomainEnv.sh


. ${DOMAIN_HOME}/bin/setOIMDomainEnv.sh

# Custom settings -- horst kapfenberger --
. ${DOMAIN_HOME}/bin/setCustDomainEnv.sh
# custom setting -- end --


WLS_HOME="${WL_HOME}/server"
export WLS_HOME

XMS_SUN_64BIT="256"
export XMS_SUN_64BIT
XMS_SUN_32BIT="256"
export XMS_SUN_32BIT
XMX_SUN_64BIT="512"
export XMX_SUN_64BIT
XMX_SUN_32BIT="512"
export XMX_SUN_32BIT
XMS_JROCKIT_64BIT="256"
export XMS_JROCKIT_64BIT
XMS_JROCKIT_32BIT="256"
export XMS_JROCKIT_32BIT
XMX_JROCKIT_64BIT="512"
export XMX_JROCKIT_64BIT
XMX_JROCKIT_32BIT="512"
export XMX_JROCKIT_32BIT


if [ "${JAVA_VENDOR}" = "Sun" ] ; then
	WLS_MEM_ARGS_64BIT="-Xms256m -Xmx512m"
	export WLS_MEM_ARGS_64BIT
	WLS_MEM_ARGS_32BIT="-Xms256m -Xmx512m"
	export WLS_MEM_ARGS_32BIT
else
	WLS_MEM_ARGS_64BIT="-Xms512m -Xmx512m"
	export WLS_MEM_ARGS_64BIT
	WLS_MEM_ARGS_32BIT="-Xms512m -Xmx512m"
	export WLS_MEM_ARGS_32BIT
fi

if [ "${JAVA_VENDOR}" = "Oracle" ] ; then
	CUSTOM_MEM_ARGS_64BIT="-Xms${XMS_JROCKIT_64BIT}m -Xmx${XMX_JROCKIT_64BIT}m"
	export CUSTOM_MEM_ARGS_64BIT
	CUSTOM_MEM_ARGS_32BIT="-Xms${XMS_JROCKIT_32BIT}m -Xmx${XMX_JROCKIT_32BIT}m"
	export CUSTOM_MEM_ARGS_32BIT
else
	CUSTOM_MEM_ARGS_64BIT="-Xms${XMS_SUN_64BIT}m -Xmx${XMX_SUN_64BIT}m"
	export CUSTOM_MEM_ARGS_64BIT
	CUSTOM_MEM_ARGS_32BIT="-Xms${XMS_SUN_32BIT}m -Xmx${XMX_SUN_32BIT}m"
	export CUSTOM_MEM_ARGS_32BIT
fi


MEM_ARGS_64BIT="${CUSTOM_MEM_ARGS_64BIT}"
export MEM_ARGS_64BIT

MEM_ARGS_32BIT="${CUSTOM_MEM_ARGS_32BIT}"
export MEM_ARGS_32BIT

if [ "${JAVA_USE_64BIT}" = "true" ] ; then
	MEM_ARGS="${MEM_ARGS_64BIT}"
	export MEM_ARGS
else
	MEM_ARGS="${MEM_ARGS_32BIT}"
	export MEM_ARGS
fi

MEM_PERM_SIZE_64BIT="-XX:PermSize=128m"
export MEM_PERM_SIZE_64BIT

MEM_PERM_SIZE_32BIT="-XX:PermSize=128m"
export MEM_PERM_SIZE_32BIT

if [ "${JAVA_USE_64BIT}" = "true" ] ; then
	MEM_PERM_SIZE="${MEM_PERM_SIZE_64BIT}"
	export MEM_PERM_SIZE
else
	MEM_PERM_SIZE="${MEM_PERM_SIZE_32BIT}"
	export MEM_PERM_SIZE
fi

MEM_MAX_PERM_SIZE_64BIT="-XX:MaxPermSize=512m"
export MEM_MAX_PERM_SIZE_64BIT

MEM_MAX_PERM_SIZE_32BIT="-XX:MaxPermSize=512m"
export MEM_MAX_PERM_SIZE_32BIT

if [ "${JAVA_USE_64BIT}" = "true" ] ; then
	MEM_MAX_PERM_SIZE="${MEM_MAX_PERM_SIZE_64BIT}"
	export MEM_MAX_PERM_SIZE
else
	MEM_MAX_PERM_SIZE="${MEM_MAX_PERM_SIZE_32BIT}"
	export MEM_MAX_PERM_SIZE
fi

if [ "${JAVA_VENDOR}" = "Sun" ] ; then
	if [ "${PRODUCTION_MODE}" = "" ] ; then
		MEM_DEV_ARGS="-XX:CompileThreshold=8000 ${MEM_PERM_SIZE} "
		export MEM_DEV_ARGS
	fi
fi

# Had to have a separate test here BECAUSE of immediate variable expansion on windows

if [ "${JAVA_VENDOR}" = "Sun" ] ; then
	MEM_ARGS="${MEM_ARGS} ${MEM_DEV_ARGS} ${MEM_MAX_PERM_SIZE}"
	export MEM_ARGS
fi

if [ "${JAVA_VENDOR}" = "HP" ] ; then
	MEM_ARGS="${MEM_ARGS} ${MEM_MAX_PERM_SIZE}"
	export MEM_ARGS
fi

if [ "${JAVA_VENDOR}" = "Apple" ] ; then
	MEM_ARGS="${MEM_ARGS} ${MEM_MAX_PERM_SIZE}"
	export MEM_ARGS
fi

## # IF USER_MEM_ARGS the environment variable is set, use it to override ALL MEM_ARGS values
## 
## if [ "${USER_MEM_ARGS}" != "" ] ; then
## 	MEM_ARGS="${USER_MEM_ARGS}"
## 	export MEM_ARGS
## fi
 
ORACLE_DOMAIN_CONFIG_DIR="${DOMAIN_HOME}/config/fmwconfig"
export ORACLE_DOMAIN_CONFIG_DIR
WLS_JDBC_REMOTE_ENABLED="-Dweblogic.jdbc.remoteEnabled=false"
export WLS_JDBC_REMOTE_ENABLED


JAVA_PROPERTIES="-Dplatform.home=${WL_HOME} -Dwls.home=${WLS_HOME} -Dweblogic.home=${WLS_HOME} "
export JAVA_PROPERTIES

ALT_TYPES_DIR="${COMMON_COMPONENTS_HOME}/modules/oracle.ossoiap_11.1.1,${COMMON_COMPONENTS_HOME}/modules/oracle.oamprovider_11.1.1,${COMMON_COMPONENTS_HOME}/modules/oracle.jps_11.1.1"
export ALT_TYPES_DIR
PROTOCOL_HANDLERS="oracle.mds.net.protocol"
export PROTOCOL_HANDLERS


ALT_TYPES_DIR="${OIM_ORACLE_HOME}/server/loginmodule/wls,${ALT_TYPES_DIR}"
export ALT_TYPES_DIR


PROTOCOL_HANDLERS="${PROTOCOL_HANDLERS}|oracle.fabric.common.classloaderurl.handler|oracle.fabric.common.uddiurl.handler|oracle.bpm.io.fs.protocol"
export PROTOCOL_HANDLERS


#  To use Java Authorization Contract for Containers (JACC) in this domain, 
#  please uncomment the following section. If there are multiple machines in 
#  your domain, be sure to edit the setDomainEnv in the associated domain on 
#  each machine.
# 
# -Djava.security.manager
# -Djava.security.policy=location of weblogic.policy
# -Djavax.security.jacc.policy.provider=weblogic.security.jacc.simpleprovider.SimpleJACCPolicy
# -Djavax.security.jacc.PolicyConfigurationFactory.provider=weblogic.security.jacc.simpleprovider.PolicyConfigurationFactoryImpl
# -Dweblogic.security.jacc.RoleMapperFactory.provider=weblogic.security.jacc.simpleprovider.RoleMapperFactoryImpl

EXTRA_JAVA_PROPERTIES="-Doracle.apm.home=${APM_ORACLE_HOME} -DAPM_HELP_FILENAME=oesohwconfig.xml -Djavax.management.builder.initial=weblogic.management.jmx.mbeanserver.WLSMBeanServerBuilder ${EXTRA_JAVA_PROPERTIES}"
export EXTRA_JAVA_PROPERTIES

EXTRA_JAVA_PROPERTIES="-Doracle.fusion.appsMode=true
${EXTRA_JAVA_PROPERTIES}"
export EXTRA_JAVA_PROPERTIES

EXTRA_JAVA_PROPERTIES=" ${EXTRA_JAVA_PROPERTIES} -DXL.HomeDir=${OIM_ORACLE_HOME}/server  -Dscheduler.disabled=false -Djava.security.auth.login.config=${OIM_ORACLE_HOME}/server/config/authwl.conf  -Dorg.owasp.esapi.resources=${OIM_ORACLE_HOME}/server/apps/oim.ear/APP-INF/classes -DeditionOverride=ee -Djbo.ampool.doampooling=true -Djbo.ampool.minavailablesize=1 -Djbo.ampool.maxavailablesize=120 -Djbo.recyclethreshold=60 -Djbo.ampool.timetolive=-1 -Djbo.load.components.lazily=true -Djbo.doconnectionpooling=true -Djbo.txn.disconnect_level=1 -Djbo.connectfailover=false -Djbo.max.cursors=5 -Doracle.jdbc.implicitStatementCacheSize=5 -Doracle.jdbc.maxCachedBufferSize=19"
export EXTRA_JAVA_PROPERTIES

EXTRA_JAVA_PROPERTIES="${EXTRA_JAVA_PROPERTIES} -Dem.oracle.home=/opt/fmw/products/identity/oracle_common -Djava.awt.headless=true"
export EXTRA_JAVA_PROPERTIES

EXTRA_JAVA_PROPERTIES=" -Doracle.idm.ipf.home=${ORACLE_HOME}/modules/oracle.idm.ipf_11.1.2 ${EXTRA_JAVA_PROPERTIES}"
export EXTRA_JAVA_PROPERTIES

EXTRA_JAVA_PROPERTIES="${EXTRA_JAVA_PROPERTIES} -Dsoa.archives.dir=${SOA_ORACLE_HOME}/soa -Dsoa.oracle.home=${SOA_ORACLE_HOME} -Dsoa.instance.home=${DOMAIN_HOME} -Dtangosol.coherence.clusteraddress=227.7.7.9 -Dtangosol.coherence.clusterport=9778 -Dtangosol.coherence.log=jdk -Djavax.xml.soap.MessageFactory=oracle.j2ee.ws.saaj.soap.MessageFactoryImpl -Dweblogic.transaction.blocking.commit=true -Dweblogic.transaction.blocking.rollback=true -Djavax.net.ssl.trustStore=${WL_HOME}/server/lib/DemoTrust.jks"
export EXTRA_JAVA_PROPERTIES

EXTRA_JAVA_PROPERTIES="${EXTRA_JAVA_PROPERTIES} -Dums.oracle.home=${UMS_ORACLE_HOME}"
export EXTRA_JAVA_PROPERTIES

EXTRA_JAVA_PROPERTIES="-Dcommon.components.home=${COMMON_COMPONENTS_HOME} -Djrf.version=11.1.1 -Dorg.apache.commons.logging.Log=org.apache.commons.logging.impl.Jdk14Logger -Ddomain.home=${DOMAIN_HOME} -Djrockit.optfile=${COMMON_COMPONENTS_HOME}/modules/oracle.jrf_11.1.1/jrocket_optfile.txt -Doracle.server.config.dir=${ORACLE_DOMAIN_CONFIG_DIR}/servers/${SERVER_NAME} -Doracle.domain.config.dir=${ORACLE_DOMAIN_CONFIG_DIR}  -Digf.arisidbeans.carmlloc=${ORACLE_DOMAIN_CONFIG_DIR}/carml  -Digf.arisidstack.home=${ORACLE_DOMAIN_CONFIG_DIR}/arisidprovider -Doracle.security.jps.config=${DOMAIN_HOME}/config/fmwconfig/jps-config.xml -Doracle.deployed.app.dir=${DOMAIN_HOME}/servers/${SERVER_NAME}/tmp/_WL_user -Doracle.deployed.app.ext=/- -Dweblogic.alternateTypesDirectory=${ALT_TYPES_DIR} -Djava.protocol.handler.pkgs=${PROTOCOL_HANDLERS}  ${WLS_JDBC_REMOTE_ENABLED} ${EXTRA_JAVA_PROPERTIES}"
export EXTRA_JAVA_PROPERTIES


## if [ "${SERVER_NAME}" = "wls_oim1" -o "${SERVER_NAME}" = "wls_oim2" ]
## then
##   EXTRA_JAVA_PROPERTIES="${EXTRA_JAVA_PROPERTIES} -Xmx2048m"
##   export EXTRA_JAVA_PROPERTIES
## else
##   EXTRA_JAVA_PROPERTIES="${EXTRA_JAVA_PROPERTIES} -Xmx1536m"
##   export EXTRA_JAVA_PROPERTIES
## fi
JAVA_PROPERTIES="${JAVA_PROPERTIES} ${EXTRA_JAVA_PROPERTIES}"
export JAVA_PROPERTIES

ARDIR="${WL_HOME}/server/lib"
export ARDIR

if [ "${JAVA_VENDOR}" = "Oracle" ] ; then
	CUSTOM_MEM_ARGS_64BIT="-Xms1024m -Xmx2048m -XX:PermSize=512m -XX:MaxPermSize=1024m"
	export CUSTOM_MEM_ARGS_64BIT
	CUSTOM_MEM_ARGS_32BIT="-Xms1024m -Xmx2048m -XX:PermSize=512m -XX:MaxPermSize=1024m"
	export CUSTOM_MEM_ARGS_32BIT
else
	CUSTOM_MEM_ARGS_64BIT="-Xms1024m -Xmx2048m -XX:PermSize=512m -XX:MaxPermSize=1024m -XX:ReservedCodeCacheSize=256m"
	export CUSTOM_MEM_ARGS_64BIT
	CUSTOM_MEM_ARGS_32BIT="-Xms1024m -Xmx2048m -XX:PermSize=512m -XX:MaxPermSize=1024m -XX:ReservedCodeCacheSize=256m"
	export CUSTOM_MEM_ARGS_32BIT
fi
MEM_ARGS_64BIT="${CUSTOM_MEM_ARGS_64BIT}"
export MEM_ARGS_64BIT
MEM_ARGS_32BIT="${CUSTOM_MEM_ARGS_32BIT}"
export MEM_ARGS_32BIT
if [ "${JAVA_USE_64BIT}" = "true" ] ; then
	MEM_ARGS="${MEM_ARGS_64BIT}"
	export MEM_ARGS
else
	MEM_ARGS="${MEM_ARGS_32BIT}"
	export MEM_ARGS
fi
## JAVA_PROPERTIES="${JAVA_PROPERTIES} ${MEM_ARGS}"
## export JAVA_PROPERTIES

# IF USER_MEM_ARGS the environment variable is set, use it to override ALL MEM_ARGS values

if [ "${USER_MEM_ARGS}" != "" ] ; then
	MEM_ARGS="${USER_MEM_ARGS}"
	export MEM_ARGS
fi

pushd ${LONG_DOMAIN_HOME}

# Clustering support (edit for your cluster!)

if [ "${ADMIN_URL}" = "" ] ; then
	# The then part of this block is telling us we are either starting an admin server OR we are non-clustered
	CLUSTER_PROPERTIES="-Dweblogic.management.discover=true"
	export CLUSTER_PROPERTIES
else
	CLUSTER_PROPERTIES="-Dweblogic.management.discover=false -Dweblogic.management.server=${ADMIN_URL}"
	export CLUSTER_PROPERTIES
fi

if [ "${LOG4J_CONFIG_FILE}" != "" ] ; then
	JAVA_PROPERTIES="${JAVA_PROPERTIES} -Dlog4j.configuration=file:${LOG4J_CONFIG_FILE}"
	export JAVA_PROPERTIES
fi

JAVA_PROPERTIES="${JAVA_PROPERTIES} ${CLUSTER_PROPERTIES}"
export JAVA_PROPERTIES

PRE_CLASSPATH="${SOA_ORACLE_HOME}/soa/modules/user-patch.jar${CLASSPATHSEP}${SOA_ORACLE_HOME}/soa/modules/soa-startup.jar${CLASSPATHSEP}${PRE_CLASSPATH}"
export PRE_CLASSPATH

JAVA_DEBUG=""
export JAVA_DEBUG

if [ "${debugFlag}" = "true" ] ; then
	JAVA_DEBUG="-Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,address=${DEBUG_PORT},server=y,suspend=n -Djava.compiler=NONE"
	export JAVA_DEBUG
	JAVA_OPTIONS="${JAVA_OPTIONS} ${enableHotswapFlag} -ea -da:com.bea... -da:javelin... -da:weblogic... -ea:com.bea.wli... -ea:com.bea.broker... -ea:com.bea.sbconsole..."
	export JAVA_OPTIONS
else
	JAVA_OPTIONS="${JAVA_OPTIONS} ${enableHotswapFlag} -da"
	export JAVA_OPTIONS
fi

if [ ! -d ${JAVA_HOME}/lib ] ; then
	echo "The JRE was not found in directory ${JAVA_HOME}. (JAVA_HOME)"
	echo "Please edit your environment and set the JAVA_HOME"
	echo "variable to point to the root directory of your Java installation."
	popd
	read _val
	exit
fi

if [ "${DERBY_FLAG}" = "true" ] ; then
	DATABASE_CLASSPATH="${DERBY_CLASSPATH}"
	export DATABASE_CLASSPATH
else
	DATABASE_CLASSPATH="${DERBY_CLIENT_CLASSPATH}"
	export DATABASE_CLASSPATH
fi

if [ "${POST_CLASSPATH}" != "" ] ; then
	POST_CLASSPATH="${COMMON_COMPONENTS_HOME}/modules/oracle.jrf_11.1.1/jrf.jar${CLASSPATHSEP}${POST_CLASSPATH}"
	export POST_CLASSPATH
else
	POST_CLASSPATH="${COMMON_COMPONENTS_HOME}/modules/oracle.jrf_11.1.1/jrf.jar"
	export POST_CLASSPATH
fi
if [ "${PRE_CLASSPATH}" != "" ] ; then
	PRE_CLASSPATH="${COMMON_COMPONENTS_HOME}/modules/oracle.jdbc_11.1.1/ojdbc6dms.jar${CLASSPATHSEP}${PRE_CLASSPATH}"
	export PRE_CLASSPATH
else
	PRE_CLASSPATH="${COMMON_COMPONENTS_HOME}/modules/oracle.jdbc_11.1.1/ojdbc6dms.jar"
	export PRE_CLASSPATH
fi


POST_CLASSPATH="${OIM_ORACLE_HOME}/server/lib/oim-manifest.jar${CLASSPATHSEP}${SOA_ORACLE_HOME}/soa/modules/oracle.rules_11.1.1/rulesadf.jar${CLASSPATHSEP}${COMMON_COMPONENTS_HOME}/modules/oracle.owasp_11.1.1/ESAPI-2.0-rc4.jar${CLASSPATHSEP}${COMMON_COMPONENTS_HOME}/modules/oracle.owasp_11.1.1/antisamy-bin.1.3.jar${CLASSPATHSEP}${COMMON_COMPONENTS_HOME}/modules/oracle.owasp_11.1.1/commons-configuration-1.5.jar${CLASSPATHSEP}${COMMON_COMPONENTS_HOME}/modules/oracle.owasp_11.1.1/commons-fileupload-1.2.jar${CLASSPATHSEP}${COMMON_COMPONENTS_HOME}/modules/oracle.owasp_11.1.1/commons-lang-2.3.jar${CLASSPATHSEP}${COMMON_COMPONENTS_HOME}/modules/oracle.owasp_11.1.1/nekohtml-0.9.5.jar${CLASSPATHSEP}${COMMON_COMPONENTS_HOME}/modules/oracle.owasp_11.1.1/xercesImpl-2.9.1.jar${CLASSPATHSEP}${POST_CLASSPATH}"
export POST_CLASSPATH

POST_CLASSPATH="${SOA_ORACLE_HOME}/soa/modules/oracle.soa.fabric_11.1.1/oracle.soa.fabric.jar${CLASSPATHSEP}${SOA_ORACLE_HOME}/soa/modules/oracle.soa.fabric_11.1.1/fabric-runtime-ext-wls.jar${CLASSPATHSEP}${SOA_ORACLE_HOME}/soa/modules/oracle.soa.adapter_11.1.1/oracle.soa.adapter.jar${CLASSPATHSEP}${SOA_ORACLE_HOME}/soa/modules/oracle.soa.b2b_11.1.1/oracle.soa.b2b.jar${CLASSPATHSEP}${POST_CLASSPATH}"
export POST_CLASSPATH

POST_CLASSPATH="${DOMAIN_HOME}/config/soa-infra${CLASSPATHSEP}${SOA_ORACLE_HOME}/soa/modules/fabric-url-handler_11.1.1.jar${CLASSPATHSEP}${SOA_ORACLE_HOME}/soa/modules/quartz-all-1.6.5.jar${CLASSPATHSEP}${POST_CLASSPATH}"
export POST_CLASSPATH

POST_CLASSPATH="${COMMON_COMPONENTS_HOME}/modules/oracle.xdk_11.1.0/xsu12.jar${CLASSPATHSEP}${BEA_HOME}/modules/features/weblogic.server.modules.xquery_10.3.1.0.jar${CLASSPATHSEP}${SOA_ORACLE_HOME}/soa/modules/db2jcc4.jar${CLASSPATHSEP}${POST_CLASSPATH}"
export POST_CLASSPATH

POST_CLASSPATH="${COMMON_COMPONENTS_HOME}/soa/modules/commons-cli-1.1.jar${CLASSPATHSEP}${COMMON_COMPONENTS_HOME}/soa/modules/oracle.soa.mgmt_11.1.1/soa-infra-mgmt.jar${CLASSPATHSEP}${POST_CLASSPATH}"
export POST_CLASSPATH

POST_CLASSPATH="${UMS_ORACLE_HOME}/communications/modules/usermessaging-config_11.1.1.jar${CLASSPATHSEP}${POST_CLASSPATH}"
export POST_CLASSPATH

POST_CLASSPATH="/opt/fmw/products/identity/soa/soa/modules/oracle.soa.common.adapters_11.1.1/oracle.soa.common.adapters.jar${CLASSPATHSEP}${POST_CLASSPATH}"
export POST_CLASSPATH

if [ "${DATABASE_CLASSPATH}" != "" ] ; then
	if [ "${POST_CLASSPATH}" != "" ] ; then
		POST_CLASSPATH="${POST_CLASSPATH}${CLASSPATHSEP}${DATABASE_CLASSPATH}"
		export POST_CLASSPATH
	else
		POST_CLASSPATH="${DATABASE_CLASSPATH}"
		export POST_CLASSPATH
	fi
fi

if [ "${ARDIR}" != "" ] ; then
	if [ "${POST_CLASSPATH}" != "" ] ; then
		POST_CLASSPATH="${POST_CLASSPATH}${CLASSPATHSEP}${ARDIR}/xqrl.jar"
		export POST_CLASSPATH
	else
		POST_CLASSPATH="${ARDIR}/xqrl.jar"
		export POST_CLASSPATH
	fi
fi

# PROFILING SUPPORT

JAVA_PROFILE=""
export JAVA_PROFILE

SERVER_CLASS="weblogic.Server"
export SERVER_CLASS

JAVA_PROPERTIES="${JAVA_PROPERTIES} ${WLP_JAVA_PROPERTIES}"
export JAVA_PROPERTIES

JAVA_OPTIONS="${JAVA_OPTIONS} ${JAVA_PROPERTIES} -Dwlw.iterativeDev=${iterativeDevFlag} -Dwlw.testConsole=${testConsoleFlag} -Dwlw.logErrorsToConsole=${logErrorsToConsoleFlag}"
export JAVA_OPTIONS

if [ "${PRODUCTION_MODE}" = "true" ] ; then
	JAVA_OPTIONS=" -Dweblogic.ProductionModeEnabled=true ${JAVA_OPTIONS}"
	export JAVA_OPTIONS
fi

# -- Setup properties so that we can save stdout and stderr to files

if [ "${WLS_STDOUT_LOG}" != "" ] ; then
	echo "Logging WLS stdout to ${WLS_STDOUT_LOG}"
	JAVA_OPTIONS="${JAVA_OPTIONS} -Dweblogic.Stdout=${WLS_STDOUT_LOG}"
	export JAVA_OPTIONS
fi

if [ "${WLS_STDERR_LOG}" != "" ] ; then
	echo "Logging WLS stderr to ${WLS_STDERR_LOG}"
	JAVA_OPTIONS="${JAVA_OPTIONS} -Dweblogic.Stderr=${WLS_STDERR_LOG}"
	export JAVA_OPTIONS
fi

# ADD EXTENSIONS TO CLASSPATHS

if [ "${EXT_PRE_CLASSPATH}" != "" ] ; then
	if [ "${PRE_CLASSPATH}" != "" ] ; then
		PRE_CLASSPATH="${EXT_PRE_CLASSPATH}${CLASSPATHSEP}${PRE_CLASSPATH}"
		export PRE_CLASSPATH
	else
		PRE_CLASSPATH="${EXT_PRE_CLASSPATH}"
		export PRE_CLASSPATH
	fi
fi

if [ "${EXT_POST_CLASSPATH}" != "" ] ; then
	if [ "${POST_CLASSPATH}" != "" ] ; then
		POST_CLASSPATH="${POST_CLASSPATH}${CLASSPATHSEP}${EXT_POST_CLASSPATH}"
		export POST_CLASSPATH
	else
		POST_CLASSPATH="${EXT_POST_CLASSPATH}"
		export POST_CLASSPATH
	fi
fi

if [ "${WEBLOGIC_EXTENSION_DIRS}" != "" ] ; then
	JAVA_OPTIONS="${JAVA_OPTIONS} -Dweblogic.ext.dirs=${WEBLOGIC_EXTENSION_DIRS}"
	export JAVA_OPTIONS
fi

JAVA_OPTIONS="${JAVA_OPTIONS}"
export JAVA_OPTIONS

# SET THE CLASSPATH

if [ "${WLP_POST_CLASSPATH}" != "" ] ; then
	if [ "${CLASSPATH}" != "" ] ; then
		CLASSPATH="${WLP_POST_CLASSPATH}${CLASSPATHSEP}${CLASSPATH}"
		export CLASSPATH
	else
		CLASSPATH="${WLP_POST_CLASSPATH}"
		export CLASSPATH
	fi
fi

if [ "${POST_CLASSPATH}" != "" ] ; then
	if [ "${CLASSPATH}" != "" ] ; then
		CLASSPATH="${POST_CLASSPATH}${CLASSPATHSEP}${CLASSPATH}"
		export CLASSPATH
	else
		CLASSPATH="${POST_CLASSPATH}"
		export CLASSPATH
	fi
fi

if [ "${WEBLOGIC_CLASSPATH}" != "" ] ; then
	if [ "${CLASSPATH}" != "" ] ; then
		CLASSPATH="${WEBLOGIC_CLASSPATH}${CLASSPATHSEP}${CLASSPATH}"
		export CLASSPATH
	else
		CLASSPATH="${WEBLOGIC_CLASSPATH}"
		export CLASSPATH
	fi
fi

if [ "${PRE_CLASSPATH}" != "" ] ; then
	CLASSPATH="${PRE_CLASSPATH}${CLASSPATHSEP}${CLASSPATH}"
	export CLASSPATH
fi

if [ "${JAVA_VENDOR}" != "BEA" ] ; then
	JAVA_VM="${JAVA_VM} ${JAVA_DEBUG} ${JAVA_PROFILE}"
	export JAVA_VM
else
	JAVA_VM="${JAVA_VM} ${JAVA_DEBUG} ${JAVA_PROFILE}"
	export JAVA_VM
fi

