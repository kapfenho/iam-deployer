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

    # print "> checking for deployment structure..."
    # os.system("mkdir -p "+appDir+"/{new,current,archive}")

    acConnect()
    print "> undeploying application..."
    undeployApp()

    # print "> archiving current version..."
    # os.system("cp -Rp "+appDir+"/current "+appDir+
    #     "/archive/$(date ""+%Y%m%d-%H%M%S"")")
    #
    # print "> removing current version..."
    # os.system("rm -f "+appPath)
    #
    # print "> moving new version to current..."
    # os.system("mv "+appDir+"/new/* "+appDir+"/current/")

    print "> deploying..."
    deployApp()

    print "> successfully finished!"
    print

    exit()

