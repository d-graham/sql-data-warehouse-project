/* Load Silver Layer Data */


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