# deploy runlevel scripts - manual approach 
#
#   run on projekt root
#
set -o errexit
set -x

# dwptoam1
#
ssh dwptoam1 -- mkdir -p /etc/weblogic

scp user-conf/rc.d/iam-node           dwptoam1:/etc/rc.d/init.d/ 
scp user-conf/rc.d/oam1/iama-admin    dwptoam1:/etc/rc.d/init.d/ 
scp user-conf/rc.d/oam1/iama-oam      dwptoam1:/etc/rc.d/init.d/ 
scp user-conf/rc.d/oam1/wls-access    dwptoam1:/etc/weblogic/ 

ssh dwptoam1 -- chmod 0755 /etc/rc.d/init.d/{iam-node,iama-admin,iama-oam}
ssh dwptoam1 -- chmod 0755 /etc/weblogic
ssh dwptoam1 -- chmod 0644 /etc/weblogic/wls-access

ssh dwptoam1 -- chkconfig --add iam-node
ssh dwptoam1 -- chkconfig --add iama-admin
ssh dwptoam1 -- chkconfig --add iama-oam

# dwptoam2
#
ssh dwptoam2 -- mkdir -p /etc/weblogic

scp user-conf/rc.d/iam-node           dwptoam2:/etc/rc.d/init.d/ 
scp user-conf/rc.d/oam2/iama-oam      dwptoam2:/etc/rc.d/init.d/ 
scp user-conf/rc.d/oam2/wls-access    dwptoam2:/etc/weblogic/

ssh dwptoam2 -- chmod 0755 /etc/rc.d/init.d/{iam-node,iama-oam}
ssh dwptoam2 -- chmod 0755 /etc/weblogic
ssh dwptoam2 -- chmod 0644 /etc/weblogic/wls-access

ssh dwptoam2 -- chkconfig --add iam-node
ssh dwptoam2 -- chkconfig --add iama-oam


# dwptoim1
#
ssh dwptoim1 -- mkdir -p /etc/weblogic

scp user-conf/rc.d/iam-node           dwptoim1:/etc/rc.d/init.d/ 
scp user-conf/rc.d/oim1/iami-admin    dwptoim1:/etc/rc.d/init.d/ 
scp user-conf/rc.d/oim1/iami-soa      dwptoim1:/etc/rc.d/init.d/ 
scp user-conf/rc.d/oim1/iami-oim      dwptoim1:/etc/rc.d/init.d/ 
scp user-conf/rc.d/oim1/wls-identity  dwptoim1:/etc/weblogic/ 

ssh dwptoim1 -- chmod 0755 /etc/rc.d/init.d/{iam-node,iami-admin,iami-soa,iami-oim}
ssh dwptoim1 -- chmod 0755 /etc/weblogic
ssh dwptoim1 -- chmod 0644 /etc/weblogic/wls-identity

ssh dwptoim1 -- chkconfig --add iam-node
ssh dwptoim1 -- chkconfig --add iami-admin
ssh dwptoim1 -- chkconfig --add iami-soa
ssh dwptoim1 -- chkconfig --add iami-oim


# dwptoim2
#
ssh dwptoim2 -- mkdir -p /etc/weblogic

scp user-conf/rc.d/iam-node           dwptoim2:/etc/rc.d/init.d/ 
scp user-conf/rc.d/oim2/iami-soa      dwptoim2:/etc/rc.d/init.d/ 
scp user-conf/rc.d/oim2/iami-oim      dwptoim2:/etc/rc.d/init.d/ 
scp user-conf/rc.d/oim2/wls-identity  dwptoim2:/etc/weblogic/ 

ssh dwptoim2 -- chmod 0755 /etc/rc.d/init.d/{iam-node,iami-soa,iami-oim}
ssh dwptoim2 -- chmod 0755 /etc/weblogic
ssh dwptoim2 -- chmod 0644 /etc/weblogic/wls-identity

ssh dwptoim2 -- chkconfig --add iam-node
ssh dwptoim2 -- chkconfig --add iami-soa
ssh dwptoim2 -- chkconfig --add iami-oim


# dwptidw1
#
scp user-conf/rc.d/web1/iam-web       dwptidw1:/etc/rc.d/init.d/ 
ssh dwptidw1 -- chmod 0755 /etc/rc.d/init.d/iam-web
ssh dwptidw1 -- chkconfig --add iam-web

# dwptidw2
#
scp user-conf/rc.d/web2/iam-web       dwptidw2:/etc/rc.d/init.d/ 
ssh dwptidw2 -- chmod 0755 iam-web
ssh dwptidw2 -- chkconfig --add /etc/rc.d/init.d/iam-web

# dwptoud1
#
scp user-conf/rc.d/oud1/iam-dir       dwptoud1:/etc/rc.d/init.d/ 
ssh dwptoud1 -- chmod 0755 /etc/rc.d/init.d/iam-dir
ssh dwptoud1 -- chkconfig --add iam-dir

# dwptoud2
#
scp user-conf/rc.d/oud2/iam-dir       dwptoud2:/etc/rc.d/init.d/ 
ssh dwptoud2 -- chmod 0755 /etc/rc.d/init.d/iam-dir
ssh dwptoud2 -- chkconfig --add iam-dir

set +x

