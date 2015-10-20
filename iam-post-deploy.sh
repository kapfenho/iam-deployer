#!/bin/sh
#
# VWFS Post installation steps
# 
# Prerequisites:
# - there should be ssh-key communication available 
#   on hosts on which the deployment should be performed
#
export DEPLOYER
export PATH=${DEPLOYER}:${PATH}

#  deploy user environment
iam userenv -a env                                   ; r=$? ; [[ $r -gt 2 ]] && exit
iam userenv -a profile -H localhost                  ; r=$? ; [[ $r -gt 2 ]] && exit

#  copy weblogic libraries
iam weblogic -a wlstlibs -t identity -H localhost    ; r=$? ; [[ $r -gt 2 ]] && exit

#  upgrade jdk 
iam jdk -H localhost -O identity                     ; r=$? ; [[ $r -gt 2 ]] && exit

#  identity domain PSA run
iam identity -a psa                                  ; r=$? ; [[ $r -gt 2 ]] && exit

#  identity domain nodemanager and domain keyfiles
iam keyfile -t nodemanager -H localhost -D identity  ; r=$? ; [[ $r -gt 2 ]] && exit
iam keyfile -t domain -D identity                    ; r=$? ; [[ $r -gt 2 ]] && exit

#  identity domain post-install steps
iam identity -a postinstall                          ; r=$? ; [[ $r -gt 2 ]] && exit
iam identity -a movelogs -H localhost                ; r=$? ; [[ $r -gt 2 ]] && exit
iam identity -a jdk7fix -t identity -H localhost     ; r=$? ; [[ $r -gt 2 ]] && exit

#  patch weblogic java environment
iam weblogic -a jdk7fix -t identity -H localhost     ; r=$? ; [[ $r -gt 2 ]] && exit

#  webgate installation bug fix
iam webtier -a postinstall                           ; r=$? ; [[ $r -gt 2 ]] && exit
iam webtier -a movelogs -h localhost

