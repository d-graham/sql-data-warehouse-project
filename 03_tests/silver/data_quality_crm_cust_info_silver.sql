/* 
Validate Data Quality Checks from silver layer transformations
Checking silver.crm_cust_info 
Grain: One row per customer (unique cst_id)

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
    - Run these checks after data loading Silver layer
    - Investige and resolve any discrepencies found during the checks
*/

SELECT * FROM silver.crm_cust_info LIMIT 100;


-- Check for NULLs or duplicates in Primary Key
-- Expectation: One row per customer w/o duplications or nulls

SELECT cst_id, COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

SELECT *
FROM silver.crm_cust_info
WHERE cst_id = '29466'; -- inspect rows with repeated cst_id to develop deduplication rule


-- Check columns for unwanted spaces
-- Expectation: No results

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Check distinct values to assess suitability for mapping to readable text
-- Expectation: Low cardinality fields that can be remapped

SELECT cst_gndr, COUNT(*) AS count_cst_gndr
FROM silver.crm_cust_info
GROUP BY cst_gndr;

SELECT cst_marital_status, COUNT(*) AS count_cst_marital_status
FROM silver.crm_cust_info
GROUP BY cst_marital_status;