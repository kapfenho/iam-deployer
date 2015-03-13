#!/bin/bash

patches=( 17897950  18244420  18416233  19457718  19471000  19702081 )

_DIR=$PWD

for i in ${patches[@]}
do
  cd $_DIR/$i/oui
  echo "--> patching $PWD.."
  ${ORACLE_HOME}/OPatch/opatch apply -silent
  echo ""
done
