-- Identity Analytics Database Schema Initialization
-- 
-- While the other applications of the suite use RCU for schema 
-- creation we need to create to objects here manually.
--
-- Adjust the script accoring your needs. Username and password
-- are also configured in the userconfig iam.config
--

CREATE TABLESPACE VSL_OIA
  DATAFILE 'tbs_oia.dbf' SIZE 2000M ONLINE;

CREATE USER VSL_OIA 
  IDENTIFIED BY "Montag11"
  DEFAULT TABLESPACE VSL_OIA
  QUOTA UNLIMITED ON VSL_OIA
  TEMPORARY TABLESPACE TEMP
  PROFILE DEFAULT;

GRANT CONNECT, RESOURCE TO VSL_OIA;

