#  JDK deployment functions
# 
_LIBDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#  create link "current" to this release of the jdk, this
#+ helps keeping a stable jdk-path in other config files
#
jdk_create_softlink() {
  # if soft link current exists delete it
  if [ -a ${dbs_java_current} ]; then
    rm -Rf ${dbs_java_current}
  fi
  # ln -s ${dbs_java_home}/${img_java_name} ${dbs_java_current}
  ln -s ${jdir} ${dbs_java_current}
}

#  patch the configuration of the new jdk, currrently the urandom
#+ system device will be used for random generation. 
#+ param1: path of JDK to patch
#
jdk_patch_config() {
  local fp=${1}/jre/lib/security/java.security
  if [ -f ${fp} ] ; then
    # we check if this one is already patched
    if ! grep -q -E -e '\/dev\/\.\/urandom' ${fp} ; then
      # found unpatched file
      if sed -i.orig 's/securerandom\.source=file:\/dev\/urandom/securerandom\.source=file:\/dev\/\.\/urandom/g' ${fp} ; then
        log "JDK performance patch urandom done for ${fp}"
      else
        error "Error while patching ${fp}"
      fi
    else
      log "JDK performance patch already done for ${fp}"
    fi
  fi
}

#  configuring the cacerts within the jdk.
#+ parameter:
#+   no:      keep default cacerts
#+   add:     add custom to default ones
#+   replace: replace default cacerts with custom
#
jdk_deploy_cacerts() {
  # java_dirname=${dbs_java_home}/${img_java_name}
  case $1 in
    replace)
      # replace with custom cacerts (more secure)
      mv ${jdir}/lib/security/cacerts ${jdir}/jre/lib/security/cacerts.orig
      cp ${s_certs}/cacerts-jdk-drei/cacerts ${jdir}/jre/lib/security/
      ;;
    add)
      # add custom cacerts to default jdk ones (less secure)
      cp ${jdir}/lib/security/cacerts ${jdir}/jre/lib/security/cacerts.orig
      ( JAVA_HOME=${jdir} \
        keytool -importkeystore -noprompt \
                -srckeystore ${s_certs}/cacerts-drei/cacerts \
                -srcstorepass ${s_certs_storepass} \
                -destkeystore ${jdir}/jre/lib/security/cacerts \
                -deststorepass changeit ) 
      ;;
    *)
      ;;
  esac
}

#  deploy jdk, parameters:
#+ 1:  java_home, parent of new jdk dir
#+ 2:  dir_name, name of new jdk dir
#+ 3:  image zip file
#+ 4:  urandom: true or false
#+ 5:  cacerts: replace, add, false
#+ 6:  current link name: link name or empty

jdk_deploy() {
  log "jdk_deploy" "start"

  jdir=${1}/${2}

  if ! [ -d ${jdir} ] ; then
    log "jdk_deploy" "deploying to ${jdir}..."

    [ -a ${1} ] || mkdir -p ${1}
    unzip -nq ${3} -d ${1}

    [ -n "${6}" ] && jdk_create_softlink
    [ "${4}" == "true" ] && jdk_patch_config ${jdir}
    jdk_deploy_cacerts ${5}

    log "jdk_deploy" "done"

  else
    log "jdk_deploy" "skipped"
  fi
}

#  JDK7 upgrade - part 1 --------------------------------------------
#  this can be done while original processes are still running
#
jdk_install7()
{
  local _oh=${1}
 
  log "Upgrading to JDK7 - part 1"
  local dest=${iam_top}/products/${_oh}
  # when oracle_home dir does not exists: skip
  [ -a ${dest} ] || exit
  # when new jdk already exists: skip
  if [ -a ${dest}/jdk/current ] ; then
    warning "Skipping - found JDK in ${dest}"
    exit
  fi
  log "upgrading JDK in product dir ${dest}"
  mkdir -p ${dest}/jdk
  tar xzf ${s_jdk} -C ${dest}/jdk
  log "Creating soft link..."
  ln -s ${dest}/jdk/${jdkname} ${dest}/jdk/current
  log "Patching JDK...."
  jdk_patch_config ${dest}/jdk/${jdkname}
  log "Finished JDK upgrade part 1 in ${dest}"
}

#  JDK7 upgrade - part 2 --------------------------------------------
#  this shall be executed when procs are down
#
jdk_move6()
{
  local _oh=${1}

  log "Upgrading to JDK7 - part 2"
  local dest=${iam_top}/products/${_oh}

  # move jdk6
  # skip if already done
  [ -h ${dest}/jdk6 ] && return
  log "We will move and replace JDK6 in ${dest}"
  mv ${dest}/jdk6 ${dest}/jdk/
  ln -s ${dest}/jdk/${jdkname} ${dest}/jdk6
  log "JDK6 moved - done"
}


