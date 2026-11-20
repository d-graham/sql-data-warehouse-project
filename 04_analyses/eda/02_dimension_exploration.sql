

-- Explore all countries customers come from

SELECT
DISTINCT country,
COUNT(*) AS count_country
FROM gold.dim_customers
GROUP BY country
ORDER BY country;

-- Explore all categories "the major divisions"

SELECT DISTINCT category, subcategory, product_name
FROM gold.dim_products
ORDER BY category, subcategory, product_name;