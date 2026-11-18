/*
Performance Analysis
Comparing the current value to a target value

Current [Measure] - Target [Measure]
e.g. Current Sales - Average Sales
    Current Year Sales - Previous Year Sales
    Current Sales - Lowest Sales
*/

-- Analyze the yearly performance of products by comparing each product's sales to both its
-- average sales performance, and the pervious year's sales

-- Developing yearly performance of products by year
SELECT
EXTRACT(YEAR FROM f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM f.order_date), p.product_name


-- Developing average sales performance component
WITH yearly_product_sales AS (
SELECT
EXTRACT(YEAR FROM f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM f.order_date), p.product_name
)
SELECT
order_year,
product_name,
current_sales,
ROUND(AVG(current_sales) OVER(PARTITION BY product_name),0) AS avg_sales,
current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name),0) AS diff_avg,
CASE WHEN current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name),0) > 0 THEN 'Above Avg'
    WHEN current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name),0) < 0 THEN 'Below Avg'
    ELSE 'Avg' 
END AS avg_change
FROM yearly_product_sales
ORDER BY product_name, order_year

-- Developing third component, comparison to previous years sales
WITH yearly_product_sales AS (
SELECT
EXTRACT(YEAR FROM f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM f.order_date), p.product_name
)
SELECT
order_year,
product_name,
current_sales,
ROUND(AVG(current_sales) OVER(PARTITION BY product_name),0) AS avg_sales,
current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name),0) AS diff_avg,
CASE WHEN current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name),0) > 0 THEN 'Above Avg'
    WHEN current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name),0) < 0 THEN 'Below Avg'
    ELSE 'Avg'
END AS avg_change,
-- Year-over-year analysis
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
    WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
    ELSE 'No change'
END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year


