
/* 
Validate Data Quality Checks from silver layer transformations
Source: erp_cust_az12 (silver) 
Expected grain: One row per customer id (cid)
 */


SELECT * FROM silver.erp_cust_az12 LIMIT 100;

-- Check duplicates in primary key
-- Expectation: No duplicates or NULLs

SELECT cid, COUNT(*) AS count_cid
FROM silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;

-- Check columns for unwanted spaces
-- Expectation: No results

SELECT *
FROM silver.erp_cust_az12
WHERE cid != TRIM(cid)

SELECT *
FROM silver.erp_cust_az12
WHERE gen != TRIM(gen)

-- Check data integrity of keys intended to join to other tables
-- Expectation: keys shared in both tables

SELECT *
FROM silver.erp_cust_az12
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info)


-- Check date fields
-- Expected: No birthdates greater than current date

SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate > CURRENT_DATE


-- Check standardization
-- Expect: Low cardinality for gen field, consistent values

SELECT DISTINCT gen
FROM silver.erp_cust_az12;
