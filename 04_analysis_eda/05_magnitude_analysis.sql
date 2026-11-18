

-- Find total customers by country

SELECT
country,
COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;


-- Find total customers by gender

SELECT
gender,
COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;


-- Find total products by category

SELECT
category,
COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- What is the average cost in each category?

SELECT
category,
ROUND(AVG(cost), 1) AS avg_costs
FROM gold.dim_products
GROUP BY category
ORDER BY avg_costs DESC;

-- What is the total revenue generated for each category?

SELECT
p.category,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY SUM(f.sales_amount) DESC;

-- What is the total revenue by each customer?

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
ORDER BY SUM(f.sales_amount) DESC;

-- What is the distribution of items sold across countries?

SELECT
c.country,
SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_key
GROUP BY
c.country
ORDER BY SUM(f.quantity) DESC;