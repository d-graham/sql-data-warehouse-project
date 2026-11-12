
/* 
Data Quality Checks
Source: erp_px_cat_g1v2 (bronze) 
Expected grain: One row per category id (id)
 */

SELECT * FROM bronze.erp_px_cat_g1v2 LIMIT 100;

-- Check duplicates in primary key
-- Expectation: No duplicates or NULLs

SELECT id, COUNT(*) AS count_cid
FROM bronze.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1 OR id IS NULL;

-- Check columns for unwanted spaces
-- Expectation: No results

SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE id != TRIM(id)

SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)

SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE subcat != TRIM(subcat)

SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE maintenance != TRIM(maintenance)

-- Check data integrity of keys intended to join to other tables
-- Expectation: keys shared in both tables

SELECT id FROM bronze.erp_px_cat_g1v2;
SELECT cat_id FROM silver.crm_prd_info;

SELECT
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2
WHERE id NOT IN (SELECT cat_id FROM silver.crm_prd_info);

-- Check standardization
-- Expect: Low cardinality for gen field, consistent values

SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2;

/* Develop transformation query to load silver layer */

SELECT
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2;