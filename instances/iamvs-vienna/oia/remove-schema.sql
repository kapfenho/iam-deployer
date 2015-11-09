-- remove the OIA objects from database
-- shut down application before running this script
--
DROP USER VSL_OIA CASCADE;

DROP TABLESPACE VSL_OIA INCLUDING CONTENTS AND DATAFILES;
