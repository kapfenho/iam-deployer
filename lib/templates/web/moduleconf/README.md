OHS HTTP Routing Configuration
==============================

The struture of this folder shall enable you to maintain a flexible 
configuration, that is easy to extend and deploy to additional
instances.

This directory has the following file types:

    application definitions:  apps/app-*
    weblogic admin apps:      apps/wls-*
    ssl definition:           apps/ssl
    virtual hosts:            vhost.conf

Each application has a definition file with all contexts needed for
routing. There the connections to the WebLogic services are stored and
additional wls-plugin features may be configured.  Those app definitions 
are included in virtual host definitions.

One virtual host file shall map to one OHS/Apache virtual host
definition. In case a vhost shall serve HTTPS include the apps/ssl 
definition inside the vhost.

The main OHS config httpd.conf can either include each vhost config 
file individually or includes all files with a "conf" suffix.


Secondary Domains
-----------------

In this context a secondary domain is an additional domain or hostname
the users will use for accessing the user interface.

For each secondary domain a copy of the final `idm.conf` shall be
created with the following changes of its content:

1. Change the `ServerName` to the new value

2. Add a substitute rule at the end of the `VirtualHost` definition
   (still inside the definition):

    <Location />
        SetOutputFilter SUBSTITUTE
        Substitute s/<original_fqdn>/<new_fqdn>/q
    </Location>

You need to replace the variables `<original_fqdn>` and `<new_fqdn>`.
Example:

    <Location />
        SetOutputFilter SUBSTITUTE
        Substitute s/identity.iamvs.agoracon.at/identity.iamvs.n00.at/q
    </Location>


Redirect on Secondary Domains
-----------------------------

Another option for to work with secondary domains is an immediate
redirect on the first request.  The user can use and bookmark URI using
a secondary domain, but each session will always switch immediatelly to
primary domain.

The can be achived by secondary domains as virtual host like this:


    <VirtualHost *:7777>
        ServerName identity.secondary.example.com
        RewriteEngine On
        RewriteRule (.*) https://identity.primary.example.com/$1 [R,L]
    </VirtualHost>

Secondary domains don't need to be covered by Access Manager and no DCC
is needed.

