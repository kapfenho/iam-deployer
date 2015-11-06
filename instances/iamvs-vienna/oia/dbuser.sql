CREATE TABLESPACE IAM_OIA
  DATAFILE 'tbs_oia.dbf' SIZE 2000M ONLINE;

CREATE USER IAM_OIA 
  IDENTIFIED BY "Montag11"
  DEFAULT TABLESPACE IAM_OIA
  TEMPORARY TABLESPACE TEMP
  PROFILE DEFAULT;

GRANT CONNECT TO IAM_OIA;

GRANT RESOURCE TO IAM_OIA;

ALTER USER IAM_OIA 
  QUOTA UNLIMITED ON IAM_OIA;

