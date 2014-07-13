#!/bin/sh

if [ $# -eq 0 ] ; then
  echo $#
  echo "Usage: $(basename ${0}) oldname [newname]"
  echo "  e.g. $(basename ${0}) lunes martes"
  exit 80
fi

echo
echo "Here are the occurences of <${1}>:"
echo

grep -ri  --exclude "*example" --exclude "*orig" ${1} user-config

if [ -n "${2}" ] ; then

  echo
  echo "Now we will change those occurences to <${2}>."
  echo
  echo "Press Ctrl-C to quit or RETURN to continue."
  read nil
  
  grep -ril --exclude "*example" --exclude "*orig" ${1} user-config | xargs sed -i.orig -e "s/${1}/${2}/g"
fi

exit 0
