# configuration of identity manager domain
#    
acConnect()

edit()
startEdit()

cd('/AdminConsole/identity_test')
cmo.setCookieName('OIMADMINCONSSESS')

cd('/JDBCSystemResources/oimOperationsDB/JDBCResource/oimOperationsDB/JDBCConnectionPoolParams/oimOperationsDB')
cmo.setMinCapacity(5)
cmo.setInitialCapacity(5)

cd('/Clusters/soa_cluster')
cmo.setWeblogicPluginEnabled(true)
cd('/Clusters/oim_cluster')
cmo.setWeblogicPluginEnabled(true)

servers = cmo.getServers()
for s in servers:
    srvName = s.getName()
    acConfigServerLog(srvName)
    acConfigServerWebLog(srvName)
    acConfigServerDataSourceLog(srvName)
    cd('/Servers/' + srvName)
    cmo.setWeblogicPluginEnabled(true)


acConfigAdminServerSSL(7102)

save()
activate()

