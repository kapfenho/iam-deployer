#!/bin/sh
#
#  CLUSTER VERSION
#  this script removes OIA from a cluster install and starts a fresh 
#  installation
#
killall -9 java
ssh oim2 -- killall -9 java

/vagrant/iam remove -t analytics
/vagrant/iam remove -t analytics -H oim2

~/bin/start-nodemanager
ssh $srcoia2 -- bash -l ~/bin/start-nodemanager

/vagrant/user-config/oia-cluster.sh

