#!/usr/bin/env bash
#
#  little helper for changing configs. will search for $1 in user config
#+ files. in case $2 is stated, $1 will be changed to $2 in all files.
#+ Use this for changing hostname, etc.

if [ $# -eq 0 ] ; then
  echo $#
  echo "Usage: $(basename ${0}) oldname [newname]"
  echo "  e.g. $(basename ${0}) lunes.agoracon.at martes.ibm.com"
  exit 80
fi

echo
echo "Here are the occurences of <${1}>:"
echo

grep -r  --exclude "*example" --exclude "*orig" "${1}" \
  user-config Vagrantfile

if [ -n "${2}" ] ; then

  echo
  echo "Now we will change those occurences to <${2}>."
  echo
  echo "Press Ctrl-C to quit or RETURN to continue."
  read nil
  
  grep -rl --exclude "*example" --exclude "*orig" "${1}" \
    user-config Vagrantfile | xargs sed -i.orig -e "s/${1}/${2}/g"
fi

exit 0
