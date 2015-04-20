#!/bin/sh

echo '*** system preparation...'

cp -f /vagrant/user-config/hostenv/hosts /etc/hosts
/vagrant/user-config/env/root-script.sh

echo '*** database installation...'
su - oracle -c '/vagrant/db.sh  | /usr/bin/tee /tmp/prov-dbs.log'
echo '*** database installation finished.'

echo '*** application installation...'
su - fmwuser -c 'DEPLOYER=/vagrant /vagrant/iam.sh | /usr/bin/tee /tmp/prov-iam.log'
echo '*** application installation finished.'

echo '*** finished successfully ***'

exit 0
