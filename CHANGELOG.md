Changelog
=========

2016-02-11  Load Balancer added
            The script will install haproxy and create a new instance
            listening on http/80. Requests are forwarded to web1:7777
            and web2:7777. Run as root:
                lib/templates/root/setup-proxy.sh

2016-02-11  PS3: provisioning of cluster was successful. We need to skip 
            last step (verification), since health checks can only be 
            executed. Instance: iamvc-ps3
            
2016-02-12  Health-Check: a new subcommand is calling the Oracle Health 
            Checks in all currently possible variations. Call it instead 
            the broken postinstall verification phase (last phase)
