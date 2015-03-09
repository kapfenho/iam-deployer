#  deploy applications on weblogic
#  (c) agoracon.at 2014
#  

import os
import time
import sys

from java.util import Date
from java.text import SimpleDateFormat

def prep():
    os.system("mkdir -p "+appDir+"/{new,current,archive}")
    os.system("cp -Rp "+appDir+"/current "+appDir+
    "/archive/$(date ""+%Y%m%d-%H%M%S"")")
    os.system("rm -f "+appPath)
    os.system("mv "+appDir+"/new/* "+appDir+"/current/")

def undeployApp():
    try:
        progress=stopApplication(appName,timeout=360000,block="true")
        progress.printStatus()
        progress=undeploy(appName,timeout=360000,block="true")
        progress.printStatus()
    except:
        print "*** Warning: Problems during undeployment"
        print dumpStack()

def deployApp():
    try:
        progress=deploy(appName=appName,path=appPath,planPath=appPlan,targets=appTargets,timeout=360000,block="true")
        progress.printStatus()
        startApplication(appName,timeout=360000,block="true")
    except:
        print "*** Error: during deployment"
        print dumpStack()


if __name__== "main":
    prep()
    connect(userConfigFile=defUC,userKeyFile=defUK,url=defAdminURL)
    undeployApp()
    deployApp()
    exit()

