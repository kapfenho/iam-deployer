# oud functions

patch_oud_post_inst() {
  local c="dsconfig set-access-control-handler-prop -X --hostname $(hostname --long) --no-prompt"

  ${c} --remove global-aci:"(target=\"ldap:///cn=changelog\")(targetattr=\"*\")(version 3.0; acl \"External changelog access\"; deny (all) userdn=\"ldap:///anyone\";)"
  ${c} --add    global-aci:"(target=\"ldap:///cn=changelog\")(targetattr=\"*\")(version 3.0; acl \"External changelog access\"; allow (read,search,compare,add,write,delete,export) groupdn=\"ldap:///cn=OIMAdministrators,cn=groups,dc=dwpbank,dc=net\";)"
  echo "Dont forget to correct 1.2.840.113556.1.4.319!"
  echo
}


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



