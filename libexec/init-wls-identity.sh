#!/bin/sh

   prop=${HOME}/.env/identity.prop
 keydir=${HOME}/.env
    dom=identity_test
admport=7101

. /vagrant/lib/libwls.sh

rm -f ${keydir}/*.{usr,key}

create_dom_prop  ${prop} \
  ${keydir} \
  5556 \
  ${dom} \
  /opt/fmw/config/domains/${dom} \
  /opt/local/domains/${dom} \
  ${admport}

# nodemanager
wlst_create_nm_keyfiles ${prop} admin Montag11

# adminserver
if hostname -s | grep '1' ; then
  wlst_create_dom_keyfiles  ${prop} weblogic Montag11
fi

echo "Keyfiles written"

exit 0
