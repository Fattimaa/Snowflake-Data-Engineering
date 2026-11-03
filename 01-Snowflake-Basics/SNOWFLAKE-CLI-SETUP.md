# Snowflake CLI Setup — Windows PowerShell

## Overview

This guide documents how I configured Snowflake CLI on Windows and uploaded local CSV files to a Snowflake internal table stage.

The setup is based on the official [Snowflake in 20 Minutes](https://docs.snowflake.com/en/user-guide/tutorials/snowflake-in-20minutes) tutorial.

**Important:** Local file paths, account identifiers, usernames, authentication methods, and connection names may differ between users.

## 1. Install Snowflake CLI

Download and install Snowflake CLI for Windows using the [official Snowflake CLI installation guide](https://docs.snowflake.com/en/developer-guide/snowflake-cli/installation/installation).

After installation, open Windows PowerShell and verify the installation:

```powershell
snow --version
```

In my environment, the installed version was:

```text
Snowflake CLI version: 3.32.1
```

## 2. Configure a Snowflake Connection

Run the following command in PowerShell:

```powershell
snow connection add
```

The interactive setup prompts for connection details.

| Configuration | Example / Description |
|---|---|
| Connection name | `snowflake_tutorial` |
| Account | Your Snowflake account identifier |
| User | Your Snowflake username |
| Password | Your Snowflake password |
| Role | A role with the required permissions |
| Warehouse | `SF_TUTS_WH` |
| Database | `SF_TUTS` |
| Schema | `PUBLIC` |
| Host / Port / Region | Use the defaults when appropriate for your account |
| Authenticator | Password-based authentication or another supported method |

The connection name is a local alias and can be different for each user.

**Security:** Never commit passwords, tokens, private keys, or local Snowflake configuration files to GitHub. Prefer secure authentication and credential management.

## 3. Test the Connection

Run:

```powershell
snow connection test -c snowflake_tutorial
```

A successful test confirms that Snowflake CLI can connect to the account.

My connection test completed successfully with status `OK`.

## 4. Prepare the CSV Files

Download the sample dataset from the official Snowflake tutorial:

[Download sample ZIP](https://docs.snowflake.com/static/samples/getting-started.zip)

Extract the five employee CSV files into a local folder.

In my Windows environment, I used:

```text
C:\temp\
```

The folder contained:

```text
employees01.csv
employees02.csv
employees03.csv
employees04.csv
employees05.csv
```

Verify the files using PowerShell:

```powershell
dir C:\temp\employees*.csv
```

**Note:** `C:\temp` is only an example. Other users must replace it with the actual location of their downloaded files.

## 5. Upload CSV Files Using PUT

Run the following command in PowerShell:

```powershell
snow sql -c snowflake_tutorial -q "PUT file://C:/temp/employees0*.csv @SF_TUTS.PUBLIC.%EMP_BASIC AUTO_COMPRESS=TRUE;"
```

This command:

- Uses the configured Snowflake CLI connection.
- Finds the matching local CSV files.
- Uploads the files to the internal stage associated with `EMP_BASIC`.
- Automatically compresses the files using GZIP.

In my environment, all five files returned:

```text
UPLOADED
```

The uploaded files were stored with `.csv.gz` extensions.

**Important:** Local-file `PUT` commands must be executed through a supported client such as Snowflake CLI, not directly in a Snowsight worksheet.

## 6. Verify Staged Files

In a Snowflake SQL worksheet, run:

```sql
USE DATABASE SF_TUTS;
USE SCHEMA PUBLIC;

LIST @%EMP_BASIC;
```

The result should list the five staged files.

## 7. Load Data Into the Table

Run the following SQL statement in Snowflake:

```sql
COPY INTO EMP_BASIC
FROM @%EMP_BASIC
FILE_FORMAT = (
    TYPE = CSV
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
)
PATTERN = '.*employees0[1-5].csv.gz'
ON_ERROR = 'ABORT_STATEMENT';
```

In my execution:

- 5 files were loaded.
- 25 rows were loaded.
- 0 loading errors were reported.

## 8. Verify the Loaded Records

```sql
SELECT COUNT(*) AS TOTAL_EMPLOYEES
FROM EMP_BASIC;
```

Expected result for the original sample dataset:

```text
TOTAL_EMPLOYEES
---------------
25
```

To inspect the records:

```sql
SELECT *
FROM EMP_BASIC;
```

## Troubleshooting Notes

During setup, I encountered an authentication error caused by incorrect connection credentials. I corrected the local configuration and successfully retested the connection.

I also observed an encoding warning in PowerShell, but it did not prevent the successful connection or file upload.

Common issues to check include:

- Incorrect account identifier, username, or password.
- Incorrect local CSV file path.
- Missing database, table, or warehouse.
- Insufficient role permissions.
- Using `PUT` in Snowsight instead of Snowflake CLI.

## Security and Portability

This repository does not include local connection credentials.

Before running the commands on another computer, users should update:

- Their Snowflake connection name.
- Their account authentication settings.
- Their local CSV directory.
- Database, schema, table, and warehouse names if different.

## References

- [Snowflake in 20 Minutes](https://docs.snowflake.com/en/user-guide/tutorials/snowflake-in-20minutes)
- [Snowflake CLI Documentation](https://docs.snowflake.com/en/developer-guide/snowflake-cli/index)
- [Snowflake SQL PUT Command](https://docs.snowflake.com/en/sql-reference/sql/put)
