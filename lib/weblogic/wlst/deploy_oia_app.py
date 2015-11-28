import os

createDomain=os.path.dirname(sys.argv[0]) +'/heinz/createDomain.py'
if os.path.exists(createDomain):
  execfile(createDomain)


# ================================================================
#           Main Code Execution
# ================================================================
if __name__== "main":
    print '###################################################################'
    print '#                   Application Deployment                        #'
    print '###################################################################'
    print ''

    intialize()
    connect(adminUserName, adminPassword, connUri);
    print 'Connected';
    deployAllApplications()
