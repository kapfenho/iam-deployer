# identity analytics functions
#

oia_dom_prop()
{
  local _propfile_template=${DEPLOYER}/user-config/oia/createdom-${1}-template.prop
  local _propfile=/tmp/createdom-${1}.prop
  cp ${_propfile_template} ${_propfile}
  
      _iam_top=$(echo ${iam_top}     | sed -e 's/[\/&]/\\&/g')
  _iam_hostenv=$(echo ${iam_hostenv} | sed -e 's/[\/&]/\\&/g')
  
  sed -i "s/__DOMAIN_NAME__/${iam_domain_oia}/"         ${_propfile}
  sed -i "s/__HOSTENV__/${_iam_hostenv}/"               ${_propfile}
  sed -i "s/__IAM_TOP__/${_iam_top}/"                   ${_propfile}
  sed -i "s/__IAM_OIA_HOST1__/${iam_oia_host1}/"        ${_propfile}
  sed -i "s/__IAM_OIA_HOST2__/${iam_oia_host2}/"        ${_propfile}
  sed -i "s/__IAM_OIA_DBUSER__/${iam_oia_dbuser}/"      ${_propfile}
  sed -i "s/__IAM_OIA_DBPWD__/${iam_oia_schema_pass}/"  ${_propfile}
  sed -i "s/__DBS_HOSTNAME__/${dbs_dbhost}/"            ${_propfile}
  sed -i "s/__IAM_SERVICENAME__/${iam_servicename}/"    ${_propfile}
}

# create weblogic domain for OIA including:
# nodemanager, boot properties, datasources, managed server
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

