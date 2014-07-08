#  Deployment shell functions
# 

#  rcd_add: register service in rc.d
#+ 1: name of new service
#+ 2: path of rc.d source file
#
rcd_add() {
  local dest=/etc/rc.d/init.d/${1}
  log "rcd_add" "registerig ${1}"
  if [ -a ${dest} ] ; then
    log "rcd_add" "service ${1} already registered, skipped"
  else
    sudo -n cp -p ${2} ${dest}
    sudo -n chmod 0755 ${dest}
    log "rcd_add" "start script added"
    sudo -n chkconfig --add ${1}
    log "rcd_add" "service registered"
  fi
}

#  rcd_service_start
#+ 1: service name
#
rcd_service_start() {
  log "rcd_service-start" "starting ${1}..."
  sudo -n service ${1} start
  log "rcd_service-start" "started"
}


#  deploy vim settings 
#+ 
add_vim_features() {
  #local d_rc=/etc/vim/vimrc.local   # debian
  local d_rc=/etc/vimrc
  local d_cust=/usr/share/vim/vimfiles
  local d_sys=/usr/share/vim/vim72
  
  cp ${_DIR}/sys/vim/vimrc ${d_rc}
  sed -i.sav "16 i execute pathogen#infect('bundle/{}', '/usr/share/vim/vimfiles/bundle/{}')" ${d_rc}

  tar --no-same-owner --no-same-permissions -xzf ${_DIR}/sys/vim/bundle.tar.gz --directory=${d_cust}

  [ -a ${d_cust}/autoload ] || mkdir -p ${d_cust}/autoload
  cp -Rp ${_DIR}/sys/vim/pathogen.vim ${d_cust}/autoload/
}

