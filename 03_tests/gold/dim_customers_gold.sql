/*
Gold layer
Create the Customer dimension table
*/


-- Joining Customer tables
SELECT
    ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    ci.cst_gndr,
    ci.cst_create_date,
    ca.bdate,
    ca.gen,
    la.cntry
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.cid


-- Check for duplicates after join
-- Expectation: No duplicated rows
SELECT cst_id, COUNT(*) FROM
    (SELECT
        ci.cst_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        ci.cst_marital_status,
        ci.cst_gndr,
        ci.cst_create_date,
        ca.bdate,
        ca.gen,
        la.cntry
    FROM silver.crm_cust_info AS ci
    LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 AS la
    ON ci.cst_key = la.cid
    ) AS customer_t
GROUP BY cst_id
HAVING COUNT(*) > 1


-- Check integration between tables
-- Friction: Mismatch exists in gender field between the customer tables
-- Business rule: Check with stakeholders. In this case the silver.crm_cust_info is considered the source of truth for gender information.
SELECT DISTINCT
    ci.cst_gndr,
    ca.gen,
    (ci.cst_gndr = ca.gen) AS gen_match,
    CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info
    ELSE COALESCE(ca.gen, 'n/a')
    END AS new_gen
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.cid
ORDER BY 1, 2



-- Developing joined tables with integration rules applied
-- Applying naming conventions for readable names using snake_case
-- Dimension table as contents of the table created describe customers
CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, -- adding a surrogate key
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.cntry AS country,
    ci.cst_marital_status AS marital_status,
    CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.cid

-- Verify creation of gold dimensional table
SELECT * FROM gold.dim_customers;

