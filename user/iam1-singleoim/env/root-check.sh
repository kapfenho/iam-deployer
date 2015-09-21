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


semmsl=$(cat /proc/sys/kernel/sem | cut -f 1)
semmns=$(cat /proc/sys/kernel/sem | cut -f 2)
semopm=$(cat /proc/sys/kernel/sem | cut -f 3)
semmni=$(cat /proc/sys/kernel/sem | cut -f 4)

if expr $semmsl \<   256 >/dev/null ; then warning "semmsl too small" ; fi
if expr $semmns \< 32000 >/dev/null ; then warning "semmns too small" ; fi
if expr $semopm \<   100 >/dev/null ; then warning "semopm too small" ; fi
if expr $semmni \<   142 >/dev/null ; then warning "semmni too small" ; fi

if expr $(cat /proc/sys/kernel/shmmax) \< 17179869184 >/dev/null ; then warning "shmmax too small" ; fi
if expr $(cat /proc/sys/fs/file-max)   \<     6815744 >/dev/null ; then warning "file-max too small" ; fi

# check ipv4 addresses

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
    rlwrap 
    tmux 
    telnet 
    nc 
    vim-enhanced )

yums=$(mktemp /tmp/yums-XXXXXXXXX)
yum list installed >${yums}

echo "++ checking 64bit packages..."
for l in ${fusion64[@]} ; do
  if ! grep -q "${l}.x86_64" ${yums} ; then
    warning "package missing: ${l}.x86_64"
  fi
done

echo "++ checking 32bit packages..."
for l in ${fusion32[@]} ; do
  if ! grep -q "${l}" ${yums} ; then
    warning "package missing: ${l}"
  fi
done

echo "++ checking additional tools..."
for l in ${tools[@]} ; do
  if ! grep -q "${l}" ${yums} ; then
    warning "package missing: ${l}"
  fi
done

rm -f ${yums}

echo "++ checking system security resource limits..."
if expr $(ulimit -Sf) \<   15000 >/dev/null ; then warning "soft limit open files less than 15000" ; fi
if expr $(ulimit -Hf) \<   15000 >/dev/null ; then warning "hard limit open files less than 15000" ; fi

if expr $(ulimit -Su) \<   16384 >/dev/null ; then warning "soft limit nproc less than 16384" ; fi
if expr $(ulimit -Hu) \<   16384 >/dev/null ; then warning "hard limit nproc less than 16384" ; fi

echo "In case you got now ERROR or WARNING you are fine!"
echo

echo "Please check if the date and time is correct"
echo "$(date)"

exit 0

