import os

createDomain=os.path.dirname(sys.argv[0]) +'/heinz/createDomain.py'
if os.path.exists(createDomain):
  execfile(createDomain)


def updateNmProperties():
    print "Updating NodeManager username and password for " + DomainLocation
    edit()
    startEdit()
    cd("SecurityConfiguration/oia_iamv2")
    cmo.setNodeManagerUsername("admin")
    cmo.setNodeManagerPassword(adminPassword)
    save()
    activate()


# ================================================================
#           Main Code Execution
# ================================================================
if __name__== "main":
    print '###################################################################'
    print '#                   Domain Creation                               #'
    print '###################################################################'
    print ''

    intialize()
    createCustomDomain()
    createAllBootProperties()
    startAndConnnectToAdminServer()
    # do enroll on local machine
    print ' Do enroll '+ domainLocation +'  -  '+ domainProps.getProperty('nmDir')+' !\n'
    nmEnroll(domainLocation, domainProps.getProperty('nmDir'))
    updateNmProperties()
    setJTATimeout()
    createAllDatasources()
