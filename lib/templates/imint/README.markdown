Imint Configuration
-------------------

The application expects two system properties when running on
application server (like Weblogic).

```
imint.env={development|test|production|...}
imint.config=/opt/fmw/config/deploy/imint/current/config/imint.yml
```

A proper way setting the properties is to add them in

  Weblogic console -> Server -> Configuration -> 
    Server Start -> Arguments

like:

```
-Djps.subject.cache.key=5 -Djps.subject.cache.ttl=600000
-Dimint.env=production
-Dimint.config=/opt/fmw/config/deploy/imint/current/config/imint.yml
```

_Attention:_ use a blank between properties, no LF.

Those settings are stored in 

    $DOMAIN/servers/wls_oim1/data/nodemanager/startup.properties

