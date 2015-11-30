# identity analytics functions
#

# create the final property file for domain creation ------------------
# exchanging placeholders with variables from iam.config file.
# however, template files in user-config are can be used for
# configuration, as long the placeholders (see below) are not touched.
#
oia_dom_prop()
{
  local _propfile_template=${DEPLOYER}/user-config/oia/createdom-${1}-template.prop
  local _propfile=/tmp/createdom-${1}.prop
  cp -f ${_propfile_template} ${_propfile}
  
      _iam_top=$(echo ${iam_top}     | sed -e 's/[\/&]/\\&/g')
  _iam_hostenv=$(echo ${iam_hostenv} | sed -e 's/[\/&]/\\&/g')
  
  sed -i -e "s/__DOMAIN_NAME__/${iam_domain_oia}/" \
         -e "s/__HOSTENV__/${_iam_hostenv}/" \
         -e "s/__IAM_TOP__/${_iam_top}/" \
         -e "s/__IAM_OIA_HOST1__/${IDMPROV_OIA_HOST}/" \
         -e "s/__IAM_OIA_HOST2__/${IDMPROV_SECOND_OIA_HOST}/" \
         -e "s/__IAM_OIA_DBUSER__/${iam_oia_dbuser}/" \
         -e "s/__IAM_OIA_DBPWD__/${iam_oia_schema_pass}/" \
         -e "s/__DBS_HOSTNAME__/${dbs_dbhost}/" \
         -e "s/__DBS_PORT__/${dbs_port}/" \
         -e "s/__IAM_SERVICENAME__/${iam_servicename}/" \
         ${_propfile}
}

