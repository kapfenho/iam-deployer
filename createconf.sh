#!/bin/sh
#
#  Helper script for creating initial user configs as copy from example
#+ files.

files=(
  Vagrantfile
  user-config/database.config
  user-config/dbs/db_create.rsp
  user-config/dbs/db_install.rsp
  user-config/dbs/db_netca.rsp
  user-config/lcm/lcm_install.rsp
  user-config/iam/provisioning.rsp
  user-config/iam/psa_access.rsp
  user-config/iam/psa_identity.rsp
  user-config/iam.config
  )

echo
echo "I am gonna create copies of the example config files as your"
echo "  initial config files."
echo "Press Ctrl-C to cancel or RETURN to continue...."
read nil
  
for f in ${files[@]} ; do
  if [ -a ${f} ] ; then
    echo "Warning: file ${f} already exists, skipping..."
    continue
  fi
  cp ${f}.example ${f}
done

exit 0

