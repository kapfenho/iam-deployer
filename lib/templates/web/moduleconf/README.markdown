OHS HTTP Routing Configuration
==============================

This directory has the following file types:

    application definitions:  _app-name
    weblogic admin apps:      _wls-xxxdomain
    ssl definition:           _ssl
    virtual hosts:            vhost.conf

Each application has a definition file with all contexts needed for
routing. Here the connections to the WebLogic services are stored and
additional wls-plugin features may be configured.

Those app definitions are used (included) in virtual host definitions
and optionally extended by the SSL (TLS) features set.

One virtual host file shall map to one OHS/Apache virtual host
definition.

The main OHS config includes all files with a "conf" suffix. Rename 
unused vhosts files to another suffix.
