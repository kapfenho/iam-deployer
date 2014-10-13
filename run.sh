#!/usr/bin/env bash
# vi: set ft=sh :

. ./env/dwp1/env.sh

for h in ${servers[@]}
do
  vagrant ssh ${h} -- ${1}
done

exit 0
