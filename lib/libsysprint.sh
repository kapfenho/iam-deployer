# Deployment shell functions, writing to stdout
# 
# Several functions for creating users and groups, adding system
#+packages, and setting system parameters and security limits.
#
_LIBDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

_sysctl=/etc/sysctl.conf

# create unix group, check if exists before
# params: name, id
create_group() {
  if ! grep -q "$1" /etc/group ; then
    echo "groupadd -g $2 $1"
  fi
}

# create unix users, check if exists before
# params: name, id
create_user() {
  if ! grep -q "$1" /etc/passwd ; then
    echo "useradd -u $2 -g $3 -G $4 $1"
  fi
}

# add sudoer file for user, all permissions, no pasword
# params: username
sudo_for() {
  _sudoer=/etc/sudoers.d/$1
  if ! [ -a ${_sudoer} ]
  then
    echo "echo \"$1  ALL=(ALL)  NOPASSWD: ALL\" > ${_sudoer}"
    echo "chmod 440 ${_sudoer}"
  fi
}

# create directory and chown to user:group
# params: directory, user:group
dir_for() {
  if ! [ -a $1 ]
  then
    echo "mkdir -p $1; chown -R $2 $1"
  fi
}

# add start comment in sysctl file
set_sysctl_start() {
  echo "echo \"# customizations oracle start\" >> ${_sysctl}"
}

# add enb comment in sysctl file
set_sysctl_end() {
  echo "echo \"# customizations oracle end\" >> ${_sysctl}"
}

# setting system setting to value
# params: setting, value
set_sysctl() {
  if grep -q $1 ${_sysctl} ; then
    echo -n "sed -i -e \"/$1/d\" ${_sysctl} ; "
  fi
  echo "echo \"$1=$2\" >> ${_sysctl}"
}

# activate the sysctl changes
# no params
activate_sysctl() {
  echo "/sbin/sysctl -p"
}

# setting system security limits
# params: setting, value
set_limit() {
  _syslmt=/etc/security/limits.conf
  echo "echo \"$1\" >> ${_syslmt}"
}

# setting system security limits
# params: setting, value
set_proc_limit() {
  _syslmt=/etc/security/limits.d/99-nproc.conf
  # TODO: delete * nproc limits
  echo "echo \"$1\" >> ${_syslmt}"
}

# update repo
update_repo() {
  echo yum check-update
  echo yum upgrade
}

# install packages
add_packages() {
  _packs=$1
  eval echo yum install -y \${$_packs[*]}
}

# add repo epel for additional packages
add_epel_rpm() {
  echo "rpm -Uvh $1"
  echo yum check-update
}

# disable system service via chkconfig
# param: service_name
disable_service() {
  if chkconfig | grep -q "$1" ; then
    echo "chkconfig --del $1"
  fi
}

#  vim features, install to system dir
#
add_vim_features_p() {
  #local d_rc=/etc/vim/vimrc.local   # debian
  local d_rc=/etc/vimrc
  local d_cust=/usr/share/vim/vimfiles
  local d_sys=/usr/share/vim/vim72
 
  echo

  echo "tar --no-same-owner --no-same-permissions -xzf ${_DIR}/sys/vim/bundle.tar.gz --directory=${d_cust}"

  echo "cp -Rp ${_DIR}/sys/vim/pathogen.vim ${d_sys}/autoload/"
  echo "cp ${_DIR}/sys/vim/vimrc /etc/skel/.vimrc"
  echo "cp ${_DIR}/sys/vim/vimrc /root/.vimrc"
  echo "mkdir -p /etc/skel/.vim/backup"
  echo
}

