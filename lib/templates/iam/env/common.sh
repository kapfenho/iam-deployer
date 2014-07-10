export         PS1='[\u@\h:\[\e[0;32m\]${E}\[\e[m\] \W]\$ '
export       PAGER=less
export      EDITOR=vi

export    DEF_PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/iam/bin
export  REPOS_HOME=/mnt/orainst/iam-11.1.2.2/repo/installers
export IDMLCM_HOME=/appl/iam/fmw/lcm

function acc() { export E=acc ; . ~/.env/acc.sh ; }
function dir() { export E=dir ; . ~/.env/dir.sh ; }
function idm() { export E=idm ; . ~/.env/idm.sh ; }
function web() { export E=web ; . ~/.env/web.sh ; }

function e() {
  echo
  echo ' Available Envs:  acc  dir  idm  web'
  if [ -n ${E} ] ; then
    echo " Currently:  E=${E}"
    echo "   ORACLE_HOME=${ORACLE_HOME}"
    echo "   DOMAIN_HOME=${DOMAIN_HOME}"
    echo "       --------------------"
    echo " aliases:"
    echo "   oh ... goto oracle home"
    echo "  ohc ... goto oracle common"
    echo "   dh ... goto domain home"
    echo "   dl ... goto domain log"
    echo
  fi
}

alias    l='ls -lF'
alias   la='ls -laF'
alias   vi='vim'
alias wlst='rlwrap ${ORACLE_COMMON}/common/bin/wlst.sh'
alias   oh='cd ${ORACLE_HOME}; pwd'
alias  ohc='cd ${ORACLE_COMMON}; pwd'
alias   dh='cd ${DOMAIN_HOME}; pwd'
alias   dl='cd ${DOMAIN_LOG}; pwd'

# default env, feel free to change it
acc

