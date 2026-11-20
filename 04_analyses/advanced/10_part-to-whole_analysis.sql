/*
Part-to-Whole Analysis
Analyze how an individual part is performing compared to the overall, to understand which category has the greatest impact on the business

( [Measure] / Total [Measure]) * 100 By [Dimension]
e.g. (Sales / Total Sales) * 100 By Category
    (Quantity / Total Quantity) * 100 By Country
*/


-- Which categories contribute the most to overall sales?
-- 

-- Query involves grain grouped at the category level, compared to grain at the organization level
--  total_sales: category grain
--  overall_sales: organizational grain
--  pct_of_total: category grain (developed as total_sales / overall_sales)


WITH category_sales AS (
    SELECT
    p.category,
    SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT
category,
total_sales,
SUM(total_sales) OVER () AS overall_sales,
CONCAT(ROUND(total_sales / SUM(total_sales) OVER () * 100, 2), '%') AS pct_of_total
FROM category_sales
ORDER BY total_sales DESC;


