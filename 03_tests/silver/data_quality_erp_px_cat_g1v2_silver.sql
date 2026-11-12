/* 
Validate Data Quality Checks from silver layer transformations
Checking silver.erp_px_cat_g1v2
Grain: One row per category id (id)

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

SELECT * FROM silver.erp_px_cat_g1v2 LIMIT 100;

-- Check duplicates in primary key
-- Expectation: No duplicates or NULLs

SELECT id, COUNT(*) AS count_cid
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1 OR id IS NULL;

-- Check columns for unwanted spaces
-- Expectation: No results

SELECT *
FROM silver.erp_px_cat_g1v2
WHERE id != TRIM(id)

SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)

SELECT *
FROM silver.erp_px_cat_g1v2
WHERE subcat != TRIM(subcat)

SELECT *
FROM silver.erp_px_cat_g1v2
WHERE maintenance != TRIM(maintenance)

-- Check data integrity of keys intended to join to other tables
-- Expectation: keys shared in both tables

SELECT id FROM silver.erp_px_cat_g1v2;
SELECT cat_id FROM silver.crm_prd_info;

SELECT
id,
cat,
subcat,
maintenance
FROM silver.erp_px_cat_g1v2
WHERE id NOT IN (SELECT cat_id FROM silver.crm_prd_info);

-- Check standardization
-- Expect: Low cardinality for gen field, consistent values

SELECT DISTINCT cat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT subcat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2;
