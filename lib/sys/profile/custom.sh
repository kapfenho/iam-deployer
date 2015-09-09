umask 0007
set bell-style off

BLOCKSIZE=K;           export BLOCKSIZE
   EDITOR=vim;         export EDITOR
    PAGER=less;        export PAGER
 CLICOLOR=1;           export CLICOLOR
     LESS="-R";        export LESS
   LC_ALL=en_US.UTF-8; export LC_ALL
     LANG=en_US.UTF-8; export LANG

PS1='[\e[0;31m\u\[\e[m\]@\h:\[\e[0;32m\]${E}\[\e[m\] \W]\$ '
export PS1

alias  l='ls -lF'
alias ll='ls -lF'
alias la='ls -laF'

