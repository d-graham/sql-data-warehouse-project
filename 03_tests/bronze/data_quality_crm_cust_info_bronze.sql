/* 
Data Quality Checks
Checking bronze.crm_cust_info
Grain: One row per customer (cst_id)

Script Purpose:
    This script performs quality checks for data consistency, accuracy,
    and standardization across the 'bronze' schema. The transformations
    used to load silver are built up from the observations of those checks.
    
    It includes checks for:
    - Null or duplicate primary keys
    - Unwanted spaces in string fields
    - Data standardization and consistency
    - Invalid date ranges and orders
    - Data consistency between related fields

Usage Notes:
    - Run these checks after data loading Bronze layer
    - Investige and resolve any discrepencies found during the checks
    - Appended at bottom of script are the data transformations built up for loading Silver
*/

SELECT * FROM bronze.crm_cust_info LIMIT 100;

-- Check for NULLs or duplicates in primary key
-- Expectation: One row per customer w/o duplications or nulls

SELECT cst_id, COUNT(*) 
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

SELECT *
FROM bronze.crm_cust_info
WHERE cst_id = '29466'; -- inspect rows with repeated cst_id to develop deduplication rule


-- Check columns for unwanted spaces
-- Expectation: No results

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Check distinct values to assess suitability for mapping to readable text
-- Expectation: Low cardinality fields that can be remapped

SELECT cst_gndr, COUNT(*) AS count_cst_gndr
FROM bronze.crm_cust_info
GROUP BY cst_gndr;

SELECT cst_marital_status, COUNT(*) AS count_cst_marital_status
FROM bronze.crm_cust_info
GROUP BY cst_marital_status;


/* Develop transformation query to load silver layer */

-- CTE removes duplicate records by ranking cst_create_date to retain the most-recent record
WITH ranked_crm_cust_info AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
    FROM bronze.crm_cust_info
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname, -- data cleansing (trimming unwanted spaces)
    TRIM(cst_lastname) AS cst_lastname, -- data cleansing (trimming unwanted spaces)
    CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single' -- normalize value to a readable format
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END cst_marital_status,    
    CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' -- normalize value to a readable format
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END cst_gndr,
    cst_create_date
FROM ranked_crm_cust_info
WHERE flag_last = 1 AND cst_id IS NOT NULL; -- Select the most recent record per customer, and exclude null cst_id