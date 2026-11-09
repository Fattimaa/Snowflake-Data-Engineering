
-- =====================================================
-- Snowflake Tutorial 02: Load CSV and JSON Data
-- Official tutorial + hands-on error correction
-- =====================================================

-- 1. Select tutorial environment
USE DATABASE mydatabase;
USE SCHEMA public;
USE WAREHOUSE mywarehouse;

-- IMPORTANT:
-- MYCSVTABLE and MYJSONTABLE are TEMPORARY tables.
-- They must exist in the current session.
-- Run 01-setup.sql first in a fresh environment.


-- 2. Check uploaded files
LIST @my_csv_stage;
LIST @my_json_stage;


-- 3. Load CSV files
-- SKIP_FILE prevents a malformed file from loading.

COPY INTO mycsvtable
FROM @my_csv_stage
FILE_FORMAT = (FORMAT_NAME = mycsvformat)
PATTERN = '.*contacts[1-5].csv.gz'
ON_ERROR = 'skip_file';


-- 4. Investigate CSV load errors
-- Run immediately after the COPY operation.
-- Replace <COPY_QUERY_ID> with the actual query ID.
-- Do not execute the placeholder unchanged.

-- SELECT LAST_QUERY_ID();

-- CREATE OR REPLACE TABLE save_copy_errors AS
-- SELECT *
-- FROM TABLE(
--   VALIDATE(
--     mycsvtable,
--     JOB_ID => '<COPY_QUERY_ID>'
--   )
-- );

-- SELECT * FROM save_copy_errors;


-- 5. Correct malformed CSV records
-- Edit contacts3.csv locally.
-- Re-upload using PowerShell with --overwrite.
-- Then execute the following COPY command.

-- COPY INTO mycsvtable
-- FROM @my_csv_stage/contacts3.csv.gz
-- FILE_FORMAT = (FORMAT_NAME = mycsvformat)
-- ON_ERROR = 'skip_file';


-- 6. Verify CSV data
SELECT COUNT(*) AS total_csv_rows
FROM mycsvtable;

SELECT *
FROM mycsvtable
ORDER BY id;


-- 7. Load JSON data
COPY INTO myjsontable
FROM @my_json_stage/contacts.json.gz
FILE_FORMAT = (FORMAT_NAME = myjsonformat)
ON_ERROR = 'skip_file';


-- 8. Verify JSON data
SELECT COUNT(*) AS total_json_rows
FROM myjsontable;

SELECT *
FROM myjsontable;


-- 9. Query nested JSON fields
-- Additional hands-on exercise

SELECT
  json_data:customer.name.first::STRING AS first_name,
  json_data:customer.name.last::STRING AS last_name,
  json_data:customer.email::STRING AS email
FROM myjsontable;


-- 10. Final verification
SHOW STAGES IN SCHEMA mydatabase.public;

LIST @my_csv_stage;
LIST @my_json_stage;


-- Expected final results after correcting contacts3.csv:
-- CSV rows: 26
-- JSON rows: 3
-- CSV files staged: 5
-- JSON files staged: 1
