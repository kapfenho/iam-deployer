export      ENV=dev2
export   idmtop=/opt/fmw
export deployer=/opt/fmw/iam-deployer
export      lcm=/opt/fmw/lcm/lcm
export  lcmhome=/opt/fmw/lcm/lcmhome
export   s_repo=/appdata/install/oracle/iam-11.1.2.2
export    s_lcm=${s_repo}/installers/idmlcm
export s_runjre=${s_repo}/installers/jdk/jdk6/jre
servers=(dwpidmdev02)
export servers

# environment functions and variables for working with vms
# load this file
#
# vi: set ft=sh :

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
  #cmd="vagrant ssh ${1} -- sudo -u fmwuser -H -n ${2}"
  #echo "${cmd}"
  #${cmd}
}

rooton() { 
  echo -n "${1}: "
  vagrant ssh ${1} -- sudo ${2}
  #cmd="vagrant ssh ${1} -- sudo ${2}"
  #echo "${cmd}" ; ${cmd}
}

on_all() {
  for srv in ${servers[@]}
  do
    on ${srv} "${1}"
  done
}

rooton_all() {
  for srv in ${servers[@]}
  do
    rooton ${srv} "${1}"
  done
}

