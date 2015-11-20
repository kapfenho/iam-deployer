-- Identity Analytics Database Schema Initialization
-- 
-- While the other applications of the suite use RCU for schema 
-- creation we need to create to objects here manually.
--
-- Adjust the script accoring your needs. Username and password
-- are also configured in the userconfig iam.config
--

CREATE TABLESPACE IAK1_OIA
  DATAFILE 'tbs_iak1_oia01.dbf' SIZE 200M ONLINE;

CREATE USER IAK1_OIA
  IDENTIFIED BY "Montag11"
  DEFAULT TABLESPACE IAK1_OIA
  QUOTA UNLIMITED ON IAK1_OIA
  TEMPORARY TABLESPACE TEMP
  PROFILE DEFAULT;

GRANT CONNECT, RESOURCE TO IAK1_OIA;

