/* Exploring measures
*/

SELECT * FROM gold.fact_sales;

-- Find the total sales

SELECT TO_CHAR(SUM(sales_amount), 'FM999,999,999') AS total_sales
FROM gold.fact_sales;

-- Find how many items are sold

SELECT SUM(quantity) AS total_quantity
FROM gold.fact_sales;

-- Find the average selling price

SELECT AVG(price) AS avg_price FROM gold.fact_sales;

-- Find the total number of orders

SELECT COUNT(order_number) AS total_orders FROM gold.fact_sales
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales

-- Find the total number of products

SELECT COUNT(DISTINCT product_key) AS total_products FROM gold.dim_products
SELECT COUNT(DISTINCT product_name) AS total_products FROM gold.dim_products

-- Find the total number of customers

SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers;


-- Find the total number of customers that has placed an order

SELECT COUNT(DISTINCT customer_key) AS total_customers_with_orders
FROM gold.fact_sales;

-- Generate a report summarizing key metrics of the business

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', ROUND(AVG(price), 1) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Products', COUNT(product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Nr. Customers', COUNT(customer_key) FROM gold.dim_customers;