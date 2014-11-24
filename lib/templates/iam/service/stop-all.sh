#!/bin/sh

services=(
  iami-oim
  iami-soa
  iami-admin
  iama-admin
  iama-oam
  iam-node
  iam-web
  iam-dir
  oracle
)

echo "Stopping all IAM Services and database system"

for s in ${services[@]}
do
  if service ${s} status >/dev/null
  then
    service ${s} stop
    echo ".... service ${s} has been stopped"
  fi
done

echo "**** all services have been stopped."

exit 0

