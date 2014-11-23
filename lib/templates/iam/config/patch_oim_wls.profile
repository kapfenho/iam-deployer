# file: $OIM_ORACLE_HOME/server/bin/patch_oim_wls.profile
#
#  used for applying patches to domains
#
#  passwords: fill password lines or comment out

ant_home=/appl/iam/fmw/products/identity/modules/org.apache.ant_1.7.1
java_home=/appl/iam/fmw/products/identity/jdk/current
mw_home=/appl/iam/fmw/products/identity
oim_oracle_home=/appl/iam/fmw/products/identity/iam
soa_home=/appl/iam/fmw/products/identity/soa
weblogic.server.dir=/appl/iam/fmw/products/identity/wlserver_10.3

weblogic_user=weblogic
# weblogic_password=
soa_host=iam2.agoracon.at
soa_port=8001

operationsDB.user=DEVI_OIM
# OIM.DBPassword=
operationsDB.host=iam2.agoracon.at
operationsDB.serviceName=lunes
operationsDB.port=1521

mdsDB.user=DEVI_MDS
# mdsDB.password=
mdsDB.host=iam2.agoracon.at
mdsDB.port=1521
mdsDB.serviceName=lunes

oim_username=xelsysadm
# oim_password=
oim_serverurl=t3://iam2.agoracon.at:7101
