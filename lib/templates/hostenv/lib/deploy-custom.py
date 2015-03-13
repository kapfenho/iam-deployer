#  deploy applications on weblogic
#  (c) agoracon.at 2015
#
#  For each application an WLST properties-file shall exists and
#  preloaded. Following application variables are needed - sample
#  data shown:
#
#    appName=imint
#    appArchive=imint.war
#    appDir=/opt/fmw/config/deploy/imint
#    appPath=/opt/fmw/config/deploy/imint/current/imint.war
#    appPlan=/opt/fmw/config/deploy/imint/current/plan/Plan.xml
#    appTargets=wls_oim1
#

import os
import time
import sys

from java.util import Date
from java.text import SimpleDateFormat

# stop applications:
#   oracle.iam.console.identity.sysadmin.ear (V2.0)
#   oracle.iam.console.identity.self-service.ear (V2.0)
#
def stopApps():
    try:
        stopApplication("oracle.iam.console.identity.self-service.ear#V2.0",
                timeout=360000,block="true")
        stopApplication("oracle.iam.console.identity.sysadmin.ear#V2.0",
                timeout=360000,block="true")
    except:
        pass


# start applications:
#   oracle.iam.console.identity.sysadmin.ear (V2.0)
#   oracle.iam.console.identity.self-service.ear (V2.0)
#
def startApps():
    try:
        startApplication("oracle.iam.console.identity.self-service.ear#V2.0",
                timeout=360000,block="true")
        startApplication("oracle.iam.console.identity.sysadmin.ear#V2.0",
                timeout=360000,block="true")
    except:
        pass

# deploy custom ui lib
#
def deployCustomLib():
    try:
        deploy(appName="oracle.iam.ui.custom#11.1.1@11.1.1",
                path="/opt/fmw/products/identity/iam/server/apps/oracle.iam.ui.custom-dev-starter-pack.war",
                targets="oim_cluster",
                timeout=360000,
                block="true")
    except:
        print "*** Error: during deployment"
        print dumpStack()


# main program
#
if __name__== "main":
    print
    print "*** Weblogic Deployment ***"
    print

    acConnect()
    print ">> stopping applications..."
    stopApps()

    print ">> deploying..."
    deployCustomLib()

    print ">> starting applications..."
    startApps()

    print ">> successfully finished!"
    print

    exit()


