#  deploy analytics applications on weblogic, horst@agoracon.at
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

def undeployApp():
    try:
        stopApplication(appName,timeout=360000,block="true")
        undeploy(appName,timeout=360000,block="true")
    except:
        pass

def deployApp():
    try:
        deploy(appName=appName,
                path=appPath,
                targets=appTargets,
                upload='false',
                stageMode='nostage',
                timeout=360000,
                block="true")
        startApplication(appName,timeout=360000,block="true")
    except:
        print "*** Error: during deployment"
        print dumpStack()


if __name__== "main":
    force = 0
    print 
    print "*** Weblogic Deployment ***"
    print
    acConnect()
    print "> undeploying application..."
    undeployApp()
    print "> deploying..."
    deployApp()
    print "> successfully finished!"
    print
    exit()

