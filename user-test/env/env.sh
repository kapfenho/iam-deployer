export      ENV=test
export   idmtop=/opt/fmw
export deployer=/vagrant
export      lcm=/opt/fmw/lcm/lcm
export  lcmhome=/opt/fmw/lcm/lcmhome
export   s_repo=/mnt/oracle/iam-11.1.2.2/repo
export    s_lcm=${s_repo}/installers/idmlcm
export s_runjre=${s_repo}/installers/jdk/jdk7/jre
servers=(oud1 oud2 oim1 oim2 oam1 oam2 web1 web2)
export servers

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

