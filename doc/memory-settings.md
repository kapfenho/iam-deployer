Memory Settings
===============

## Large Pages

If large pages are supported and enabled in the Operating System, 
ensure that JVM is configured as follows:

Arguments:

    -XX:+UseLargePages (for HotSpot JVM)
    -XX:+UseLargePagesForHeap
    -XX:+ForceLargePagesForHeap (for JRockit JVM).

In JRockit JVM, if you are enabling large pages, do not use the argument:

    -XX:+UseLargePagesForCode

System settings: kernel parameter

    # /etc/sysctl.conf
    #
    # shmmax ------------------------------------------------------
    #   Where n is equal to the number of bytes of the maximum shared
    #   memory segment allowed on the system. You should set it at least 
    #   to the size of the largest heap size you want to use for the JVM, 
    #   or alternatively you can set it to the total amount of memory in 
    #   the system.
    kernel.shmmax = n
    #
    # vm.nr_hugepages ---------------------------------------------
    #   Where n is equal to the number of large pages. You will need to 
    #   look up the large page size in /proc/meminfo.
    vm.nr_hugepages = 15000
    #
    # shm_group ---------------------------------------------------
    #   Where gid is a shared group id for the users you want to have 
    #   access to the large pages.
    vm.hugetlb_shm_group = 20027
    
System settings: security limits
    
    # /etc/security/limits.conf
    #   n=(vm.nr_hugepages * page size in kb)
    #     or unlimited
    fmwuser     soft     memlock     n
    fmwuser     hard     memlock     n

### Further information

(Redhat JBoss Performance Tuning)[https://access.redhat.com/documentation/en-US/JBoss_Enterprise_Application_Platform/5/html/Performance_Tuning_Guide/sect-Performance_Tuning_Guide-Java_Virtual_Machine_Tuning-Large_Page_Memory.html]


