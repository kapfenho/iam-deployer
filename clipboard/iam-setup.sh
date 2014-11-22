#!/bin/sh

# parameters:
# para 1: nodemanager | domain
# para 2: product name: access | identity
# para 3: domain name
# para 4: admin server port

E_BADARGS=77
EXPECTED_ARGS=4

set -o errexit
# set -o nounset

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#. ${_DIR}/user-config/iam.config
. ${_DIR}/lib/libwlst.sh

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: $(basename $0) {nodemanager|domain} {product} {domain_name} {admin_port}"
  echo "Example: $(basename $0) domain access access_dev 7001"
  exit $E_BADARGS
fi

set -x
nm=false
dom=false
[ "$1" == "nodemanager" ] && nm=true
[ "$1" == "domain" ]      && dom=true

echo "Nodemanager: ${nm}"
echo "Domain:      ${dom}"

if [ "${nm}" == "true" ]
then
  echo "*** nodemanager keyfiles: creating..."
  wlst_create_nm_keyfiles $2 $3 $4
  echo "*** nodemanager keyfiles: done"
fi

if [ "${dom}" == "true" ]
then
  echo "*** dom keyfiles:         creating..."
  wlst_create_dom_keyfiles $2 $3 $4
  echo "*** dom keyfiles:         done"
fi

set +x
exit 0

