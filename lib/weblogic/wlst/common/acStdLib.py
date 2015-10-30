#######################################################
#
#  Agora Con Standard Lib - Weblogic Scripting
#  
#  Copyright (c) 2015, AGORA CON GMBH
#  All rights reserved.
#  
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  
#  * Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#  
#  * Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#  
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
#  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

import os
import thread
import time
import socket

# get FQDN from machine
#
def acGetFQDN():
    return socket.getfqdn()

# connect to domain with preloaded properties
#
def acConnect():
    return connect(userConfigFile=domUC, userKeyFile=domUK, url=domUrl)

# connect to nodemanager-domain with preloaded properties
#
def acNmConnect():
    return nmConnect(userConfigFile=nmUC,userKeyFile=nmUK,host=acGetFQDN,port=nmPort,domainName=domName,domainDir=admDir,nmType='ssl');

# print status of domain and its servers, etc.
#
def acState():
    domainConfig()
    servers = cmo.getServers()
    for s in servers:
        state(s.getName())
        # cd("/ServerLifeCycleRuntimes/" + name.getName())
        # serverState = cmo.getState()
        # if serverState == "RUNNING":
        #     print 'Server ' + name.getName() + ' is :\033[1;32m' + serverState + '\033[0m'
        # elif serverState == "STARTING":
        #     print 'Server ' + name.getName() + ' is :\033[1;33m' + serverState + '\033[0m'
        # elif serverState == "UNKNOWN":
        #     print 'Server ' + name.getName() + ' is :\033[1;34m' + serverState + '\033[0m'
        # else:
        #     print 'Server ' + name.getName() + ' is :\033[1;31m' + serverState + '\033[0m'

# domain config functions

# apply the standard log settings to specific server
#   parameter: name of server
#
def acConfigServerLog(name):
    cd('/Servers/' + name + '/Log/' + name )
    cmo.setFileCount(7)
    cmo.setNumberOfFilesLimited(true)
    cmo.setRotateLogOnStartup(true)
    cmo.setRedirectStderrToServerLogEnabled(true)
    cmo.setRedirectStdoutToServerLogEnabled(true)
    # cmo.setFileName('/var/log/fmw/identitiy_test/AdminServer/AdminServer.log')

# apply the standard web logging settings to specific server
#   parameter: name of server
#
def acConfigServerWebLog(name):
    cd('/Servers/' + name + '/WebServer/' + name + '/WebServerLog/' + name )
    cmo.setFileCount(7)
    cmo.setNumberOfFilesLimited(true)
    cmo.setRotateLogOnStartup(true)
    # cmo.setFileName('/var/log/fmw/identitiy_test/AdminServer/http.log')

# apply the standard datasource logging settings to specific server
#   parameter: name of server
#
def acConfigServerDataSourceLog(name):
    cd('/Servers/' + name + '/DataSource/' + name + '/DataSourceLogFile/' + name )
    cmo.setFileCount(7)
    cmo.setNumberOfFilesLimited(true)
    cmo.setRotateLogOnStartup(true)
    # cmo.setFileName('/var/log/fmw/identitiy_test/AdminServer/datasource.log')

# enable the ssl port of admin server and set port number.
# Server lookup by name "AdminServer"
#   parameter: port number for ssl listener
#
def acConfigAdminServerSSL(port):
    cd('/Servers/AdminServer/SSL/AdminServer')
    cmo.setListenPort(port)
    # cmo.setJSSEEnabled(true)
    # cmo.setHostnameVerificationIgnored(false)

# shortcut function for restarting application (not server)
# using populated properties
#
def acRestartApp():
    stopApplication( appName,timeout=360000,block="true")
    startApplication(appName,timeout=360000,block="true")


