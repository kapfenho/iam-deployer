# wlst functions for deploying
#

#  create nodemanger keyfiles
#
function wlst_create_nm_keyfiles() {
  wls_user=weblogic
  wls_pwd=Montag11
  wls_host="$(hostname)"
  wls_port=5556
  wls_dom=acc_dev
  wls_dompath=/opt/fmw/config/domains/acc_dev
  wls_adminport=7001
  ks=/opt/fmw/config/keystore
  defUCnm=${ks}/nm-${wls_host}.usr
  defUKnm=${ks}/nm-${wls_host}.key
  defUC=${ks}/${wls_dom}.usr
  defUK=${ks}/${wls_dom}.key
  local wlst=${iam_mw_home}/products/access/oracle_common/common/bin/wlst.sh
  ${wlst} <<-EOF
  nmConnect(       userConfigFile='${wls_user}',
                      userKeyFile='${wls_pwd}',
                             host='${wls_host}',
                             port='${wls_port}',
                       domainName='${wls_dom}',
                        domainDir='${dom_dir}', 'ssl' )
  storeUserConfig( userConfigFile='${defUCnm}',
                      userKeyFile='${defUKnm}', nm='true' )
  connect(                  user='${wls_user}',
                        password='${wls_pwd}',
                             url='t3://${wls_host}:${wls_adminport}' )
  storeUserConfig( userConfigFile='${defUC}',
                      userKeyFile='${defUK}', nm='false' )
  exit()
EOF

}

