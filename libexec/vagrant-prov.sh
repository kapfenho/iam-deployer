#!/bin/sh

# echo '*** mounting...'
# ( [ -a /mnt/oracle ] || mkdir -m 0777 /mnt/oracle ) && if ! mount | grep -q 'oracle' ; then mount -t nfs nyx:/export/oracle /mnt/oracle ; fi

echo '*** system preparation...'

/vagrant/user-config/env/root-script.sh

# echo '*** database installation...'
# su - oracle -c '/vagrant/db.sh  | /usr/bin/tee /tmp/prov-dbs.log'
# echo '*** database installation finished.'
# 
# echo '*** application installation...'
# su - iam    -c '/vagrant/iam.sh | /usr/bin/tee /tmp/prov-iam.log'
# echo '*** application installation finished.'
# 
# echo '*** finished successfully ***'

exit 0
