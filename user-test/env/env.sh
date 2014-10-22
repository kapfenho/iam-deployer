export      ENV=test
export   idmtop=/opt/fmw
export deployer=/vagrant
export      lcm=/opt/fmw/lcm/lcm
export  lcmhome=/opt/fmw/lcm/lcmhome
export   s_repo=/mnt/oracle/iam-11.1.2.2/repo
export    s_lcm=${s_repo}/installers/idmlcm
export s_runjre=${s_repo}/installers/jdk/jdk7/jre
export  servers=( oud1 oud2 oim1 oim2 oam1 oam2 web1 web2 )

on() { 
  c="vagrant ssh ${1} -- sudo -u fmwuser -H -n ${2}"
  echo "${c}" ; ${c}
}

on_all() {
  for srv in ${servers[@]}
  do
    on ${srv} "${1}"
  done
}

