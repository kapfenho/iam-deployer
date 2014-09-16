#!/usr/bin/env bash
#
#  Helper script for creating initial user configs as copy from example
#+ files.

files=(
  Vagrantfile
  user-config/database.config
  user-config/lcm/lcm_install.rsp
  user-config/dbs/db_create.rsp
  user-config/dbs/db_install.rsp
  user-config/dbs/db_netca.rsp
  user-config/iam/provisioning.rsp
  user-config/iam/psa_access.rsp
  user-config/iam/psa_identity.rsp
  user-config/iam.config
  )
dbfiles=(
  user-config/dbs/db_create.rsp
  user-config/dbs/db_install.rsp
  user-config/dbs/db_netca.rsp
)

echo
echo ">> I am gonna create copies of the example config files as your"
echo "   initial config files."
echo ">> The database response files are short stripped versions - check the"
echo "   example files for more information and additional options."
echo
echo "Press Ctrl-C to cancel or RETURN to continue...."
read nil
  
for f in ${files[@]} ; do
  if [ -a ${f} ] ; then
    echo "*** Warning: file ${f} already exists, skipping..."
    continue
  fi
  cp ${f}.example ${f}
  echo "File created: ${f}"
done

for f in ${dbfiles[@]} ; do
  if [ -a ${f}.short ] ; then
    echo "*** Warning: file ${f} already exists, skipping..."
    continue
  fi
  egrep '(^[A-Z].*)|(^\[.*)' ${f}.example > ${f}.short
  echo "File created: ${f}"
done

echo "Completed."

exit 0

