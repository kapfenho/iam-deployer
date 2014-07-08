# wlst functions for deploying
#

#  create nodemanger keyfiles
#
function wlst_create_nm_keyfiles() {
  local wlst=${iam_mw_home}/products/access/oracle_common/common/bin/wlst.sh
  $wlst <<-EOF
    nmConnect('admin','Montag11','iam2','5556','IAMAccessDomain','/appl/iam/fmw/config/domains/IAMAccessDomain','ssl')
    start('AdminServer')
    connect('weblogic_idm', 'Montag11', 't3://iam2:7001')
    start('wls_oam1')
EOF

}

