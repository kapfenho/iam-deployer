#!/usr/bin/env wlst

import sys
import os

from java.util import Properties
from javax.management import *   
from java.io import FileInputStream

propFile = os.getcwd() + "/user-config/iam/perstore.properties"

createDomain=os.path.dirname(sys.argv[0]) +'/heinz/createDomain.py'
if os.path.exists(createDomain):
    execfile(createDomain)
else:
    print "Please provide the properties file."
    print "USAGE: create_oia_domain.py $properties/file/path"
    sys.exit(0)


def init ():
    input = FileInputStream(propFile)
    global domainProps, adminURL, adminUser, adminPassword
    global clusterName, dataSourceName

    domainProps = Properties()
    domainProps.load(input)
    input.close()

    adminURL = 't3://' + domainProps.get('adminserver.listenAddress') 
    adminURL += ':' + domainProps.get('adminserver.listenPort')
    adminUser = domainProps.get('adminserver.user')
    adminPassword = domainProps.get('adminserver.pass')
    clusterName = domainProps.get('clusterName')
    dataSourceName = domainProps.get("jdbcDatasourceName")


def wlsConnect():
    try:
        connect(adminUser, adminPassword, adminURL)

    except:
        print "Could not connect to AdminServer.."
        dumpStack()


def moveJMSPersistentStores():

    try:
        print "### Moving JMS Persistent File Stores to JDBC stores.."
        jmsServers = cmo.getJMSServers()

        for jmsServer in jmsServers:
            
            edit()
            startEdit()
            # take only the JMSServer name, without prefixes/suffixes
            jmsServerName = jmsServer.getName()[:3]
            jmsObjectName = jmsServer.getObjectName().toString()
            jmsStoreName = jmsServerName + "JDBCStore"
            
            print "jmsStoreName: " + jmsStoreName
            print "jmsObjectName: " + jmsObjectName
            
            cd('/')
            cmo.createJDBCStore(jmsStoreName)
            cd('/JDBCStores/' + jmsStoreName)
            cmo.setDataSource(getMBean('/SystemResources/' + dataSourceName))
            cmo.setPrefixName('JMS_' + jmsStoreName)

            print "set target"
            # there is always only one target
            #cmo.setTargets(jmsServer.getTargets()[0].getName())
            msObjectName = 'com.bea:Name=' + jmsServer.getTargets()[0].getName()+ ',Type=Server'
            set('Targets',jarray.array([ObjectName(msObjectName)], ObjectName))
            # get created Store object
            jmsStore=cmo

            print "set store"

            cd('/JMSServers/' + jmsServer.getName())
            #jmsStoreObjectName = 'com.bea:Name=' + jmsStoreName + ',Type=JDBCStore'
            jmsStoreObjectName = jmsStore.getObjectName().toString()
            #print "jmsStoreObjectName: " + jmsStoreObjectName
            #set('PersistentStore',jarray.array([ObjectName(jmsStoreObjectName)], ObjectName))
            cmo.setPersistentStore(jmsStore)
            print "set store after"
            print "### created JDBC persistent store " + jmsStoreName
            save()
            activate()
    except:
        print "### exception while creating JDBC persistence store!"
        dumpStack()



def createJDBCPersistentStore():

    try:
        print "### creating JDBC persistent store.."
        cd('Clusters/' + clusterName)
        managedServers = cmo.getServers()
        i = 1
        for managedServer in managedServers:
            edit()
            startEdit()
            managedServerName = managedServer.getName()
            cd('/')
            cmo.createJDBCStore('JDBCStore_' + str(i))
            cd('/JDBCStores/JDBCStore_' + str(i))
            cmo.setDataSource(getMBean('/SystemResources/'+dataSourceName))
            cmo.setPrefixName('JMS'+str(i))
            msObjectName = 'com.bea:Name=' + managedServerName + ',Type=Server'
            set('Targets',jarray.array([ObjectName(msObjectName)], ObjectName))
            print "### created JDBC persistent store"
            i = i + 1
            save()
            activate()

    except:
        print "### exception while creating JDBC persistence store!"
        dumpStack()


# everything that is commented out should not be used for now!
#### start script ###
if __name__ == "main":
    init()
    wlsConnect()
    #createAllDatasources()
    createJDBCPersistentStore()
    moveJMSPersistentStores()
    #disconnect()
    #### end script ###
