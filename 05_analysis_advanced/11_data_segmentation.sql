/*
Data Segmentation
Group the data based on a specific range to understand the correlation between two measures

[Measure] By [Measure]
e.g. Total Products By Sales Range
    Total Customers By Age

Process is to take a measure and convert it to a category [Dimension], the familiar creating buckets to group by
*/


-- Segment products into cost ranges and count how many products fall into each segment

WITH product_segments AS (
    SELECT
    product_key,
    product_name,
    cost,
    CASE WHEN cost <= 0 THEN '0'
        WHEN cost < 100 THEN '1 - 100'
        WHEN cost < 500 THEN '101 - 500'
        WHEN cost < 1000 THEN '501 - 1000'
        ELSE '1000+'
    END AS cost_range
    FROM gold.dim_products
    ORDER BY cost
)
SELECT
cost_range,
COUNT(product_key) AS count_products
FROM product_segments
GROUP BY cost_range
ORDER BY cost_range DESC


-- Group customers into three segments based on their spending behavior:
--  VIP: at least 12 months of history and spending more than 5,000
--  Regular: at least 12 months of history but spending 5,000 or less
--  New: lifespan less than 12 months

SELECT * FROM gold.dim_customers;
SELECT * FROM gold.fact_sales;

-- Step 1: Develop a CASE filter to classify new cusomters by 12 months

-- Thought process: I take issue with the 12 months lifespan definition developed in example, which used DATEDIFF() on first_order and
-- last_order by customer, because it requires customers have at least two purchases and I do not see the clear business relevance.
-- I think the structure is developed for sake of lesson convenience in SQL Server.

-- Alternative: The largest first_order date is 2014-01-28 for all customers, the data set is stale. Assuming the date to be 2014-02-01 and
-- looking for customers who placed a first_order within the last year to flag as those customers with lifespan of 12 months or less.
-- In a database maintained over time this sliding 'New customer' criteria makes more business sense than as presented.

SELECT
f.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_sales,
--MIN(order_date) AS first_order,
CASE WHEN MIN(order_date) >= '2013-02-01' THEN 'New customer' -- Assuming date is 2014-02-01 captures all first orders 12 months or less
    ELSE 'Returning customer'
END AS customer_classification
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON f.customer_key = c.customer_key
GROUP BY f.customer_key, c.first_name, c.last_name


-- Final query - Step 2: Develop classification to bucket by total_sales, also

SELECT
f.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_sales,
--MIN(order_date) AS first_order,
CASE WHEN MIN(order_date) >= '2013-02-01' THEN 'New customer' -- Assuming date is 2014-02-01 captures all first orders 12 months or less
    WHEN SUM(f.sales_amount) < 5000 THEN 'Regular customer'
    WHEN SUM(f.sales_amount) >= 5000 THEN 'VIP customer'
    ELSE 'Review edge case'
END AS customer_classification
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON f.customer_key = c.customer_key
GROUP BY f.customer_key, c.first_name, c.last_name


-- Validating logic. Added a filter to visually inspect VIP and Regular customers are not overriding New customer flags.
-- In this case coincidentally no new customers are above 5000 total_sales

SELECT
f.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_sales,
--MIN(order_date) AS first_order,
CASE WHEN MIN(order_date) >= '2013-02-01' THEN 'New customer' -- Assuming date is 2014-02-01 captures all first orders 12 months or less
    WHEN SUM(f.sales_amount) < 5000 THEN 'Regular customer'
    WHEN SUM(f.sales_amount) >= 5000 THEN 'VIP customer'
    ELSE 'Review edge case'
END AS customer_classification
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON f.customer_key = c.customer_key
GROUP BY f.customer_key, c.first_name, c.last_name
HAVING MIN(order_date) >= '2013-02-01'
ORDER BY total_sales

-- Adding a count to developed classifications


WITH customer_segment AS (
    SELECT
    f.customer_key,
    CASE WHEN MIN(order_date) >= '2013-02-01' THEN 'New customer' -- Assuming date is 2014-02-01 captures all first orders 12 months or less
        WHEN SUM(f.sales_amount) < 5000 THEN 'Regular customer'
        WHEN SUM(f.sales_amount) >= 5000 THEN 'VIP customer'
        ELSE 'Review edge case'
    END AS customer_classification
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_customers AS c
    ON f.customer_key = c.customer_key
    GROUP BY f.customer_key
)
SELECT
customer_classification,
COUNT(customer_key) AS total_customers
FROM customer_segment
GROUP BY customer_classification