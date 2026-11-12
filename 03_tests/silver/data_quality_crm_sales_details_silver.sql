/* 
Validate Data Quality Checks from silver layer transformations
Checking silver.crm_sales_details
Grain: One row per prd_key per prd_start_dt

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


SELECT * FROM silver.crm_sales_details LIMIT 100;

-- Check duplicates in sales order number
-- Expectation: Duplicates in sls_ord_num possible, verifying expected grain is combination with sales product key

SELECT sls_ord_num, COUNT(*) AS count_sls_ord_num
FROM silver.crm_sales_details
GROUP BY sls_ord_num
HAVING COUNT(*) > 1;

SELECT *
FROM silver.crm_sales_details
WHERE sls_ord_num = 'SO57523';

-- Check columns for unwanted spaces
-- Expectation: No results

SELECT *
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- Check data integrity of keys intended to join to other tables
-- Expectation: keys shared in both tables

SELECT *
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)

SELECT *
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)

-- Examine date fields
-- Expected: All date fields populated and within a valid date range

SELECT
sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > '2050-01-01'
    OR sls_order_dt < '1900-01-01'

SELECT
sls_ship_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt > '2050-01-01'
    OR sls_ship_dt < '1900-01-01'

SELECT
sls_due_dt
FROM silver.crm_sales_details
WHERE sls_due_dt > '2050-01-01'
    OR sls_due_dt < '1900-01-01'


-- Check for invalid date sequences
-- Expected: No order dates greater than ship date, or order date greater than due date

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
    OR sls_order_dt > sls_due_dt


-- Check data consistency between Sales, Quantity, and Price
-- Expected: 'Sales = Quantity * Price' AND 'Values may not be NULL, zero, or negative'

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_sales <= 0
OR sls_quantity IS NULL OR sls_quantity <= 0
OR sls_price IS NULL OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price


