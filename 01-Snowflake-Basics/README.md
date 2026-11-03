# Snowflake Basics — Hands-on Tutorial

## Project Overview

This project documents my hands-on experience with Snowflake, following the official **Snowflake in 20 Minutes** tutorial.

The goal was to understand Snowflake's core architecture, configure a working environment, load CSV data into a table, and query the data using SQL.

## Technologies Used

- Snowflake Cloud Data Platform
- Snowflake CLI
- SQL
- CSV files
- Windows PowerShell

## What I Learned

### 1. Snowflake Environment Setup
- Created a database named `SF_TUTS`.
- Used the `PUBLIC` schema.
- Created the `EMP_BASIC` table.
- Configured an X-Small virtual warehouse named `SF_TUTS_WH`.

### 2. Data Staging
- Installed and configured Snowflake CLI.
- Established a connection to my Snowflake account.
- Uploaded five CSV files using the `PUT` command.
- Verified the staged files using `LIST`.

### 3. Data Loading
- Loaded staged CSV files into `EMP_BASIC` using `COPY INTO`.
- Used CSV file format settings.
- Successfully loaded 25 records from five files with zero reported errors.

### 4. SQL Queries
- Retrieved records using `SELECT`.
- Explored inserting new records using `INSERT INTO`.
- Learned how to filter email addresses using `WHERE` and `LIKE`.
- Practiced date calculations using `DATEADD`.

## Data Loading Workflow

```text
Local CSV Files
       |
       | PUT
       v
Snowflake Internal Stage
       |
       | COPY INTO
       v
EMP_BASIC Table
       |
       | SELECT
       v
Query Results
```

## Key Concepts

- **Database:** A container for schemas and database objects.
- **Schema:** A logical organization of database objects.
- **Table:** Stores structured data in rows and columns.
- **Virtual Warehouse:** Provides compute resources for executing queries and loading data.
- **Stage:** Stores data files before loading.
- **DDL:** Defines or modifies database structures.
- **DML:** Inserts, updates, and deletes data.

## Results

- 5 CSV files uploaded successfully.
- 25 records loaded successfully.
- 0 loading errors reported.
- Data successfully queried from the Snowflake table.

## Reference

Official Snowflake Tutorial:

[Snowflake in 20 Minutes](https://docs.snowflake.com/en/user-guide/tutorials/snowflake-in-20minutes)

## Next Steps

Continue learning SQL, data transformations, Snowflake data loading techniques, and data warehousing concepts through additional hands-on exercises.
