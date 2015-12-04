#!/bin/bash

log() {
  if [[ -t 1 ]]; then
    printf "%b>>>%b %b%s%b\n" "\x1b[1m\x1b[32m" "\x1b[0m" \
                              "\x1b[1m\x1b[37m" "$1" "\x1b[0m"
  else
    printf ">>> %s\n" "$1"
  fi
}

error() {
  if [[ -t 1 ]]; then
    printf "%b!!!%b %b%s%b\n" "\x1b[1m\x1b[31m" "\x1b[0m" \
                              "\x1b[1m\x1b[37m" "$1" "\x1b[0m" >&2
  else
    printf "!!! %s\n" "$1" >&2
  fi
}

warning() {
  if [[ -t 1 ]]; then
    printf "%b***%b %b%s%b\n" "\x1b[1m\x1b[33m" "\x1b[0m" \
                        "\x1b[1m\x1b[37m" "$1" "\x1b[0m" >&2
  else
    printf "*** %s\n" "$1" >&2
  fi
}

# ---------------------------------------------

: ${TMPDIR:=/tmp}

checks='semmsl:256:cat /proc/sys/kernel/sem | cut -f 1
semmns:32000:cat /proc/sys/kernel/sem | cut -f 2
semopm:100:cat /proc/sys/kernel/sem | cut -f 3
semmni:142:cat /proc/sys/kernel/sem | cut -f 4
shmmax:17179869184:cat /proc/sys/kernel/shmmax
file-max:6815744:cat /proc/sys/fs/file-max
nofile-soft:15000:ulimit -Sf
nofile-hard:15000:ulimit -Hf
nproc-soft:16384:ulimit -Su
nproc-hard:16384:ulimit -Hu
tmpspace:1300:df -m ${TMPDIR} | tail -1 | awk "{ print $3 }"'

#   64bit packages for all fusion apps
fusion64=(
    binutils 
    compat-libcap1 
    compat-libstdc++-33 
    gcc 
    gcc-c++ 
    glibc 
    libaio 
    libaio-devel 
    libgcc 
    libstdc++ 
    libstdc++-devel 
    libXext 
    libXtst 
    make 
    openmotif 
    openmotif22 
    redhat-lsb-core 
    sysstat 
    xorg-x11-utils 
    xorg-x11-apps 
    xorg-x11-xinit 
    xorg-x11-server-Xorg 
    xterm )

#   32bit packages for fusion apps
fusion32=(
    compat-libstdc++-33.i686 
    glibc-devel.i686 
    glibc.i686 
    libstdc++-devel.i686 
    libstdc++.i686 
    libXext.i686 
    libXtst.i686 
    libXi.i686 )

tools=(
    nfs-utils 
    unzip 
#   rlwrap 
#   tmux 
#   telnet 
#   nc 
    vim-enhanced )

# -------------------------------------------------

declare -i issues
issues=0
IFS="
"

echo "Starting checks..."
echo
echo "--- checking kernel parameters"
for c in ${checks[@]} ; do 

   cname=$(echo -n ${c} | cut -d : -f 1)
  climit=$(echo -n ${c} | cut -d : -f 2)
  ccheck=$(echo -n ${c} | cut -d : -f 3)

  if expr $( eval "${ccheck}" ) \< ${climit} >/dev/null ; then
    warning "${cname} is lower than ${climit}."
    let issues++
  else
    echo "${cname} ok"
  fi

done

# -------------------------------------------------

yums=$(mktemp /tmp/yums-XXXXXXXXX)
yum list installed >${yums}

echo
echo "--- checking 64bit packages..."
for l in ${fusion64[@]} ; do
  if ! grep -q "${l}.x86_64" ${yums} ; then
    warning "package missing: ${l}.x86_64"
    let issues++
  else
    echo "package <${l}.x86_64> is installed"
  fi
done

echo
echo "--- checking 32bit packages..."
for l in ${fusion32[@]} ; do
  if ! grep -q "${l}" ${yums} ; then
    warning "package missing: ${l}"
    let issues++
  else
    echo "package <${l}> is installed"
  fi
done

echo
echo "--- checking additional tools..."
for l in ${tools[@]} ; do
  if ! grep -q "${l}" ${yums} ; then
    warning "package missing: ${l}"
    let issues++
  else
    echo "package <${l}> is installed"
  fi
done
rm -f ${yums}

# ---------------------------------

if [[ "$(hostname -s)" == "$(hostname -f)" ]] ; then
  # dnsdomainname
  warning "Hostname problem: hostname -s ... hostname"
  warning "Hostname problem: hostname -f ... full qualified hostname"
fi

echo
if [ ${issues} -gt 0 ] ; then
  warning "There are ${issues} issues to correct before proceeding"
else
  echo "No problems found!"
fi

echo
echo "Please check now the date and time:  $(date)"

exit 0

