#!/bin/sh

echo
echo "Deployment for oracle.iam.ui.custom library"
echo "-------------------------------------------"
echo
echo "Have you placed your new version there...?"
echo "  /opt/fmw/products/identity/iam/server/apps/oracle.iam.ui.custom-dev-starter-pack.war"
echo
echo "Press ENTER to continue or Ctrl-C to stop"
read answer

${WL_HOME}/common/bin/wlst.sh -loadProperties ${IDM_PROP} ${HOME}/lib/deploy-custom.py

echo "Finished."

exit 0


