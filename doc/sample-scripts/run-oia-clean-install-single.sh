#!/bin/sh
#
#  CLUSTER VERSION
#  this script removes OIA from a cluster install and starts a fresh 
#  installation
#
killall -9 java

/vagrant/iam remove -t analytics

~/bin/start-nodemanager

/vagrant/user-config/oia-single.sh

