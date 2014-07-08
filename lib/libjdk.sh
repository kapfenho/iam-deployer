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
#+ system device will be used for random generation. Don't use in 
#+ production if you wanna be super secure (placebo warning - I am 
#+ sure there are enough other ways to break into the system).
#
jdk_patch_config() {
  sed -i.orig 's/securerandom\.source=file:\/dev\/urandom/securerandom\.source=file:\/dev\/\.\/urandom/g' \
    $1/jre/lib/security/java.security
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

    [ -n ${6} ] && jdk_create_softlink
    [ "${4}" == "true" ] && jdk_patch_config ${jdir}
    jdk_deploy_cacerts ${5}

    log "jdk_deploy" "done"

  else
    log "jdk_deploy" "skipped"
  fi
}

