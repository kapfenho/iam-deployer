#########################################################################
#
#  functions for removing installed application 
#
# -----------------------------------------------------------------------
#  remove hostenvironment: ~/{bin,lib,.env,.creds}
#  Always returns 0
#
remove_env()
{
  set -o nounset
  : ${DEPLOYER:?}

  #  bin
  for f in $(ls ${DEPLOYER}/lib/templates/hostenv/bin/) ; do
    rm -f ~/bin/${f}
  done
  rmdir ~/bin 2>/dev/null || true
  #  lib
  for f in $(ls ${DEPLOYER}/lib/templates/hostenv/lib/) ; do
    rm -f ~/lib/${f}
  done
  rmdir ~/lib 2>/dev/null || true
  #  env
  for f in $(ls ${DEPLOYER}/lib/templates/hostenv/env/) ; do
    rm -f ~/.env/${f}
  done
  rmdir ~/.env 2>/dev/null || true
  #  cred
  rm -Rf ~/.cred 
}


# -----------------------------------------------------------------------
#  remove installation directories populated by LCM
#  Always returns 0
#
remove_iam()
{
  set -o nounset
  : ${iam_top:?}
  : ${iam_services:?}

  rm -Rf ${iam_top}/products/* \
         ${iam_top}/config/* \
         ${iam_top}/*.lck \
         ${iam_top}/lcm/lcmhome/provisioning/phaseguards/* \
         ${iam_top}/lcm/lcmhome/provisioning/provlocks/* \
         ${iam_top}/lcm/lcmhome/provisioning/logs/ \
         ${iam_services}/*
}

# -----------------------------------------------------------------------
#  remove LCM (life cycle manager) iam_base/lcm
#  binaries and home
#
remove_lcm()
{
  set -o nounset
  : ${iam_top:?}

  rm -Rf ${iam_top}/lcm/{lcm,lcmhome}
}

# -----------------------------------------------------------------------
#  remove OIA installation including including env
#  Always returns 0
#
remove_oia()
{
  set -o nounset
  : ${iam_top:?}
  : ${iam_log:?}
  : ${iam_services:?}
  : ${iam_rbacx_home:?}
  : ${iam_domain_oia:?}
  : ${IL_APP_CONFIG:?}
  : ${IDMPROV_OIA_HOST:?}

  rm -Rf ${iam_top}/products/analytics \
         ${iam_rbacx_home} \
         ${IL_APP_CONFIG}/oia.jar \
         ${iam_log}/${iam_domain_oia} \
         ${iam_services}/domains/${iam_domain_oia} \
         ~/.env/{oia.env,analytics.prop,oia.prop} \
         ~/bin/*analytics* \
         ~/lib/deploy-oia.py \
         ~/.cred/${iam_domain_oia}.{key,usr}

  echo "Removing domain from nodemanager"
  for f in ${iam_top}/config/nodemanager/${IDMPROV_OIA_HOST}/nodemanager.domains ; do
    sed -i -e /${iam_domain_oia}/d ${f}
  done

  echo
  echo "OIA binaries, webapp, domain and environment files removed."
  echo "Restart nodemanager now"
}

# -----------------------------------------------------------------------
#  call other remove functions for iam, lcm, env
#
remove_all()
{
  remove_iam
  remove_lcm
  remove_env
}

