/* 
Data Quality Checks
Checking bronze.erp_cust_az12
Grain: One row per customer id (cid)

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

SELECT * FROM bronze.erp_cust_az12 LIMIT 100;

-- Check duplicates in primary key
-- Expectation: No duplicates or NULLs

SELECT cid, COUNT(*) AS count_cid
FROM bronze.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;

-- Check columns for unwanted spaces
-- Expectation: No results

SELECT *
FROM bronze.erp_cust_az12
WHERE cid != TRIM(cid)

SELECT *
FROM bronze.erp_cust_az12
WHERE gen != TRIM(gen)

-- Check data integrity of keys intended to join to other tables
-- Expectation: keys shared in both tables

SELECT * FROM silver.crm_cust_info LIMIT 5;
SELECT * FROM bronze.erp_cust_az12 LIMIT 5; -- observing extra characters prefix 'NAS' that will need to be stripped out

SELECT *
FROM bronze.erp_cust_az12
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info)

SELECT -- developing transformation
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
    ELSE cid
END cid,
bdate,
gen
FROM bronze.erp_cust_az12;

SELECT
cid,
bdate,
gen
FROM bronze.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
    ELSE cid
END NOT IN (SELECT cst_key FROM silver.crm_cust_info)

-- Check date fields
-- Expected: All values are dates

SELECT DISTINCT
bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > CURRENT_DATE


-- Check standardization
-- Expect: Low cardinality for gen field, consistent values

SELECT DISTINCT gen
FROM bronze.erp_cust_az12;

/* Develop transformation query to load silver layer */

SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
    ELSE cid
END cid,
CASE WHEN bdate > CURRENT_DATE THEN NULL
    ELSE bdate
END AS bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
    WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
    ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12;