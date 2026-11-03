
-- Snowflake in 20 Minutes
-- Step 3: Query and manipulate loaded data

USE DATABASE SF_TUTS;
USE SCHEMA PUBLIC;
USE WAREHOUSE SF_TUTS_WH;

-- 1. Retrieve all rows and columns.
SELECT *
FROM EMP_BASIC;

-- 2. Count the original loaded records.
-- Expected: 25 before inserting additional rows.
SELECT COUNT(*) AS TOTAL_EMPLOYEES
FROM EMP_BASIC;

-- 3. Insert two additional employees.
-- Run this INSERT only once to avoid duplicates.
INSERT INTO EMP_BASIC VALUES
    ('Clementine', 'Adamou', 'cadamou@sf_tuts.com',
     '10510 Sachs Road', 'Klenak', '2017-9-22'),
    ('Marlowe', 'De Anesy', 'madamouc@sf_tuts.co.uk',
     '36768 Northfield Plaza', 'Fangshan', '2017-1-26');

-- 4. Verify the total number of employees.
-- Expected: 27 after inserting two rows.
SELECT COUNT(*) AS TOTAL_EMPLOYEES
FROM EMP_BASIC;

-- 5. Find email addresses ending in .uk.
SELECT EMAIL
FROM EMP_BASIC
WHERE EMAIL LIKE '%.uk';

-- 6. Add 90 days to the start date for employees
-- who started on or before January 1, 2017.
SELECT
    FIRST_NAME,
    LAST_NAME,
    DATEADD('day', 90, START_DATE) AS BENEFIT_ELIGIBILITY_DATE
FROM EMP_BASIC
WHERE START_DATE <= '2017-01-01';
