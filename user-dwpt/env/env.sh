export      ENV=dwpt
export   idmtop=/opt/fmw
export deployer=/opt/fmw/iam-deployer
export      lcm=/opt/fmw/lcm/lcm
export  lcmhome=/opt/fmw/lcm/lcmhome
export   s_repo=/opt/install/dwpbank/IAM-Base/iam-11.1.2.2/repo
export    s_lcm=${s_repo}/installers/idmlcm
export s_runjre=${s_repo}/installers/jdk/jdk7/jre
export  servers=( dwptoud1 dwptoud2 dwptoim1 dwptoim2 dwptoam1 dwptoam2 dwptidw1 dwptidw2 )

on() { 
  c="ssh ${1} -- ${2}"
  echo "${c}" ; ${c}
}

on_all() {
  for srv in ${servers[@]}
  do
    on ${srv} "${1}"
  done
}

