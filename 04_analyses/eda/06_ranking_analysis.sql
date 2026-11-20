


-- Which 5 products generate the highest revenue?

SELECT
p.product_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY SUM(f.sales_amount) DESC
LIMIT 5;

SELECT *
FROM (
    SELECT
    p.product_name,
    SUM(f.sales_amount) AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
    GROUP BY p.product_name
    ORDER BY SUM(f.sales_amount) DESC) AS sub_t
WHERE rank_products <= 5;

SELECT
p.subcategory,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
GROUP BY p.subcategory
ORDER BY SUM(f.sales_amount) DESC
LIMIT 5;

-- What are the 5 worst-performing products in terms of sales?

SELECT
p.product_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY SUM(f.sales_amount)
LIMIT 5;


-- Find the top 10 customers who have generated the highest revenue

SELECT
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_key
GROUP BY
c.customer_key,
c.first_name,
c.last_name
ORDER BY SUM(f.sales_amount) DESC
LIMIT 10;

-- The 3 customers with the fewest orders placed

SELECT
c.customer_key,
c.first_name,
c.last_name,
COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_key
GROUP BY
c.customer_key,
c.first_name,
c.last_name
ORDER BY COUNT(DISTINCT order_number) ASC
LIMIT 10;