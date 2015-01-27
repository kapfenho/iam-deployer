#!/bin/sh

set -x

src=/appexec/fmw/products/access/jdk
jdk=jdk1.7.0_60


for d in access identity dir web 
do
  dest=/opt/fmw/products/$d

  mkdir -p $dest/jdk
  mv $dest/jdk6 $dest/jdk/
  cp -Rp $src/$jdk $dest/jdk/
  ln -s $dest/jdk/$jdk $dest/jdk/current
  ln -s $dest/jdk/$jdk $dest/jdk6
done

set +x
