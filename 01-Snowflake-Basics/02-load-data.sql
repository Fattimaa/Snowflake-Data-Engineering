
-- Snowflake in 20 Minutes
-- Step 2: Stage and load CSV files

USE DATABASE SF_TUTS;
USE SCHEMA PUBLIC;
USE WAREHOUSE SF_TUTS_WH;

-- Upload five CSV files from the local Windows computer.
-- Run this PUT statement through Snowflake CLI, not Snowsight.

PUT file://C:/temp/employees0*.csv
    @%EMP_BASIC
    AUTO_COMPRESS = TRUE;

-- Verify that all five files are staged.
LIST @%EMP_BASIC;

-- Load staged CSV data into the EMP_BASIC table.
COPY INTO EMP_BASIC
FROM @%EMP_BASIC
FILE_FORMAT = (
    TYPE = CSV
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
)
PATTERN = '.*employees0[1-5].csv.gz'
ON_ERROR = 'ABORT_STATEMENT';

-- Verify the number of loaded records.
SELECT COUNT(*) AS TOTAL_EMPLOYEES
FROM EMP_BASIC;
