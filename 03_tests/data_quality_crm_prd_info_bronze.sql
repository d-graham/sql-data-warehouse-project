/* 
Data Quality Checks
Source: crm_prd_info (bronze) 
Expected grain: One row per prd_key per prd_start_dt
 */

SELECT * FROM bronze.crm_prd_info LIMIT 100;

-- Check for duplicates or nulls in prd_id
-- Expected: No duplicates

SELECT prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted spaces
-- Expected: No extra spaces

SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check prd_cost for NULLs or negative numbers
-- Expected: No NULLs, intended that prd_cost may be used for calculations later

SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Check distinct values to assess suitability for mapping to readable text
-- Low cardinality. Additional definitions for each M, R, S, T provided as "go and talk to the domain experts" response.

SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

-- Check product dates for reasonableness
-- Expected: No prd_end_dt prior to prd_start_dt, logical date progression

SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


/* Develop transformation query to load silver layer */

SELECT
prd_id,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- splitting out cat_id from prd_key to join to erp table
SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key, -- removing split cat_id captures a prd_key field that can be joined to crm_sales_details table
prd_nm,
COALESCE(prd_cost, 0) AS prd_cost, -- replace NULLs with 0
CASE UPPER(TRIM(prd_line)) -- normalize value to a readable format
    WHEN 'M' THEN 'Mountain'
    WHEN 'R' THEN 'Road'
    WHEN 'S' THEN 'Other Sales'
    WHEN 'T' THEN 'Touring'
    ELSE 'n/a'
END AS prd_line,
prd_start_dt,
LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt -- Corrects for bad prd_end_dt data by calculating from start dates
FROM bronze.crm_prd_info;