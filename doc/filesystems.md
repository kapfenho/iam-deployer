File System Storage
===================

Each Server has severlal mount points or directories, used be the services running on the host.

Technically there are two types of file systems:

  * local file systems
  * network file systems

This separation is independent of the storage location - a local filesystem can
be on remote storage and a network file system can be on local storage. A
network file system can be used by multiple hosts at the same time and usually
implements some kind of locking for write access.

You can choose between several local file systems, depending on you operating
system. When it comes to network file system Oracle supports NFS (version 3 and 4).
While you could use AFS or other network file systems, only NFS ist supported.




