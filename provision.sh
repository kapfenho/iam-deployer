#!/bin/sh

echo '*** mounting...'
( [ -a /mnt/oracle ] || mkdir -m 0777 /mnt/oracle ) && if ! mount | grep -q 'oracle' ; then mount -t nfs nyx:/oracle /mnt/oracle ; fi

echo '*** system preparation...'

/vagrant/sys.sh && ~/root-script.sh

cp -R /vagrant /tmp/
chown -R oracle /tmp/vagrant

echo '*** database installation...'
su - oracle -c '/tmp/vagrant/db.sh  | /usr/bin/tee /tmp/prov-dbs.log'
chown -R iam /tmp/vagrant
echo '*** database installation finished.'

echo '*** application installation...'
su - iam    -c '/tmp/vagrant/iam.sh | /usr/bin/tee /tmp/prov-iam.log'
echo '*** application installation finished.'

echo '*** cleaning up ***'
rm -Rf /tmp/vagrant
echo '*** finished successfully ***'
exit 0
