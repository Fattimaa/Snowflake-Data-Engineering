# Snowflake Tutorial 02 — Bulk Loading Local Files (CSV & JSON)

## Overview

This tutorial documents hands-on practice with loading local CSV and JSON files into Snowflake using Snowflake CLI, internal stages, named file formats, and the `COPY INTO` command.

It also demonstrates how to identify, investigate, and correct data-loading errors using Snowflake's `VALIDATE` function.

**Reference:** [Snowflake Official Documentation — Bulk Loading from a Local File System](https://docs.snowflake.com/en/user-guide/tutorials/data-load-internal-tutorial)

## 1. Environment

- Operating system: Windows
- Command-line environment: PowerShell
- Snowflake CLI: Version 3.32.1
- Connection profile: `snowflake_tutorial`
- Database: `MYDATABASE`
- Schema: `PUBLIC`
- Warehouse: `MYWAREHOUSE`
- Local data directory: `C:\temp\load`

The tutorial data package contained five CSV files (`contacts1.csv` through `contacts5.csv`) and one JSON file (`contacts.json`).

## 2. Connect to Snowflake

Verify the connection from PowerShell:

```powershell
snow connection test -c snowflake_tutorial
```

Start an interactive Snowflake SQL session:

```powershell
snow sql -c snowflake_tutorial
```

## 3. Create and Select Snowflake Resources

```sql
CREATE OR REPLACE DATABASE mydatabase;

CREATE OR REPLACE WAREHOUSE mywarehouse
  WITH WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 120
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

USE DATABASE mydatabase;
USE SCHEMA public;
USE WAREHOUSE mywarehouse;
```

## 4. Create Destination Tables

```sql
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
```

Temporary tables exist only for the Snowflake session in which they are created.

## 5. Create File Formats

```sql
CREATE OR REPLACE FILE FORMAT mycsvformat
  TYPE = 'CSV'
  FIELD_DELIMITER = '|'
  SKIP_HEADER = 1;

CREATE OR REPLACE FILE FORMAT myjsonformat
  TYPE = 'JSON'
  STRIP_OUTER_ARRAY = TRUE;
```

The CSV file format uses the pipe (`|`) delimiter and skips the header row.

The JSON file format allows an outer JSON array to be loaded as individual records.

## 6. Create Internal Stages

```sql
CREATE OR REPLACE STAGE my_csv_stage
  FILE_FORMAT = mycsvformat;

CREATE OR REPLACE STAGE my_json_stage
  FILE_FORMAT = myjsonformat;
```

## 7. Upload Files Using PowerShell

The CSV files were uploaded individually because a wildcard-based upload initially caused command-line argument issues.

Example:

```powershell
snow stage copy "C:\temp\load\contacts1.csv" "@mydatabase.public.my_csv_stage" --auto-compress -c snowflake_tutorial
```

Repeat the command for `contacts2.csv`, `contacts3.csv`, `contacts4.csv`, and `contacts5.csv`.

Upload the JSON file:

```powershell
snow stage copy "C:\temp\load\contacts.json" "@mydatabase.public.my_json_stage" --auto-compress -c snowflake_tutorial
```

Verify the staged files:

```sql
LIST @my_csv_stage;
LIST @my_json_stage;
```

## 8. Load CSV Data

```sql
COPY INTO mycsvtable
FROM @my_csv_stage
FILE_FORMAT = (FORMAT_NAME = mycsvformat)
PATTERN = '.*contacts[1-5].csv.gz'
ON_ERROR = 'skip_file';
```

During the first attempt, four files loaded successfully, but `contacts3.csv.gz` contained malformed records.

The initial CSV load produced 21 rows.

## 9. Investigate Data-Loading Errors

Retrieve the COPY operation's query ID immediately after running it:

```sql
SELECT LAST_QUERY_ID();
```

Use the returned query ID to validate the load:

```sql
CREATE OR REPLACE TABLE save_copy_errors AS
SELECT *
FROM TABLE(
  VALIDATE(
    mycsvtable,
    JOB_ID => '<COPY_QUERY_ID>'
  )
);
```

Inspect the errors:

```sql
SELECT *
FROM save_copy_errors;
```

The malformed CSV records contained incorrect pipe delimiters, causing Snowflake to detect an unexpected number of columns.

After inspecting the records, the local CSV file was corrected and saved.

## 10. Re-upload the Corrected CSV File

```powershell
snow stage copy "C:\temp\load\contacts3.csv" "@mydatabase.public.my_csv_stage" --auto-compress --overwrite -c snowflake_tutorial
```

Reload the corrected file:

```sql
COPY INTO mycsvtable
FROM @my_csv_stage/contacts3.csv.gz
FILE_FORMAT = (FORMAT_NAME = mycsvformat)
ON_ERROR = 'skip_file';
```

Successful result:

- Status: `LOADED`
- Rows loaded: `5`
- Errors: `0`

Verify the total:

```sql
SELECT COUNT(*) AS total_rows
FROM mycsvtable;
```

**Final CSV result: 26 rows.**

## 11. Load JSON Data

```sql
COPY INTO myjsontable
FROM @my_json_stage/contacts.json.gz
FILE_FORMAT = (FORMAT_NAME = myjsonformat)
ON_ERROR = 'skip_file';
```

Successful result:

- Status: `LOADED`
- Rows loaded: `3`
- Errors: `0`

Inspect the JSON records:

```sql
SELECT *
FROM myjsontable;
```

## 12. Query Nested JSON Fields

The following is an additional hands-on exercise beyond the core file-loading workflow.

```sql
SELECT
  json_data:customer.name.first::STRING AS first_name,
  json_data:customer.name.last::STRING AS last_name,
  json_data:customer.email::STRING AS email
FROM myjsontable;
```

Snowflake's `VARIANT` data type supports semi-structured data, and JSON path expressions allow nested fields to be queried directly.

## 13. Final Verification

```sql
SELECT *
FROM mycsvtable
ORDER BY id;

SELECT COUNT(*) AS total_json_rows
FROM myjsontable;

SHOW STAGES IN SCHEMA mydatabase.public;

LIST @my_csv_stage;
LIST @my_json_stage;
```

### Final Results

| Check | Result |
|---|---|
| CSV files staged | 5 |
| CSV rows loaded | 26 |
| JSON files staged | 1 |
| JSON rows loaded | 3 |
| Corrected CSV file | `contacts3.csv` |
| Final corrected-file load | 5 rows, 0 errors |
| Internal stages | 2 |

## 14. Troubleshooting Lessons

**Malformed CSV delimiters:** An extra or missing pipe character can change the expected number of columns. Use `VALIDATE` to identify rejected records and correct the source data.

**Expired authentication:** An inactive Snowflake CLI session may require reconnecting with `snow connection test` and `snow sql`.

**Temporary table lifetime:** Temporary tables disappear when their session ends. They must be recreated in a new session before loading data again.

**Incorrect Windows paths:** Always use the complete drive-qualified path, such as `C:\temp\load\contacts3.csv`.

**Data quality versus load success:** Successfully loading a row does not guarantee every field is clean or semantically valid.

## 15. Cleanup

Snowflake tutorial resources can be removed when no longer required, to avoid unnecessary storage costs and keep the environment organized.

For this exercise, the database, warehouse, file formats, and internal stages were intentionally retained for further review and documentation.

**Do not run destructive cleanup commands until the resources are no longer needed.**

## Key Skills Learned

- Creating Snowflake databases, warehouses, and temporary tables
- Configuring named CSV and JSON file formats
- Creating and inspecting internal stages
- Uploading local files with Snowflake CLI
- Loading data with `COPY INTO`
- Investigating failed loads using `VALIDATE`
- Correcting and re-uploading malformed CSV files
- Querying semi-structured JSON data with `VARIANT`
- Understanding Snowflake session persistence and resource cleanup
