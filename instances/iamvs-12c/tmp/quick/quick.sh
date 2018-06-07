#!/bin/sh -x

file="fmw_12.2.1.3.0_idmquickstart.jar"

cd /mnt/oracle/images/iam-12.2.1.3/quick

java -jar "$file" \
  -invPtrLoc /etc/oraInst.loc \
  -responseFile $HOME/deploy/quick.rsp \
  -silent
