#!/bin/sh

servers=( oud1 oud2 oim1 oim2 oam1 oam2 web1 web2 )

for srv in ${servers[@]}
do
  echo "************** ${srv}"
  vagrant ssh ${srv} -- 'sudo ps wuax | grep fmwuser'
done

exit 0
