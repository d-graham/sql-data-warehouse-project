/*
Gold layer
Create the Products dimension table
*/


-- Joining Product tables
SELECT
pr.prd_id,
pr.cat_id,
pr.prd_key,
pr.prd_nm,
pr.prd_cost,
pr.prd_line,
pr.prd_start_dt,
pc.cat,
pc.subcat,
pc.maintenance
FROM silver.crm_prd_info AS pr
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pr.cat_id = pc.id
WHERE pr.prd_end_dt IS NULL -- filter out historic data


SELECT * FROM silver.crm_prd_info;
SELECT * FROM silver.erp_px_cat_g1v2;


-- Check for duplicates after join
-- Expectation: No duplicated rows
SELECT prd_key, COUNT(*) FROM (
    SELECT
    pr.prd_id,
    pr.cat_id,
    pr.prd_key,
    pr.prd_nm,
    pr.prd_cost,
    pr.prd_line,
    pr.prd_start_dt,
    pc.cat,
    pc.subcat,
    pc.maintenance
    FROM silver.crm_prd_info AS pr
    LEFT JOIN silver.erp_px_cat_g1v2 AS pc
    ON pr.cat_id = pc.id
    WHERE pr.prd_end_dt IS NULL -- filter out historic data
) AS pr_table GROUP BY prd_key
HAVING COUNT(*) > 1;


-- Check integration between tables
-- No data fields to integrate between tables in this case



-- Developing joined tables with integration rules applied
-- Applying naming conventions for readable names using snake_case
-- Dimension table as contents of the table created describe customers

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pr.prd_start_dt, pr.prd_key) AS product_key,
    pr.prd_id AS product_id,
    pr.prd_key AS product_number,
    pr.prd_nm AS product_name,
    pr.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,
    pr.prd_cost AS cost,
    pr.prd_line AS product_line,
    pr.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pr
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pr.cat_id = pc.id
WHERE pr.prd_end_dt IS NULL -- filter out historic data


-- Verify creation of gold dimensional table
SELECT * FROM gold.dim_products;

