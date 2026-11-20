/*
Cumulative Analysis
Timeseries. Aggregating the data progressively over time.

SUM [Cumulative Measure] By [Date Dimension]

e.g. Running Total Sales By Year
     Moving Average of Sales BY Month

*/

-- Calculate the total sales per month, and the running total of sales over time

-- By month
SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM (
    SELECT
    DATE_TRUNC('month', order_date)::date AS order_date,
    SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date)
    ORDER BY order_date ) AS t


-- By year
SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM (
    SELECT
    DATE_TRUNC('year', order_date)::date AS order_date,
    SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC('year', order_date)
    ORDER BY order_date ) AS t


-- Moving average of price
SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM (
    SELECT
    DATE_TRUNC('year', order_date)::date AS order_date,
    SUM(sales_amount) AS total_sales,
    AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC('year', order_date)
    ORDER BY order_date ) AS t