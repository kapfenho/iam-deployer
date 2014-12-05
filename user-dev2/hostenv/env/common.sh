export         PS1='[\u@\h:\[\e[0;32m\]${E}\[\e[m\] \W]\$ '
export       PAGER=less
export      EDITOR=vi

export    DEF_PATH=${HOME}/bin:/appexec/fmw/platform/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin
export  REPOS_HOME=/mnt/orainst/iam-11.1.2.2/repo/installers
export IDMLCM_HOME=/appexec/fmw/lcm

function   acc() { export E=acc  ; . ~/.env/acc.sh   ; }
function   dir() { export E=dir  ; . ~/.env/dir.sh   ; }
function   idm() { export E=idm  ; . ~/.env/idm.sh   ; }
function   web() { export E=web  ; . ~/.env/web.sh   ; }
function  poud() { export E=poud ; . ~/.env/poud.sh  ; }
function play1() { export E=poud ; . ~/.env/play1.sh ; }

function e() {
  echo
  echo -e "\e[36mAvailable Envs:  \e[31macc  dir  idm  web  poud  play1\e[0m"
  if [ -n ${E} ] ; then
    echo " Currently:  E=${E}"
    echo "   ORACLE_HOME=${ORACLE_HOME}"
    echo "   DOMAIN_HOME=${DOMAIN_HOME}"
    echo "       --------------------"
    echo " aliases:"
    echo -e "\e[31m   oh \e[0m... goto oracle home"
    echo -e "\e[31m  ohc \e[0m... goto oracle common"
    echo -e "\e[31m   dh \e[0m... goto domain home"
    echo -e "\e[31m   dl \e[0m... goto domain log"
    echo
    echo -e " type \e[31me\e[0m for this message"
    echo
  fi
}

alias    l='ls -lF'
alias   ll='ls -lF'
alias   la='ls -laF'
alias   vi='vim'
alias wlst='rlwrap ${ORACLE_COMMON}/common/bin/wlst.sh'
alias   oh='cd ${ORACLE_HOME}; pwd'
alias  ohc='cd ${ORACLE_COMMON}; pwd'
alias   dh='cd ${DOMAIN_HOME:-$INST_HOME}; pwd'
alias   dl='cd ${DOMAIN_LOG:-$INST_LOG}; pwd'

# default env, feel free to change it
# play1

