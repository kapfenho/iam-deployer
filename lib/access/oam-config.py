# configuration of access manager domain
#    
acConnect()

edit()
startEdit()

cd('/AdminConsole/'+domName)
cmo.setCookieName('OAMCONSOLESESS')

cd('/Clusters/oam_cluster')
cmo.setWeblogicPluginEnabled(true)

cd('/')
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

