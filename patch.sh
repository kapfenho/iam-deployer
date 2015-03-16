#!/bin/sh

declare -a list
list=(
  17897950
  18244420
  18416233
  19457718
  19471000
  19702081
)

for d in ${list[@]} ; do
  echo -e "\n\n*************************** Patch ${d} ********"
  pushd ${d}/oui
  ${ORACLE_HOME}/OPatch/opatch apply -silent
  popd
done

echo "-e\n ----> Completed successfully"
echo


