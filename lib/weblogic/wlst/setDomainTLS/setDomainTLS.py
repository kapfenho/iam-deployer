#!/usr/bin/env wlst

import os, sys, re 
import threading
from java.io import *

def setDomainKeystores(idstore, idpwd, tstore, tpwd, key, keypwd):
    
    cd('/Servers')
    servers = ls(returnMap='true')

    for server in servers:
        print server
        cd('/Servers/' + server)
        set("KeyStores", "CustomIdentityAndCustomTrust")
        
        set("CustomIdentityKeyStoreFileName", idstore)
        set("CustomIdentityKeyStorePassPhrase", idpwd)
        set("CustomIdentityKeyStoreType", "JKS")
        set("CustomTrustKeyStoreFileName", tstore)
        set("CustomTrustKeyStorePassPhrase", tpwd)
        set("CustomIdentityKeyStoreType", "JKS")
        
        cd('SSL/' + cmo.getName())
        set("ServerPrivateKeyAlias", key)
        set("ServerPrivateKeyPassPhrase", keypwd)
        set("JSSEEnabled", "true")
        
        if server == 'AdminServer':
            set("Enabled", "true")

        set("HostnameVerificationIgnored", "false")
        set("HostnameVerifier", "BEAHostNameVerifier")
    

def setSecureOUD(oudPort):    
    cd('/SecurityConfiguration/' + domName + '/Realms/myrealm/AuthenticationProviders/OUDAuthenticator')
    set("SSLEnabled", "true")
    cmo.setPort(int(oudPort))


if __name__== "main":
    edit()
    startEdit()

    print "Keystore setup for Weblogic domains"
    print "-----------------------------------"

    print "I git this information already:"

    print " trust keystore file:    " + trustKeystore
    print " identity keystore file: " + idKeystore
    print " private key alias:      " + keyAlias

    print "I need this information: "
    print "- trust keystore password"
    print "- identity keystore password"
    print "- private key password"

    print "We are now configuring domain " + domName
    print                   ("(to exit press <C-c>")

    trustPass = raw_input("--> trust keystore password    (printed!) : ")
    idPass    = raw_input("--> identity keystore password (printed!) : ")
    keyPass   = raw_input("--> private key password       (printed!) : ")

    setDomainKeystores(idKeystore, idPass, trustKeystore, trustPass, keyAlias,
            keyPass)

    setSecureOUD(oudPort)

    save()
    activate()
    exit()
