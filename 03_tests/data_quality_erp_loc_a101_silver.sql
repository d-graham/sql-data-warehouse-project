
/* 
Validate Data Quality Checks from silver layer transformations
Source: erp_loc_a101 (silver) 
Expected grain: One row per customer id (cid)
 */

SELECT * FROM silver.erp_loc_a101 LIMIT 100;

-- Check duplicates in primary key
-- Expectation: No duplicates or NULLs

SELECT cid, COUNT(*) AS count_cid
FROM silver.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;

-- Check columns for unwanted spaces
-- Expectation: No results

SELECT *
FROM silver.erp_loc_a101
WHERE cid != TRIM(cid)

SELECT *
FROM silver.erp_loc_a101
WHERE cntry != TRIM(cntry)

-- Check data integrity of keys intended to join to other tables
-- Expectation: keys shared in both tables

SELECT cid FROM silver.erp_loc_a101; -- observing extra characters '-' that will need to be stripped out
SELECT cst_key FROM silver.crm_cust_info;

SELECT
cid,
cntry
FROM silver.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);

-- Check standardization
-- Expect: Low cardinality for gen field, consistent values

SELECT DISTINCT cntry
FROM silver.erp_loc_a101;
