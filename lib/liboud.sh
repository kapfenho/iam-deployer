# oud functions

apply_oud_tls_settings() {

  # for ldaps
  dsconfig set-connection-handler-prop \
    --handler-name LDAPS\ Connection\ Handler \
    --add ssl-protocol:TLSv1 \
    --add ssl-protocol:TLSv1.1 \
    --add ssl-protocol:TLSv1.2 \
    --trustAll \
    --no-prompt

  # for starttls
  dsconfig set-connection-handler-prop \
    --handler-name LDAP\ Connection\ Handler \
    --add ssl-protocol:TLSv1 \
    --add ssl-protocol:TLSv1.1 \
    --add ssl-protocol:TLSv1.2 \
    --trustAll \
    --no-prompt
    
  # for replication
  dsconfig set-crypto-manager-prop \
    --add ssl-protocol:TLSv1 \
    --add ssl-protocol:TLSv1.1 \
    --add ssl-protocol:TLSv1.2 \
    --trustAll \
    --no-prompt 

}


