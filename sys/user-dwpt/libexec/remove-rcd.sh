# remove old runlevel scripts
#
set -o errexit
set -x

# dwptoam1
#
ssh dwptoam1 -- chkconfig --del iamadmin
ssh dwptoam1 -- chkconfig --del iamoam
ssh dwptoam1 -- chkconfig --del iamnm
ssh dwptoam1 -- rm -f /etc/rc.d/init.d/iam{admin,oam,soa,oim,nm}
ssh dwptoam1 -- rm -f /etc/rc.d/init.d/{wls-access,wls-identity,functions-wls}

# dwptoam2
#
ssh dwptoam2 -- chkconfig --del iamoam
ssh dwptoam2 -- chkconfig --del iamnm
ssh dwptoam2 -- rm -f /etc/rc.d/init.d/iam{admin,oam,soa,oim,nm}

# dwptoim1
#
ssh dwptoim1 -- chkconfig --del iamadmin
ssh dwptoim1 -- chkconfig --del iamoim
ssh dwptoim1 -- chkconfig --del iamsoa
ssh dwptoim1 -- chkconfig --del iamnm
ssh dwptoim1 -- rm -f /etc/rc.d/init.d/iam{admin,oam,soa,oim,nm}
ssh dwptoim1 -- rm -f /etc/rc.d/init.d/{wls-access,wls-identity,functions-wls}

# dwptoim2
#
ssh dwptoim2 -- chkconfig --del iamoim
ssh dwptoim2 -- chkconfig --del iamsoa
ssh dwptoim2 -- chkconfig --del iamnm
ssh dwptoim2 -- rm -f /etc/rc.d/init.d/iam{admin,oam,soa,oim,nm}
ssh dwptoim2 -- rm -f /etc/rc.d/init.d/{wls-access,wls-identity,functions-wls}

# dwptidw1
#
ssh dwptidw1 -- chkconfig --del iamweb
ssh dwptidw1 -- rm -f /etc/rc.d/init.d/iam{admin,oam,soa,oim,nm,web,dir}
ssh dwptidw1 -- rm -f /etc/rc.d/init.d/{wls-access,wls-identity,functions-wls}

# dwptidw2
#
ssh dwptidw2 -- chkconfig --del iamweb
ssh dwptidw2 -- rm -f /etc/rc.d/init.d/iam{admin,oam,soa,oim,nm,web,dir}
ssh dwptidw2 -- rm -f /etc/rc.d/init.d/{wls-access,wls-identity,functions-wls}

# dwptoud1
#
ssh dwptoud1 -- chkconfig --del iamdir
ssh dwptoud1 -- rm -f /etc/rc.d/init.d/iam{admin,oam,soa,oim,nm,web,dir}
ssh dwptoud1 -- rm -f /etc/rc.d/init.d/{wls-access,wls-identity,functions-wls}

# dwptoud2
#
ssh dwptoud2 -- chkconfig --del iamdir
ssh dwptoud2 -- rm -f /etc/rc.d/init.d/iam{admin,oam,soa,oim,nm,web,dir}
ssh dwptoud2 -- rm -f /etc/rc.d/init.d/{wls-access,wls-identity,functions-wls}

set +x

