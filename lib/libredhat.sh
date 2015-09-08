# for centos releases: add redhat version to release file
#
redhat_compat() {
  local rf=/etc/redhat-release
  if ! grep -q 'Red Hat' $rf ; then
    if grep -q '6\.6' $rf ; then
      echo "Red Hat Enterprise Linux Server release 6.6 (Santiago)" >>$rf
    fi
    if grep -q '7\.1' $rf ; then
      echo "Red Hat Enterprise Linux Server release 7.1 (Maipo)" >>$rf
    fi
  fi
}

