
-- Snowflake Tutorial 02
-- Setup database, warehouse, tables, file formats and stages
-- WARNING: CREATE OR REPLACE can overwrite existing resources.
-- Run only in a fresh tutorial environment.

CREATE OR REPLACE DATABASE mydatabase;

CREATE OR REPLACE WAREHOUSE mywarehouse
  WITH WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 120
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

USE DATABASE mydatabase;
USE SCHEMA public;
USE WAREHOUSE mywarehouse;

CREATE OR REPLACE TEMPORARY TABLE mycsvtable (
  id INTEGER,
  last_name STRING,
  first_name STRING,
  company STRING,
  email STRING,
  workphone STRING,
  cellphone STRING,
  streetaddress STRING,
  city STRING,
  postalcode STRING
);

CREATE OR REPLACE TEMPORARY TABLE myjsontable (
  json_data VARIANT
);

CREATE OR REPLACE FILE FORMAT mycsvformat
  TYPE = 'CSV'
  FIELD_DELIMITER = '|'
  SKIP_HEADER = 1;

CREATE OR REPLACE FILE FORMAT myjsonformat
  TYPE = 'JSON'
  STRIP_OUTER_ARRAY = TRUE;

CREATE OR REPLACE STAGE my_csv_stage
  FILE_FORMAT = mycsvformat;

CREATE OR REPLACE STAGE my_json_stage
  FILE_FORMAT = myjsonformat;
