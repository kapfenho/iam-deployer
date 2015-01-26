# configuration of access manager domain
#    
acConnect()

edit()
startEdit()

cd('/AdminConsole/access_test')
cmo.setCookieName('OAMCONSOLESESS')

cd('/Clusters/oam_cluster')
cmo.setWeblogicPluginEnabled(true)

servers = cmo.getServers()
for s in servers:
    srvName = s.getName()
    acConfigServerLog(srvName)
    acConfigServerWebLog(srvName)
    acConfigServerDataSourceLog(srvName)
    cd('/Servers/' + srvName)
    cmo.setWeblogicPluginEnabled(true)


acConfigAdminServerSSL(7002)

save()
activate()

