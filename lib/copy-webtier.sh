# copy webtier files
#

_wtf=(
  httpd.conf
  moduleconf
  moduleconf/idm.conf
  moduleconf/oamadm.conf
  moduleconf/oimadm.conf
  moduleconf/oiminternal.conf
  moduleconf/plsql.conf
  moduleconf/sso.conf
  ssl-base.conf
  ssl.conf
  )


# copy_webtier: copy ohs config files
#   $1: source dir within project
#   $2: dest dir, config folder of instance
#
copy_webtier() {
  src=$1
  dest=$2

  local bkp=${dest}/backup/$(date +"%Y%m%d-%H%M")
  mkdir -p ${bkp}

  for f in ${_wtf[@]}
  do
    [ -a ${dest}/${f} ] && cp -pfv ${dest}/${f} ${bkp}/
    cp -pfv ${src}/${f} ${dest}/${f}
  done
}

  

