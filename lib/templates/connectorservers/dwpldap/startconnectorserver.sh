#!/bin/sh

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

log=/var/log/fmw/connectorservers/dwpldap/dwldap.out

nohup ${_DIR}/connectorserver.sh /run >${log} 2>&1 &

echo "Started successfully"
echo 

exit 0

