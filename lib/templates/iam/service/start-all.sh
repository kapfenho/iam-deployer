#!/bin/sh

services=(
  oracle
  iam-dir
  iam-node
  iam-web
  iama-oam
  iama-admin
  iami-admin
  iami-soa
  iami-oim
)

echo "Starting database system and all IAM services..."

for s in ${services[@]}
do
  if service ${s} status >/dev/null
  then
    echo "..** service ${s} is already running"
  else
    if service ${s} start
    then
      echo ".... service ${s} has been started"
    else
      exit 80
    fi
  fi
done

echo "**** all services have been started."
echo

exit 0

