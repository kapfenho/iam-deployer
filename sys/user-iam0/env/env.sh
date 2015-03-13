# environment functions and variables for working with vms
# load this file
#
# vi: set ft=sh :

declare -a servers
 servers=( oud1 oud2 oim1 oim2 oam1 oam2 web1 web2 )
export servers

E_NR_PARAM=70

on_vm() {
  if [ ${#} -lt 2 -o ${#} -gt 3  ] ; then
    echo "ERROR: argument missing"
    echo "${0} { server | -a | --all } 'command to execute' [-0 | -1]"
    echo "    -0...  print hostname inline"
    echo "    -1...  print hostname on individual line"
    echo 
    exit E_NR_PARAM
  fi
  info=""
  p_srv=${1}
  p_cmd=${2}
  if [ ${#} -eq 3 ]; then
    info=""
    if [ "${3}" -eq "-0" ]; then
      info='echo -n ">>>> host $(hostname -s): " ; '
    elif [ "${3}" -eq "-1" ]; then
      info='echo ">>>> host $(hostname -s):" ; '
    fi
  fi

  case ${p_srv} in
    "-a" | "--all")
      for s in ${servers[@]}
      do 
        vagrant ssh ${s} -- ${info} sudo -u fmwuser -H -n ${p_cmd}
      done
      ;;
    *)
      vagrant ssh ${p_srv} -- ${info} sudo -u fmwuser -H -n ${p_cmd}
      ;;
  esac
}


on() { 
  vagrant ssh ${1} -- sudo -u fmwuser -H -n ${2}
}

rooton() { 
  echo "*** ${1} ***"
  vagrant ssh ${1} -- sudo ${2}
}

on_all() {
  for srv in ${servers[@]} ; do
    echo "*** ${srv} ***"
    on ${srv} "${1}"
  done
}

rooton_all() {
  for srv in ${servers[@]} ; do
    echo "*** ${srv} ***"
    rooton ${srv} "${1}"
  done
}