oia_rdeploy()
{
  _action=${1}

  pack=$WL_HOME/common/bin/pack.sh
  unpack=$WL_HOME/common/bin/unpack.sh
  template_loc=/l/ora/products
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

# unpack OIA instance
#
oia_explode()
{
  # conflicting libs
  c_libs[0]=jrf-api.jar
  c_libs[1]=stax-1.2.0.jar
  c_libs[2]=stax-api-1.0.1.jar
  c_libs[3]=tools.jar
  c_libs[4]=ucp.jar
  c_libs[5]=xfire-all-1.2.5.jar


  if [ -a "${MW_HOME}" ]
  then
    unzip -q ${s_oia}/app-archive/${oia_name} -d ${RBACX_HOME}

    mv ${RBACX_HOME}/sample/* ${RBACX_HOME}
    rm -rf ${RBACX_HOME}/sample

    mkdir ${RBACX_HOME}/{_rbacx_orig,rbacx}
    cp ${RBACX_HOME}/rbacx.war ${RBACX_HOME}/_rbacx_orig
    cd ${RBACX_HOME}/rbacx ; jar -xf ../rbacx.war ; rm ../rbacx.war

    # copy libraries needed by OIA
    cp ${s_oia}/ext/*.jar ${RBACX_HOME}/rbacx/WEB-INF/lib/

    # Remove conflicting libs
    #
    for lib in ${c_libs[@]}; do
      rm ${RBACX_HOME}/rbacx/WEB-INF/lib/${lib}
    done
    echo "Done unpacking OIA."
    echo ""
  else
    log "Analytics: ${MW_HOME} does not exist. Please install WLS first."
  fi
}

# Apply rbacx configurations by patching the OOTB rbacx instance
# with the changes from a preconfigured rbacx instance
# 
# deployment type:
# 0 - single instance
# 1 - clustered
#
oia_appconfig()
{
  deployment_type=${1}

  if type dos2unix >/dev/null 2>&1 ; then
    echo "Tool dos2unix found - converting..."
    for d in conf conf/workflows rbacx/WEB-INF ; do
      echo "Tool dos2unix found - converting in $d"
      find ${RBACX_HOME}/${d} -maxdepth 1 -type f -exec dos2unix {} \;
    done
  fi

  cd ${RBACX_HOME}
  if [ "${deployment_type}" == "single" ]
  then
    echo "Patching RBACX_HOME for single instance deployment.."
    patch -p1 < ${DEPLOYER}/user-config/oia/rbacx_single.patch
  elif [ "${deployment_type}" == "cluster" ]
  then
    echo "Patching RBACX_HOME for cluster deployment.."
    patch -R -p1 < ${DEPLOYER}/user-config/oia/rbacx_cluster.patch
  fi
  echo "Done patching RBACX_HOME."
  echo ""

  # Encrypt OIMJDBC Password
  java -jar ${RBACX_HOME}/rbacx/WEB-INF/lib/vaau-commons-crypt.jar \
    -encryptProperty \
    -cipherKeyProperties ${RBACX_HOME}/conf/cipherKey.properties \
    -propertyFile ${RBACX_HOME}/conf/oimjdbc.properties \
    -propertyName oim.jdbc.password
  echo "Encrypted OIM JDBC Password"
}

# appconfig new version ---------------------------------------
#
oia_appconfig2()
{
  local _c=${RBACX_HOME}
  local _prod=${iam_top}/products/analytics

  # conf/iam.properties
  sed -i -e s/\$RBACX_HOME/${_prod}/g  ${_c}/conf/iam.properties

  # conf/oimjdbc.properties
  sed -i -e s/oimdbuser/${iam_oim_prefix}_OIM/g \
         -e s/oimpassword/${iam_oim_schema_pass}/g \
         -e s/\$SERVER_NAME:\$PORT:oim/${dbs_dbhost}:${dbs_port}\/${dbs_port}/g \
         ${_c}/conf/oimjdbc.properties

  # rbacx/WEB-INF/application-context.xml
  sed -i -e s/Prod-1-Cluster/VWFSCluster/g \
         ${_c}/rbacx/WEB-INF/application-context.xml


# rbacx/WEB-INF/classes/jasperreports.properties
# ----------------------------------------------
# add one line:
#  net.sf.jasperreports.export.xls.max.rows.per.sheet=65534
# +net.sf.jasperreports.compiler.classpath=/l/ora/products/analytics/oia/rbacx/WEB-INF/lib/jasperreports-2.0.5-javaflow.jar
# 
# rbacx/WEB-INF/classes/oscache.properties
# ----------------------------------------
# sed -i -e s/#cache\.event\.listeners/cache\.event\.listeners/ \
#        -e s/#cache\.cluster\.multicast\.ip=.*$/cache\.cluster\.multicast\.ip=231.12.21.100/ \
#        oimjdbc.properties
# 
# -#cache.event.listeners=com.opensymphony.oscache.plugins.clustersupport.JavaGroupsBroadcastingListener,com.opensymphony.oscache.extra.CacheMapAccessEventListenerImpl
# +cache.event.listeners=com.opensymphony.oscache.plugins.clustersupport.JavaGroupsBroadcastingListener,com.opensymphony.oscache.extra.CacheMapAccessEventListenerImpl
# -#cache.cluster.multicast.ip=231.12.21.100
# +cache.cluster.multicast.ip=231.12.21.100
# 
# rbacx/WEB-INF/conf-context.xml 
# ------------------------------
# ${RBACX_HOME}
# 
# -                <value>file:${RBACX_HOME}/conf/jdbc.properties</value>
# +                <!--value>file:/l/ora/products/analytics/oia/conf/jdbc.properties</value-->
# 
# 
# rbacx/WEB-INF/dataaccess-context.xml
# ------------------------------------
# Replace Datasource definition by JNDI-Name to pre configured Datasource
# 
# -    <bean id="dataSource" parent="abstractDataSource">
# +    <!--bean id="dataSource" parent="abstractDataSource">
#          <description>Default datasource that uses Oracle UCP as a pool implementation</description>
#          <property name="connectionFactoryClassName" value="${jdbc.driverClassName}"/>
#          <property name="URL" value="${jdbc.url}"/>
# @@ -76,6 +76,9 @@
#                  <property name="ignoreResourceNotFound" value="true"/>
#              </bean>
#          </property>
# +    </bean-->
# +    <bean id="dataSource" class="org.springframework.jndi.JndiObjectFactoryBean">
# +          <property name="jndiName" value="jdbc/OIADataSource" /> 
#      </bean>
# 

}

# OIM-OIA integration steps
#
oia_oim_integrate()
{
  # oim server libs
  oim_lib[0]=xlCrypto.jar
  oim_lib[1]=wlXLSecurityProviders.jar
  oim_lib[2]=xlAuthentication.jar
  oim_lib[3]=xlLogger.jar

  # design console libs
  dc_lib[0]=xlAPI.jar
  dc_lib[1]=xlCache.jar
  dc_lib[2]=xlDataObjectBeans.jar
  dc_lib[3]=xlDataObjects.jar
  dc_lib[4]=xlUtils.jar
  dc_lib[5]=xlVO.jar
  dc_lib[6]=oimclient.jar
  dc_lib[7]=iam-platform-utils.jar

  local _oia_lib=${RBACX_HOME}/rbacx/WEB-INF/lib

  # copy OIM designconsole and server libraries to OIA
  for lib in ${oim_lib[@]}; do
    cp ${OIM_MW_HOME}/iam/server/lib/${lib} ${_oia_lib}
  done

  for lib in ${dc_lib[@]}; do
    cp ${OIM_MW_HOME}/iam/designconsole/lib/${lib} ${_oia_lib}
  done

  cp ${OIM_MW_HOME}/oracle_common/modules/oracle.jrf_11.1.1/jrf-api.jar ${_oia_lib}

  cp ${OIM_WL_HOME}/server/lib/wlfullclient.jar ${_oia_lib}

  # copy designconsole config to OIA
  mkdir -p ${RBACX_HOME}/xellerate
  cp -R ${OIM_MW_HOME}/iam/designconsole/config ${RBACX_HOME}/xellerate

  # patching workflow configurations
  cd ${RBACX_HOME}
  patch -p0 --silent < ${DEPLOYER}/user-config/oia/rbacx_workflow.patch
}

# configure OIA weblogic domain
# 
oia_domconfig()
{
  # setDomainEnv.sh patch
  cd ${DOMAIN_HOME}/bin
  patch -p0 < ${DEPLOYER}/user-config/oia/oia_setdomenv.patch
}
