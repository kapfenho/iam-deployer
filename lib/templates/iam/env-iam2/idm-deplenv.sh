# set deployment environment
#
. ${HOME}/.env/common.sh
. ${HOME}/.env/idm.sh
. ${WL_HOME}/server/bin/setWLSEnv.sh
deploy() {
  java weblogic.WLST -loadProperties ~/.wlst/${1}.prop ${HOME}/lib/deploy.py
}

