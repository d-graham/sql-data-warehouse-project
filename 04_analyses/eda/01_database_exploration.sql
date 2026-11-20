/*
Exploratory Data Analysis (EDA)
Database Exploration
*/


-- Explore all objects in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES


-- Explore all columns in the database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'