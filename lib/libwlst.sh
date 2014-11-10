# wlst functions for deploying
#


# nmConnect(       userConfigFile='${wls_user}',
#                     userKeyFile='${wls_pwd}',
#                            host='${wls_host}',
#                            port='${wls_port}',
#                      domainName='${wls_dom}',
#                       domainDir='${wls_dompath}', nmType='ssl' )

#  create nodemanger keyfiles
#
function wlst_create_nm_keyfiles() {
  iam_mw_home=/opt/fmw/products/$1
  nm_user=admin
  nm_pwd=Montag11
  wls_user=weblogic
  wls_pwd=Montag11
  wls_host="$(hostname)"
  wls_nmport=5556
  #wls_dom=identity_test
  wls_dom=$2
  wls_dompath=/opt/fmw/config/domains/${wls_dom}
  wls_adminport=$3
  ks=/opt/fmw/config/keystore
  defUCnm=${ks}/nm-${wls_host}.usr
  defUKnm=${ks}/nm-${wls_host}.key
  defUC=${ks}/${wls_dom}.usr
  defUK=${ks}/${wls_dom}.key
  local wlst=${iam_mw_home}/oracle_common/common/bin/wlst.sh

  ${wlst} <<-EOF
  nmConnect(             username='${nm_user}',
                         password='${nm_pwd}',
                             host='${wls_host}',
                             port='${wls_nmport}',
                       domainName='${wls_dom}',
                        domainDir='${wls_dompath}', nmType='ssl' )
  storeUserConfig( userConfigFile='${defUCnm}',
                      userKeyFile='${defUKnm}', nm='true' )
y
  exit()
EOF
}

function wlst_create_dom_keyfiles() {
  iam_mw_home=/opt/fmw/products/$1
  wl_home=/opt/fmw/products/identity/wlserver_10.3
  nm_user=admin
  nm_pwd=Montag11
  wls_user=weblogic
  wls_pwd=Montag11
  wls_host="$(hostname)"
  wls_nmport=5556
  wls_dom=$2
  wls_dompath=/opt/fmw/config/domains/${wls_dom}
  wls_adminport=$3
  ks=/opt/fmw/config/keystore
  defUCnm=${ks}/nm-${wls_host}.usr
  defUKnm=${ks}/nm-${wls_host}.key
  defUC=${ks}/${wls_dom}.usr
  defUK=${ks}/${wls_dom}.key
  local wlst=${wl_home}/common/bin/wlst.sh

  ${wlst} <<-EOF
  connect(              username="${wls_user}",
                        password="${wls_pwd}",
                             url="t3://${wls_host}:${wls_adminport}" )

  storeUserConfig( userConfigFile="${defUC}",
                      userKeyFile="${defUK}", nm="false" )
y
  exit()
EOF
}

