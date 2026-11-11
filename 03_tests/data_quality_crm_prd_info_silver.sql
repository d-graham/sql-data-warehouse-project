/* 
Validate Data Quality Checks from silver layer transformations
Source: crm_prd_info (silver) 
Expected grain: One row per prd_key per prd_start_dt
 */

SELECT * FROM silver.crm_prd_info LIMIT 100;

-- Check for duplicates or nulls in prd_id
-- Expected: No duplicates

SELECT prd_id, COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted spaces
-- Expected: No extra spaces

SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check prd_cost for NULLs or negative numbers
-- Expected: No NULLs, intended that prd_cost may be used for calculations later

SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Check distinct values to assess suitability for mapping to readable text
-- Low cardinality. Additional definitions for each M, R, S, T provided as "go and talk to the domain experts" response.

SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Check product dates for reasonableness
-- Expected: No prd_end_dt prior to prd_start_dt, logical date progression

SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;