export      ENV=dwpt
export   idmtop=/opt/fmw
export deployer=/opt/fmw/iam-deployer
export      lcm=/opt/fmw/lcm/lcm
export  lcmhome=/opt/fmw/lcm/lcmhome
export   s_repo=/opt/install/dwpbank/IAM-Base/iam-11.1.2.2/repo
export    s_lcm=${s_repo}/installers/idmlcm
export s_runjre=${s_repo}/installers/jdk/jdk7/jre
declare -a servers
servers=( dwptoud1 dwptoud2 dwptoim1 dwptoim2 dwptoam1 dwptoam2 dwptidw1 dwptidw2 )
export servers

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

# reverse proxy config
#
_VHDEF="NameVirtualHost 97.0.105.250\\
<VirtualHost 97.0.105.250>\\
\\
"
        PROV_HEADER_IDM="${_VHDEF}  ServerName         idm.ppapplications.dwpbank.net"
     PROV_HEADER_OAMADM="${_VHDEF}  ServerName      oamadm.ppapplications.dwpbank.net"
     PROV_HEADER_OIMADM="${_VHDEF}  ServerName      oimadm.ppapplications.dwpbank.net"
PROV_HEADER_OIMINTERNAL="${_VHDEF}  ServerName oiminternal.ppapplications.dwpbank.net"
        PROV_HEADER_SSO="${_VHDEF}  ServerName         sso.ppapplications.dwpbank.net"

# PROV_HEADER_IDM="NameVirtualHost 97.0.105.250\\
# <VirtualHost 97.0.105.250>\\
# \\
#   ServerName idm.ppapplications.dwpbank.net"
# 
# PROV_HEADER_OAMADM="NameVirtualHost 97.0.105.250\\
# <VirtualHost 97.0.105.250>\\
# \\
#   ServerName oamadm.ppapplications.dwpbank.net"
# 
# PROV_HEADER_OIMADM="
# NameVirtualHost 97.0.105.250
# <VirtualHost 97.0.105.250>
# 
#   ServerName oimadm.ppapplications.dwpbank.net
# "
# 
# PROV_HEADER_OIMINTERNAL="
# NameVirtualHost 97.0.105.250
# <VirtualHost 97.0.105.250>
# 
#   ServerName oiminternal.ppapplications.dwpbank.net
# "
# 
# PROV_HEADER_SSO="
# NameVirtualHost 97.0.105.250
# <VirtualHost 97.0.105.250>
# 
#   ServerName sso.ppapplications.dwpbank.net
# "
PROV_CONN_OAMADM="WebLogicHost dwptoam1.dwpbank.net\\
    WebLogicPort 7001"
PROV_CONN_OIMADM="WebLogicHost dwptoim1.dwpbank.net\\
    WebLogicPort 7101"
PROV_CONN_OAM="WebLogicCluster dwptoam1:14100,dwptoam2:14100"
PROV_CONN_OIM="WebLogicCluster dwptoim1:14000,dwptoim2:14000"
PROV_CONN_SOA="WebLogicCluster dwptoim1:8001,dwptoim2:8001"
    
