
/* 
Data Quality Checks
Source: crm_sales_details (bronze) 
Expected grain: One row per sales order number (sls_ord_num) and sales product key (sls_prd_key) combination
 */

SELECT * FROM bronze.crm_sales_details LIMIT 100;

-- Check duplicates in sales order number
-- Expectation: Duplicates in sls_ord_num possible, verifying expected grain is combination with sales product key

SELECT sls_ord_num, COUNT(*) AS count_sls_ord_num
FROM bronze.crm_sales_details
GROUP BY sls_ord_num
HAVING COUNT(*) > 1;

SELECT *
FROM bronze.crm_sales_details
WHERE sls_ord_num = 'SO57523';

-- Check columns for unwanted spaces
-- Expectation: No results

SELECT *
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- Check data integrity of keys intended to join to other tables
-- Expectation: keys shared in both tables

SELECT *
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)

SELECT *
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)

-- Examine date fields
-- Expected: All date fields populated and within a valid date range

SELECT
NULLIF(sls_order_dt,0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
    OR LENGTH(sls_order_dt::text) != 8
    OR sls_order_dt > 20500101
    OR sls_order_dt < 19000101

SELECT
NULLIF(sls_ship_dt,0) AS sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0
    OR LENGTH(sls_ship_dt::text) != 8
    OR sls_ship_dt > 20500101
    OR sls_ship_dt < 19000101

SELECT
NULLIF(sls_due_dt,0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
    OR LENGTH(sls_due_dt::text) != 8
    OR sls_due_dt > 20500101
    OR sls_due_dt < 19000101

-- Check for invalid date sequences
-- Expected: No order dates greater than ship date, or order date greater than due date

SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
    OR sls_order_dt > sls_due_dt


-- Check data consistency between Sales, Quantity, and Price
-- Expected: 'Sales = Quantity * Price' AND 'Values may not be NULL, zero, or negative'

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_sales <= 0
OR sls_quantity IS NULL OR sls_quantity <= 0
OR sls_price IS NULL OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price


SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,
CASE WHEN sls_sales IS NULL or sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
    THEN sls_quantity * ABS (sls_price)
    ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price IS NULL OR sls_price <= 0
    THEN sls_sales / NULLIF(sls_quantity, 0)
    ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_sales <= 0
OR sls_quantity IS NULL OR sls_quantity <= 0
OR sls_price IS NULL OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

/* Develop transformation query to load silver layer */

SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt::text) != 8 THEN NULL -- enforcing valid date ranges else null
    ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
END AS sls_order_dt,
CASE WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt::text) != 8 THEN NULL -- enforcing valid date ranges else null
    ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
END AS sls_ship_dt,
CASE WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt::text) != 8 THEN NULL -- enforcing valid date ranges else null
    ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
END AS sls_due_dt,
CASE WHEN sls_sales IS NULL or sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) -- cleaning valid sales, product, price business rules
    THEN sls_quantity * ABS (sls_price)
    ELSE sls_sales
END AS sls_sales,
sls_quantity,
CASE WHEN sls_price IS NULL OR sls_price <= 0 -- cleaning valid sales, product, price business rules
    THEN sls_sales / NULLIF(sls_quantity, 0)
    ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details;