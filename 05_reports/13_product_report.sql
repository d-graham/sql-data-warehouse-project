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
Product Report

Purpose:
    - Report consolidates key product metrics and behaviors

Highlights:
    1. Gather essential fields such as product name, category, subcategory, and cost
    2. Segment products by revenue to identify High-Performers, Mid-Range, or Low-Performers
    3. Aggregate product-level metrics:
        - total orders
        - total sales
        - total quantity sold
        - total customers (unique)
        - lifespan (in months)
    4. Calculate KPIs:
        - recency (months since last sale)
        - average order revenue (AOR)
        - average monthly revenue
*/


DROP VIEW IF EXISTS gold.report_products;
CREATE VIEW gold.report_products AS
-- 1 Base Query: Retrieve columns from tables
WITH base_query AS (
    SELECT
    f.order_number,
    f.order_date,
    f.customer_key,
    f.sales_amount,
    f.quantity,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
    WHERE order_date IS NOT NULL
),
-- 2 Product Aggregations: Summarize key metrics at the product level
product_aggregations AS (
    SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    ROUND((MAX(order_date) - MIN(order_date)) / 365.25 * 12,0) AS lifespan,
    MAX(order_date) AS last_sale_date,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(sales_amount)::numeric / NULLIF(SUM(quantity), 0), 2) AS avg_selling_price
    FROM base_query
    GROUP BY product_key, product_name, category, subcategory, cost
)
SELECT
product_key,
product_name,
category,
subcategory,
cost,
last_sale_date,
ROUND(((CURRENT_DATE - last_sale_date) / 365.25 * 12), 0) AS recency_in_months,
CASE
    WHEN total_sales > 50000 THEN 'High-Performer'
    WHEN total_sales >= 10000 THEN 'Mid-Range'
    ELSE 'Low_Performer'
END AS product_segment,
lifespan,
total_orders,
total_sales,
total_quantity,
total_customers,
avg_selling_price,
CASE
    WHEN total_orders = 0 THEN 0
    ELSE total_sales / total_orders
END AS avg_order_revenue,
CASE
    WHEN lifespan = 0 THEN total_sales
    ELSE total_sales / lifespan
END AS avg_monthly_revenue
FROM product_aggregations




SELECT * FROM gold.report_products;

SELECT
product_segment,
COUNT(product_key) AS total_products,
SUM(total_sales) AS total_sales
FROM gold.report_products
GROUP BY product_segment

