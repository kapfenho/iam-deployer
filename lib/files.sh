# config settings for Oracle Database installation
# 

# scripts location
                     base=/vagrant
              MNT_SCRIPTS=${base}/lib
                  SYS_DIR=${base}/sys/redhat
                  LIB_DIR=${base}/lib
             TEMPLATE_DIR=${LIB_DIR}/templates
                 RESP_DIR=${LIB_DIR}/resp 

                 MISC_DIR=${LIB_DIR}/misc
                 INIT_DIR=${LIB_DIR}/init.d
                  s_certs=${LIB_DIR}/certs

             RESP_WLS_IDM=${RESP_DIR}/wls_install_idm.xml
             RESP_WLS_OWT=${RESP_DIR}/wls_install_owt.xml
             RESP_WLS_IAM=${RESP_DIR}/wls_install_iam.xml
                  RESP_DB=${RESP_DIR}/db_install.rsp
                 RESP_IAM=${RESP_DIR}/iam_install.rsp
                 RESP_IDM=${RESP_DIR}/idm_install.rsp
                 RESP_SOA=${RESP_DIR}/soa_install.rsp
                 resp_owt=${RESP_DIR}/owt/owt_install.rsp
             resp_owt_cfg=${RESP_DIR}/owt/owt_create_instance.rsp
           RESP_ORAINVPTR=${TEMPLATE_DIR}/oraInst.loc
                JDK_PATCH=${MISC_DIR}/jdk.patch

                  DBS_ENV=${LIB_DIR}/env/dbs_profile.sh
                  IAM_ENV=${LIB_DIR}/env/iam_profile.sh
                  IDM_ENV=${LIB_DIR}/env/idm_profile.sh
                 base_DBS=/appl/dbs
                 base_IAM=/appl/iam
                 base_IDM=/appl/idm
                 base_OWT=/appl/web
              FEDORA_EPEL=${MISC_DIR}/epel-release-6-8.noarch.rpm
                  LOGFILE=log/install.log
                   XAVIEW=/appl/dbs/product/11.2/db/rdbms/admin/xaview.sql

# images location
                 s_images=/mnt/orainst/oinstall
                    s_jdk=${s_images}/oracle-jrockit-28.2.8-1.6.0_51/jrockit-R28.2.8-p16863120_2828_Linux-x86-64.zip
                s_jdkname=jrockit-jdk1.6.0_51
               s_jdkpatch=${base}/lib/patches/jdk16-secconf.patch

                 s_img_db=${s_images}/oracle-db-ee-11.2.0.3/p10404530_112030_Linux-x86-64
                s_patches=${s_images}/patches
               s_rcu_home=${s_images}/iam-11.1.2.2/repo/installers/fmw_rcu/linux/rcuHome
                    s_lcm=${s_images}/iam-11.1.2.2/repo/installers/idmlcm
                 s_runjdk=${s_images}/iam-11.1.2.2/repo/installers/jdk/jdk6

# machine information
           GROUPS_UNIX=( oinstall dba iam idm )
                 USER_ORA=oracle
                 USER_IAM=iam
                 USER_IDM=idm

