#  common installation functions

#  standard logging
#
log() {
  echo "${1}: ${2}"
}

exit_on_not_root() {
  if [ $UID != 0 ] ; then
    echo "ERROR: please execute as system admin!"
  fi
}

#  create a backup of file, format "<oldname>.20140621", optional adding ~
#  parameter is original file
#
backup() { 
  for file in "$@"; do
    local new=${file}.$(date '+%Y%m%d')
    while [ -f $new ]; do
        new+="~";
    done;
    cp -ip "$file" "$new";
  done
}

create_user_profile() {
  log "create_user_profile" "start"
  [ -a ${HOME}/.env ] || mkdir -p ${HOME}/.env
  cp ${_DIR}/lib/templates/iam/env/{acc,idm,dir,web,common}.sh* ${HOME}/.env/
  if ! grep -q common ${HOME}/.bash_profile ; then
    echo '[ -a ~/.env/common.sh ] && . ~/.env/common.sh' >>${HOME}/.bash_profile
  fi
  log "create_user_profile" "done"
}



#  Create user profile and source them, parameters:
#  1. grep text, if found then skip
#  2. file to grep (skip)
#  3. directory with all templates
#
create_and_source_user_profile() {
  log "create_user_profile" "start"
  if ! grep -q "$1" "$2" ; then
    log "create_user_profile" "deploying .bashrc and .bash_profile..."
    # backup in home dir
    backup ~/.bashrc ~/.bash_profile
    local tmp1=/tmp/rc1_$(date '+%Y%m%d')
    while read line
    do
      eval echo "$line" >> ${tmp1}
    done < ${3}/bashrc
    . ${tmp1}
    cat ${tmp1} >>~/.bashrc
    while read line
    do
      eval echo "$line" >>~/.bash_profile
    done < ${3}/bash_profile
    rm -f ${tmp1}
    log "create_user_profile" "deployed"
  else
    log "create_user_profile" "skipped"
  fi

  #. ~/.bashrc ; . ~/.bash_profile
  log "create_user_profile" "profiles sourced"
  log "create_user_profile" "done"
}


#  create oracle inventory pointer, user needs sudo without pwd
#+ function will exit on error
#  1: orainv_pointer, default /etc/oraInst.loc
#  2: orainv,         default /appl/oraInventory
#  3: orainv_group,   default oinstall
create_orainv() {
  log "create_orainv" "start"
  local ptr="${1:-/etc/oraInst.loc}"
  local oin="${2:-/appl/oraInventory}"
  local grp="${3:-oinstall}"
  local txt1="inventory_loc=${oin}"
  local txt2="inst_group=${grp}"

  if ! [ -a ${ptr} ] ; then
    local _tf=/tmp/orainv.tmp.txt
    echo ${txt1} >  ${_tf}
    echo ${txt2} >> ${_tf}
    sudo -n cp ${_tf} ${ptr}

    if [ $? -ne 0 ] ; then
      rm -f $_tf
      echo "ERROR: no permission to write file ${ptr}. Root must execute
      echo ${txt} >> ${ptr}"
      exit 77
    fi
    rm -f ${_tf}
    if ! [ -d ${oin} ] ; then
      sudo -n mkdir -p ${oin}
      sudo -n chown $USER:$grp ${oin}
    fi
  fi
  log "create_orainv" "done"
}

#  in case they dont exists: create vim user folders
#
add_vim_user_config() {
  for d in backup spell autoload bundle ; do
    [ -a ${HOME}/.vim/${d} ] || mkdir -p ${HOME}/.vim/${d}
  done
}

##  generate configs from all templates with current env
##  in: 1.. templates dir
##      2.. output dir
##      2.. [optional] file to source in sub process
configs_from_templates() {
  (
  # if parameter 3 is passed then source file
  [[ -z $3 ]] || source $3
  for t in "$1/*" ; do
    while read line ; do
        eval echo "$line" > "$2/${t}.conf"
    done < $1/${t}
  done
  )
}

config_template() {
  while read line ; do
      eval echo "$line" > "$2/${3}.conf"
  done < $1
}

dir_for() {
  if [ ! -a $1 ] ; then
    mkdir -p $1; chown -R $2 $1
  fi
}


