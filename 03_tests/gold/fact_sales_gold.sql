/*
Gold layer
Create the Sales facts table
*/


SELECT * FROM silver.crm_sales_details

-- Joining to bring over surrogate keys from dimension tables
SELECT
sd.sls_ord_num,
pr.product_key, -- Products surrogate key
cst.customer_key, -- Customers surrogate key
sd.sls_order_dt,
sd.sls_ship_dt,
sd.sls_due_dt,
sd.sls_sales,
sd.sls_quantity,
sd.sls_price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers AS cst
ON sd.sls_cust_id = cst.customer_id



-- Developing joined tables with integration rules applied
-- Applying naming conventions for readable names using snake_case
-- Dimension table as contents of the table created describe customers

CREATE VIEW gold.fact_sales AS
SELECT
sd.sls_ord_num AS order_number,
pr.product_key, -- Products surrogate key
cst.customer_key, -- Customers surrogate key
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS shipping_date,
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales_amount,
sd.sls_quantity AS quantity,
sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers AS cst
ON sd.sls_cust_id = cst.customer_id


-- Verify creation of gold dimensional table
SELECT * FROM gold.fact_sales;


-- Check Foreign Key Integrity (Dimensions)
-- Expected: No results if records match up
SELECT *
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL

SELECT *
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL


