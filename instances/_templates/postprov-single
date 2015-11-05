#!/bin/sh
#
set -o errexit

# we want the iam command in PATH
export DEPLOYER
export PATH=${DEPLOYER}:${PATH}

#  deploy user environment
iam userenv -a env
iam userenv -a profile -H localhost

#  copy weblogic libraries
iam weblogic -a wlstlibs -t identity -H localhost

#  upgrade jdk
iam jdk -H localhost -O identity

#  identity domain PSA run
iam identity -a psa

#  identity domain nodemanager and domain keyfiles
iam keyfile -t nodemanager -H localhost -D identity
iam keyfile -t domain -D identity

#  identity domain post-install steps
iam identity -a postinstall
iam identity -a movelogs -H localhost

#  patch weblogic java environment
iam weblogic -a jdk7fix -t identity -H localhost
iam identity -a jdk7fix -t identity -H localhost

#  webgate installation bug fix
iam webtier  -a postinstall
iam webtier  -a movelogs -h localhost

