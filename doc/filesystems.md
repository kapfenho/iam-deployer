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
While you could use AFS or other network file systems, only NFS ist
official supported.

Local or Shared
---------------

Shared file systems are usually implmemented on top of local
filesystems, shared block storage or some kind of distributed low level
storage. In anyway more features and more complexity is needed,
resulting in increased operational effort, sometimes performance
disadvantages (depending what you compare it to).

In short 
Let's group the storage clients first - the services:

- Some services require shared storage. Usually this services run in
clusters, where one service can take over artifacts of others. Or
singular services that can be 'migrated' to (or can be started on) a
different host, with some additional configuration.

- Other services don't require shared storage, but using shared storage
bring obvious benefits. Binaries used on multiple machines, a common
configuration location, central data storage, etc.

- On the other end many services are designed to run independent,
stateless or their coordination or session data distribution is
implemented elsewhere. Use local storage if not other specified.





