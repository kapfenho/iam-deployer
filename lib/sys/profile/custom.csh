umask 0007
set bell-style off

setenv BLOCKSIZE K
setenv    EDITOR vim
setenv     PAGER less
setenv  CLICOLOR 1
setenv      LESS "-R"
setenv    LC_ALL en_US.UTF-8
setenv      LANG en_US.UTF-8

setenv PS1 '[\e[0;31m\u\[\e[m\]@\h:\[\e[0;32m\]${E}\[\e[m\] \W]\$ '

alias  l 'ls -lF'
alias ll 'ls -lF'
alias la 'ls -laF'

