-- remove the OIA objects from database
-- shut down application before running this script
--
DROP USER IAM_OIA CASCADE;

DROP TABLESPACE IAM_OIA INCLUDING CONTENTS AND DATAFILES;
