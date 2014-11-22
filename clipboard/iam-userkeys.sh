#!/usr/bin/env bash

set -o errexit nounset

. ./user-config/env/env.sh

on oam1 '/vagrant/iam-setup.sh nodemanager access   access_test   7001'
on oam2 '/vagrant/iam-setup.sh nodemanager access   access_test   7001'
on oim1 '/vagrant/iam-setup.sh nodemanager identity identity_test 7101'
on oim2 '/vagrant/iam-setup.sh nodemanager identity identity_test 7101'

on oam1 '/vagrant/iam-setup.sh domain      access   access_test   7001'
on oim1 '/vagrant/iam-setup.sh domain      identity identity_test 7101'

exit 0

