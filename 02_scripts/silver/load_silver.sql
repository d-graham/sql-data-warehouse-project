/* Load Silver Layer Data */
-- Transformation queries developed in ../03_tests/


-- Transformation query developed in 'data_quality_crm_cust_info_bronze.sql'
INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date)
-- CTE removes duplicate records by ranking cst_create_date to retain the most-recent record
WITH ranked_crm_cust_info AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
    FROM bronze.crm_cust_info
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname, -- data cleansing (trimming unwanted spaces)
    TRIM(cst_lastname) AS cst_lastname, -- data cleansing (trimming unwanted spaces)
    CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single' -- Normalize marital status values to readable format
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END cst_marital_status,    
    CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' -- Normalize gender values to readable format
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END cst_gndr,
    cst_create_date
FROM ranked_crm_cust_info
WHERE flag_last = 1 AND cst_id IS NOT NULL; -- Select the most recent record per customer, and exclude null cst_id


-- Transformation query developed in 'data_quality_crm_prd_info_bronze.sql'
INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt)
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


-- Transformation query developed in 'data_quality_crm_prd_sales_details_bronze.sql'
INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price)
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



-- Transformation query developed in 'data_quality_erp_cust_az12_bronze.sql'
INSERT INTO silver.erp_cust_az12 (
cid,
bdate,
gen)
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
    ELSE cid
END cid,
CASE WHEN bdate > CURRENT_DATE THEN NULL
    ELSE bdate
END AS bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
    WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
    ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12;

-- Transformation query developed in 'data_quality_erp_cust_az12_bronze.sql'
INSERT INTO silver.erp_loc_a101 (
cid,
cntry)
SELECT
REPLACE(cid, '-', '') cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
    WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
    WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
    ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101;


-- No transformations necessary, clean data in this table
INSERT INTO silver.erp_px_cat_g1v2 (
id,
cat,
subcat,
maintenance)
SELECT
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2;