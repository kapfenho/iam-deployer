Database Settings
=================



SYSDBA Access
-------------

SYSDBA access is needed for
* RCU: create or drop schemas
* Patch Set Assistant

Config files with username and password:

    user-config/iam.config
    user-config/iam/psa_identity.rsp
    user-config/iam/psa_access.rsp

Attention: it's mandatory to use the SYS users for RCU, SYSDBA role is
not sufficient.


