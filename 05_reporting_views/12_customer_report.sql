/*
Build Customer Report
A system is proposed for building up more complicated reporting tasks

Base data (CTE foundation for next steps):
    Fact table as general starting point to start selecting data from the database
    Join it with dimension tables
    Filter data considering what is actually needed for the task
    Trim down to the relevant columns needed
    Transform and derive columns

Aggregations:
    Calculate aggregations next in its own CTE
    Look over the columns from the fact tables and consider which make sense to aggregate

Final results:
    Take the resulting table after aggregations step then develop the final reporting results
*/

/*
Customer Report

Purpose:
    - Report consolidates key customer metrics and behaviors

Highlights:
    1. Gather essential fields such as names, ages, and transaction details
    2. Segment customers into categories (VIP, Regular, New) and age groups
    3. Aggregate customer-level metrics:
        - total orders
        - total sales
        - total quantity purchased
        - total products
*/

DROP VIEW IF EXISTS gold.report_customers;
CREATE VIEW gold.report_customers AS
-- 1 Base Query: Retrieve columns from tables
WITH base_query AS (
    SELECT
    f.order_number,
    f.product_key,
    f.order_date,
    f.sales_amount,
    f.quantity,
    c.customer_key,
    c.customer_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    FLOOR((CURRENT_DATE - c.birthdate) / 365.25) AS customer_age
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_customers AS c
    ON c.customer_key = f.customer_key
    WHERE order_date IS NOT NULL AND c.birthdate IS NOT NULL)
-- 2 Customer Aggregations: Summarize key metrics at the customer level
, customer_aggregation AS (
    SELECT
    customer_key,
    customer_number,
    customer_name,
    customer_age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order_date,
    ROUND((MAX(order_date) - MIN(order_date)) / 365.25 * 12,0) AS lifespan
    FROM base_query
    GROUP BY customer_key, customer_number, customer_name, customer_age
)
SELECT
customer_key,
customer_number,
customer_name,
customer_age,
CASE
    WHEN customer_age < 20 THEN 'Under 20'
    WHEN customer_age < 29 THEN '20-29'
    WHEN customer_age < 39 THEN '30-39'
    WHEN customer_age < 49 THEN '40-49'
    WHEN customer_age < 119 THEN '50 and above'
    ELSE 'REVIEW CASE age_group'
END AS age_group,
CASE
    WHEN lifespan < 12 THEN 'New'
    WHEN total_sales <= 5000 THEN 'Regular'
    WHEN total_sales > 5000 THEN 'VIP'
    ELSE 'REVIEW CASE customer_segment'
END AS customer_segment,
last_order_date,
ROUND((CURRENT_DATE - last_order_date)/365.25 * 12, 0) AS recency,
total_orders,
total_sales,
CASE WHEN total_orders = 0 THEN 0 -- condition check for divide by 0 errors
    ELSE ROUND(total_sales / total_orders, 0)
END AS avg_order_value,
CASE WHEN lifespan = 0 THEN total_sales
    ELSE ROUND(total_sales / lifespan, 0)
END AS avg_monthly_spend
FROM customer_aggregation


SELECT * FROM gold.report_customers;

SELECT
customer_segment,
COUNT(customer_number) AS total_customers,
SUM(total_sales) AS total_sales
FROM gold.report_customers
GROUP BY customer_segment

