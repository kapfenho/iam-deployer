export      ENV=dwpt
export     ddir=/opt/fmw
export    dbase=/opt/install/dwpbank/
export      prj=${dbase}/iam-deployer
export   shared=${dbase}/idmlcm
export   s_repo=${dbase}/IAM-Base/iam-11.1.2.2/repo
export    s_lcm=${s_repo}/installers/idmlcm
export s_runjre=${s_repo}/installers/jdk/jdk7/jre
export  servers=( dwptoud1 dwptoud2 dwptoim1 dwptoim2 dwptoam1 dwptoam2 dwptidw1 dwptidw2 )

on() { 
  c="ssh ${1} -- ${2}"
  echo "${c}" ; ${c}
}

