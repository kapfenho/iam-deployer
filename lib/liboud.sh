# oud functions

patch_oud_post_inst() {

  local c="dsconfig set-access-control-handler-prop --no-prompt"

  ${c} --remove global-aci:"(target=\"ldap:///cn=changelog\")(targetattr=\"*\")(version 3.0; acl \"External changelog access\"; deny(all) userdn=\"ldap:///anyone\";)"
  ${c} --add    global-aci:"(target=\"ldap:///cn=changelog\")(targetattr=\"*\")(version 3.0; acl \"External changelog access\"; allow(read,search,compare,add,write,delete,export) groupdn=\"ldap:///cn=OIMAdministrators,cn=Groups,dc=dwpbank,dc=net\";)"

  ${c} --remove global-aci:"(targetcontrol=\"1.3.6.1.1.12 || 1.3.6.1.1.13.1 || 1.3.6.1.1.13.2 || 1.2.840.113556.1.4.319 || 1.2.826.0.1.3344810.2.3 || 2.16.840.1.113730.3.4.18 || 2.16.840.1.113730.3.4.9 || 1.2.840.113556.1.4.473 || 1.3.6.1.4.1.42.2.27.9.5.9\") (version 3.0; acl \"Authenticated users control access\"; allow(read) userdn=\"ldap:///all\";)"
  ${c} --add    global-aci:"(targetcontrol=\"1.3.6.1.1.12 || 1.3.6.1.1.13.1 || 1.3.6.1.1.13.2 || 1.2.826.0.1.3344810.2.3 || 2.16.840.1.113730.3.4.18 || 2.16.840.1.113730.3.4.9 || 1.2.840.113556.1.4.473 || 1.3.6.1.4.1.42.2.27.9.5.9\") (version 3.0; acl \"Authenticated users control access\"; allow(read) userdn=\"ldap:///all\";)"

  ${c} --remove global-aci:"(targetcontrol=\"2.16.840.1.113730.3.4.2 || 2.16.840.1.113730.3.4.17 || 2.16.840.1.113730.3.4.19 || 1.3.6.1.4.1.4203.1.10.2 || 1.3.6.1.4.1.42.2.27.8.5.1 || 2.16.840.1.113730.3.4.16 || 2.16.840.1.113894.1.8.31\") (version 3.0; acl \"Anonymous control access\"; allow(read) userdn=\"ldap:///anyone\";)"
  ${c} --add    global-aci:"(targetcontrol=\"2.16.840.1.113730.3.4.2 || 2.16.840.1.113730.3.4.17 || 1.2.840.113556.1.4.319 || 2.16.840.1.113730.3.4.19 || 1.3.6.1.4.1.4203.1.10.2 || 1.3.6.1.4.1.42.2.27.8.5.1 || 2.16.840.1.113730.3.4.16 || 2.16.840.1.113894.1.8.31\") (version 3.0; acl \"Anonymous control access\"; allow(read) userdn=\"ldap:///anyone\";)"
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

