

SELECT * FROM gold.fact_sales LIMIT 10;

-- Explore date bounds in facts table

-- Friction: Within SQL Server the function DATEDIFF(year, MIN(order_date), MAX(order_date)) exists
-- This command allows for year to be swapped out with month and so forth. An equivalent is not available in postgres.

-- Decision: In most date analysis the precision needed for dates has some flexibility. It is often satisfactory to
-- calculate days between dates then divide by 365.25 to develop years. Then bucket, take floor, or develop into months or so forth.
-- Chose to go this route for this exercise assuming business logic defined in an accual case, and if precision is material to the
-- analysis can develop that thoughtfully within the query at that time.

SELECT
MIN(order_date) AS min_order_date,
MAX(order_date) AS max_order_date,
CEIL((MAX(order_date) - MIN(order_date))/365.25) AS year_diff,
ROUND(((MAX(order_date) - MIN(order_date))/365.25 * 12),0) AS months_diff
--EXTRACT(DAY FROM AGE(MAX(order_date), MIN(order_date))) AS days_max_min,
--EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) AS year_diff_old
--EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS month_diff
FROM gold.fact_sales;


SELECT
MIN(shipping_date) AS min_shipping_date,
MAX(shipping_date) AS max_shipping_date,
CEIL((MAX(shipping_date) - MIN(shipping_date))/365.25) AS year_diff,
ROUND(((MAX(shipping_date) - MIN(shipping_date))/365.25 * 12),0) AS months_diff
FROM gold.fact_sales;


SELECT
MIN(due_date) AS min_due_date,
MAX(due_date) AS max_due_date,
CEIL((MAX(due_date) - MIN(due_date))/365.25) AS year_diff,
ROUND(((MAX(due_date) - MIN(due_date))/365.25 * 12),0) AS months_diff
FROM gold.fact_sales;


-- Find the youngest and oldest customer

SELECT
MIN(birthdate) AS min_birthdate,
MAX(birthdate) AS max_birthdate,
FROM gold.dim_customers;

SELECT
FLOOR((CURRENT_DATE - birthdate) / 365.25) AS age
FROM gold.dim_customers;

SELECT
MIN(FLOOR((CURRENT_DATE - birthdate) / 365.25)) AS min_age,
MAX(FLOOR((CURRENT_DATE - birthdate) / 365.25)) AS max_age
FROM gold.dim_customers;