# unpack OIA instance -------------------------------------------------
# creates directories
#   iam_top/config/analytics
#   iam_top/products/analytics
# expodes archive of webapp rbacx
#
oia_explode()
{
  mkdir -p ${iam_rbacx_home} ${iam_analytics_home}

  # unzip in config, used for config and deployment
  unzip -q ${s_oia_archive} -d ${RBACX_HOME}
  # keep orginal verson in products
  unzip -q ${s_oia_archive} -d ${iam_analytics_home}

  mv ${RBACX_HOME}/sample/* ${RBACX_HOME}
  rm -Rf ${RBACX_HOME}/sample

  mkdir ${RBACX_HOME}/oia
  cd ${RBACX_HOME}/oia
  jar -xf ../rbacx.war
  rm -f ../rbacx.war

  # copy libraries needed by OIA
  cp ${s_oia_ext}/*.jar ${RBACX_HOME}/oia/WEB-INF/lib/

  # remove conflicting libs
  for lib in jrf-api.jar \
             stax-1.2.0.jar \
             stax-api-1.0.1.jar \
             tools.jar \
             ucp.jar \
             xfire-all-1.2.5.jar ; do
    rm ${RBACX_HOME}/oia/WEB-INF/lib/${lib}
  done

  echo "Done unpacking OIA"
  echo
}

# create weblogic domain for OIA --------------------------------------
# with:
#   nodemanager, boot properties, datasources, managed server
# 
oia_wlst_exec()
{
  # create domain or deploy OIA application
  local _operation=${1}

  case ${_operation} in
    wlstdom)
      local _start_wlst=${DEPLOYER}/lib/weblogic/wlst/create_oia_domain.py
      ;;
    oia)
      local _start_wlst=${DEPLOYER}/lib/weblogic/wlst/deploy_oia_app.py
      ;;
    *)
      exit $ERROR_FILE_NOT_FOUND
      ;;
  esac

  local _wls_dom_template=${WL_HOME}/common/templates/domains/wls.jar
  local _user_prop=/tmp/createdom-${2}.prop

  JAVA_OPTIONS="${JAVA_OPTIONS} -Xmx2048m -Xms2048m -Djava.net.preferIPv4Stack=true"
  JVM_ARGS="-Dprod.props.file='${WL_HOME}'/.product.properties \
    -Dweblogic.management.confirmKeyfileCreation=true \
     ${CONFIG_JVM_ARGS}"
  source ${WL_HOME}/server/bin/setWLSEnv.sh
  set -x
  eval '"${JAVA_HOME}/bin/java"' ${JVM_ARGS} weblogic.WLST \
    -skipWLSModuleScanning ${_start_wlst} \
                           ${_wls_dom_template} \
                           ${oiaWlUser} \
                           ${oiaWlPwd} \
                           ${_user_prop}
  set +x
}

# packing and unpacking of domain dir  --------------------------------
#
oia_rdeploy()
{
  _action=${1}

  pack=$WL_HOME/common/bin/pack.sh
  unpack=$WL_HOME/common/bin/unpack.sh
  template_loc=${IL_APP_CONFIG}
  template_name=${iam_domain_oia}

  case ${_action} in
    pack)
      ${pack} -managed=true \
        -domain=${DOMAIN_HOME} \
        -template=${template_loc}/${template_name}.jar \
        -template_name=${template_name}
      ;;
    unpack)
      ${unpack} -domain=${DOMAIN_HOME} \
                -app_dir=${DOMAIN_HOME} \
                -template=${template_loc}/${template_name}.jar \
      ;;
    *)
      exit $ERROR_FILE_NOT_FOUND
      ;;
  esac
}

# configure the OIA weapp config files --------------------------------
#   param1: single or cluster        
#
oia_appconfig()
{
  local _c _prod _topo

     _topo=${1}
        _c=${RBACX_HOME}

  # this variable will be used in sed command and must be escaped before
  _iam_log=$(echo ${iam_log}            | sed -e 's/[\/&]/\\&/g')
     _prod=$(echo ${iam_analytics_home} | sed -e 's/[\/&]/\\&/g')

  # check if already executed
  if ! grep -q '$RBACX_HOME' ${_c}/conf/iam.properties ; then
    echo "OIA appconfig already done - skipping"
    return 0
  fi

  echo " * conf/iam.properties"
  echo "     replacing the variable \$RBACX_HOME with its value"

  sed -i -e "s/\$RBACX_HOME/${_prod}/g" ${_c}/conf/iam.properties

  echo
  echo " * conf/oimjdbc.properties"
  echo "     setting OIM database connection properties"
  echo "     encrypting OIM jdbc password"

  sed -i -e "s/oimdbuser/${iam_oim_prefix}_OIM/g" \
         -e "s/\$SERVER_NAME:\$PORT:oim/${dbs_dbhost}:${dbs_port}\/${iam_servicename}/g" \
         ${_c}/conf/oimjdbc.properties
  echo ""                                         >> ${_c}/conf/oimjdbc.properties
  echo "oim.jdbc.password=${iam_oim_schema_pass}" >> ${_c}/conf/oimjdbc.properties

  java -jar ${_c}/oia/WEB-INF/lib/vaau-commons-crypt.jar \
    -encryptProperty \
    -cipherKeyProperties ${_c}/conf/cipherKey.properties \
    -propertyFile ${_c}/conf/oimjdbc.properties \
    -propertyName oim.jdbc.password

  echo
  echo " * oia/WEB-INF/application-context.xml"
  echo "     replacing cluster name"

  sed -i -e "339s/Prod-1-Cluster/${iam_domain_oia}-Cluster/g" \
         ${_c}/oia/WEB-INF/application-context.xml

  if [ ${_topo} == "cluster" ] ; then
    
    echo "     CLUSTER: list of service IP addresses"
    sed -i -e '345s/false/true/g' \
           -e '345 a \
              \        <constructor-arg index="1" value="__MY_CLUSTER_IPS__"/>\
              ' ${_c}/oia/WEB-INF/application-context.xml
    sed -i -e "s/__MY_CLUSTER_IPS__/${IDMPROV_OIA_CLUSTERIP}/g" \
                ${_c}/oia/WEB-INF/application-context.xml
  fi

  echo
  echo " * oia/WEB-INF/classes/jasperreports.properties"
  echo "     adding jasper reports classpath"

  echo "net.sf.jasperreports.compiler.classpath=${_c}/oia/WEB-INF/lib/jasperreports-2.0.5-javaflow.jar" \
    >> ${_c}/oia/WEB-INF/classes/jasperreports.properties
  
  echo
  echo " * oia/WEB-INF/classes/oscache.properties"
  echo "     adding cluster cache config, multicast"

  echo "cache.event.listeners=com.opensymphony.oscache.plugins.clustersupport.JavaGroupsBroadcastingListener,com.opensymphony.oscache.extra.CacheMapAccessEventListenerImpl" >> ${_c}/oia/WEB-INF/classes/oscache.properties
  echo "cache.cluster.multicast.ip=231.12.21.100" >> ${_c}/oia/WEB-INF/classes/oscache.properties
  
  echo
  echo " * oia/WEB-INF/conf-context.xml"
  echo "     removing line with jdbc-config file, we use datasource"

  sed -i '12 d' ${_c}/oia/WEB-INF/conf-context.xml

  echo
  echo " * oia/WEB-INF/dataaccess-context.xml"
  echo "     replacing jdbc driver with weblogic data source"

  sed -i -e '59s/<bean id/<!-- bean id/g' \
         -e '79s/<\/bean>/<\/bean -->/g' \
         -e '80 a \
            \    <bean id="dataSource" class="org.springframework.jndi.JndiObjectFactoryBean">\
            \        <property name="jndiName" value="jdbc/OIADataSource" />\
            \    </bean>\
            ' ${_c}/oia/WEB-INF/dataaccess-context.xml

  echo
  echo " * oia/WEB-INF/etl-context.xml"
  echo "     activating ETLManager block"

  sed -i -e '6s/<!--/</g' \
         -e '16s/<\/bean-->/<\/bean>/g' \
         ${_c}/oia/WEB-INF/etl-context.xml

  echo
  echo " * oia/WEB-INF/iam-context.xml"
  echo "     referencing activated ETLManager"

  sed -i -e '269s/<!--/</g' \
         -e '269s/-->/>/g' \
         ${_c}/oia/WEB-INF/iam-context.xml

  echo
  echo " * oia/WEB-INF/log4j.properties"
  echo "     log directory"

  sed -i -e "s/log4j\.appender\.file\.file=logs\/oia.log/log4j\.appender\.file\.file=${_iam_log}\/${iam_domain_oia}\/oia.log/g" \
         ${_c}/oia/WEB-INF/log4j.properties

  echo
  echo " * oia/WEB-INF/scheduling-context.xml"
  echo "     referencing activated ETLManager"

  sed -i -e '145,146s/<prop/<!-- prop/g' \
         -e '145,146s/prop>/prop -->/g' \
         -e '146 a \
            \                        <prop key="org.quartz.jobStore.driverDelegateClass">org.quartz.impl.jdbcjobstore.oracle.weblogic.WebLogicOracleDelegate</prop>\
            \                        <prop key="org.quartz.jobStore.selectWithLockSQL">SELECT * FROM {0}LOCKS WHERE LOCK_NAME = ? FOR UPDATE</prop>\
            ' ${_c}/oia/WEB-INF/scheduling-context.xml

  echo
  echo " * oia/WEB-INF/weblogic.xml"
  echo "     creating new with content"

  cat > ${_c}/oia/WEB-INF/weblogic.xml <<-EOS
	<?xml version="1.0" encoding="UTF-8"?>
	<weblogic-web-app xmlns="http://xmlns.oracle.com/weblogic/weblogic-web-app">
	  <container-descriptor>
	    <prefer-application-packages>
	      <package-name>javax.wsdl.*</package-name>
	      <package-name>com.ibm.wsdl.*</package-name>
	      <package-name>org.springframework.*</package-name>
	      <package-name>org.aspectj.*</package-name>
	      <package-name>org.jdom.*</package-name>
	      <package-name>org.codehaus.xfire.*</package-name>
	      <package-name>org.jaxen.*</package-name>
	      <package-name>org.apache.bcel.*</package-name>
	      <package-name>org.apache.commons.*</package-name>
	      <package-name>com.ctc.wstx.*</package-name>
	      <package-name>org.codehaus.stax2.*</package-name>
	      <package-name>org.openspml.*</package-name>
	      <package-name>org.quartz.*</package-name>
	    </prefer-application-packages>
	  </container-descriptor>
	</weblogic-web-app>
EOS

  echo
  echo "app config completed"
}

# OIM-OIA integration steps -------------------------------------------
#
oia_oim_integrate()
{
  local _dest=${RBACX_HOME}/oia/WEB-INF/lib

  # copy oim server libs
  for lib in  xlCrypto.jar \
              wlXLSecurityProviders.jar \
              xlAuthentication.jar \
              xlLogger.jar ; do
    cp ${OIM_MW_HOME}/iam/server/lib/${lib} ${_dest}/
  done

  # copy design console libs
  for lib in  xlAPI.jar \
              xlCache.jar \
              xlDataObjectBeans.jar \
              xlDataObjects.jar \
              xlUtils.jar \
              xlVO.jar \
              oimclient.jar \
              iam-platform-utils.jar ; do
    cp ${OIM_MW_HOME}/iam/designconsole/lib/${lib} ${_dest}/
  done

  cp ${OIM_MW_HOME}/oracle_common/modules/oracle.jrf_11.1.1/jrf-api.jar \
     ${OIM_WL_HOME}/server/lib/wlfullclient.jar \
     ${_dest}/

  # copy designconsole config to OIA
  mkdir -p ${RBACX_HOME}/xellerate
  cp -R ${OIM_MW_HOME}/iam/designconsole/config ${RBACX_HOME}/xellerate/

  # patching workflow configurations
  oia_config_workflows ${RBACX_HOME}/conf/workflows
}

# OIM-OIA integration workflow patching -----------------------------------
# param 1: directory path of workflow definitions
#
oia_config_workflows()
{
  sed -i '125 a \
    \                <function name="exportIAMPolicyFunction" type="spring">\
    \                      <arg name="bean.name">exportIAMPolicyFunction</arg>\
    \                      <arg name="OIMServer"/>\
    \                </function>\
    ' ${1}/policy-creation-workflow.xml \
      ${1}/policy-modification-workflow.xml

  sed -i '245 a \
    \                <function name="exportIAMRoleFunction" type="spring"> \
    \                      <arg name="bean.name">exportIAMRoleFunction</arg> \
    \                      <arg name="OIMServer"/> \
    \                </function> \
    ' ${1}/role-creation-workflow.xml

  sed -i '279 a \
    \                <function name="exportIAMRoleFunction" type="spring"> \
    \                      <arg name="bean.name">exportIAMRoleFunction</arg> \
    \                      <arg name="OIMServer"/> \
    \                </function> \
    ' ${1}/role-modification-workflow.xml
}

# configure OIA weblogic domain -------------------------------------
# new file with custom env will be sourced by setDomainEnv.sh
#
oia_domconfig()
{
  local _s _d
  _s=${DEPLOYER}/lib/templates/analytics
  _d=${DOMAIN_HOME}/bin

  # custom domain env file, will be sourced
  cp ${_s}/setCustDomainEnv.sh ${_d}/
  chmod 0644 ${_d}/setCustDomainEnv.sh

  # patch will source the custom env file
  patch ${_d}/setDomainEnv.sh < ${_s}/setDomainEnv.patch
}

