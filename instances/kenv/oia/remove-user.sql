-- remove the OIA objects from database
-- shut down application before running this script
--
DROP USER IAK1_OIA CASCADE;

DROP TABLESPACE IAK1_OIA INCLUDING CONTENTS AND DATAFILES;
