
/* 
Data Quality Checks
Source: erp_loc_a101 (bronze) 
Expected grain: One row per customer id (cid)
 */

SELECT * FROM bronze.erp_loc_a101 LIMIT 100;

-- Check duplicates in primary key
-- Expectation: No duplicates or NULLs

SELECT cid, COUNT(*) AS count_cid
FROM bronze.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;

-- Check columns for unwanted spaces
-- Expectation: No results

SELECT *
FROM bronze.erp_loc_a101
WHERE cid != TRIM(cid)

SELECT *
FROM bronze.erp_loc_a101
WHERE cntry != TRIM(cntry)

-- Check data integrity of keys intended to join to other tables
-- Expectation: keys shared in both tables

SELECT cid FROM bronze.erp_loc_a101; -- observing extra characters '-' that will need to be stripped out
SELECT cst_key FROM silver.crm_cust_info;

SELECT
cid,
cntry
FROM bronze.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);

-- Check standardization
-- Expect: Low cardinality for gen field, consistent values

SELECT DISTINCT cntry
FROM bronze.erp_loc_a101;

/* Develop transformation query to load silver layer */

SELECT
REPLACE(cid, '-', '') cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
    WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
    WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
    ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101;