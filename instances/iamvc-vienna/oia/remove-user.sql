-- remove the OIA objects from database
-- shut down application before running this script
--
DROP USER VCL_OIA CASCADE;

DROP TABLESPACE VCL_OIA INCLUDING CONTENTS AND DATAFILES;
