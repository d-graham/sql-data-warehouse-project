
/* 
Validate Data Quality Checks from silver layer transformations
Source: erp_px_cat_g1v2 (silver) 
Expected grain: One row per category id (id)
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
