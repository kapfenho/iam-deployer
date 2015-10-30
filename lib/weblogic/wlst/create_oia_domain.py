import os

createDomain=os.path.dirname(sys.argv[0]) +'/heinz/createDomain.py'
if os.path.exists(createDomain):
  execfile(createDomain)

# update Nodemanager credentials for new domain
def updateNmUser():
    print "Updating Nodemanager Username and password"
    edit()
    startEdit()
    cd("/SecurityConfiguration/" + domainProps.getProperty('domainName'))
    cmo.setNodeManagerUsername("admin")
    cmo.setNodeManagerPassword(adminPassword)
    save()
    activate()

# do enroll on local machine
def enrollNm():
    nrMachines = domainProps.getProperty('amountMachine')

    machine = 1
    while (machine <= int(nrMachines)):
        nmDir = get_instance_property('machine', str(machine), 'nmDir')
        print ' Do enroll '+ domainLocation +'  -  '+ nmDir +' !\n'
        nmEnroll(domainLocation, nmDir)

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
    enrollNm()
    setJTATimeout()
    createAllDatasources()
