import os

createDomain=os.path.dirname(sys.argv[0]) +'/heinz/createDomain.py'
if os.path.exists(createDomain):
  execfile(createDomain)


def updateNmUser():
    print "Updating Nodemanager Username and password"
    edit()
    startEdit()
    cmo.setNodeManagerUsername("admin")
    cmo.setNodeManagerPassword(AdminPassword)
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
    updateNmUser()
    # do enroll on local machine
    print ' Do enroll '+ domainLocation +'  -  '+ domainProps.getProperty('nmDir')+' !\n'
    nmEnroll(domainLocation, domainProps.getProperty('nmDir'))
    setJTATimeout()
    createAllDatasources()
