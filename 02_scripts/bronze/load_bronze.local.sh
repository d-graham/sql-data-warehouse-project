# Script exclusion added to .gitignore "*.local.sh"
# Exclusion to avoid upload of user name or local path details to github.

#!/usr/bin/env bash
# Load bronze CSVs. Run from anywhere; uses absolute paths.
# Connection: adjust -h/-U/-d if needed.

# Open in terminal and make script executable by: chmod +x load_bronze.local.sh
# Run script with ./load_bronze.local.sh


psql -h localhost -d datawarehouse -U postgres <<EOF
TRUNCATE TABLE bronze.crm_cust_info;
\copy bronze.crm_cust_info FROM '/home/owner/Documents/projects/sql-data-warehouse-project/00_datasets/source_crm/cust_info.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',')
TRUNCATE TABLE bronze.crm_prd_info;
\copy bronze.crm_prd_info FROM '/home/owner/Documents/projects/sql-data-warehouse-project/00_datasets/source_crm/prd_info.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',')
TRUNCATE TABLE bronze.crm_sales_details;
\copy bronze.crm_sales_details FROM '/home/owner/Documents/projects/sql-data-warehouse-project/00_datasets/source_crm/sales_details.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',')
TRUNCATE TABLE bronze.erp_cust_az12;
\copy bronze.erp_cust_az12 FROM '/home/owner/Documents/projects/sql-data-warehouse-project/00_datasets/source_erp/CUST_AZ12.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',')
TRUNCATE TABLE bronze.erp_loc_a101;
\copy bronze.erp_loc_a101 FROM '/home/owner/Documents/projects/sql-data-warehouse-project/00_datasets/source_erp/LOC_A101.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',')
TRUNCATE TABLE bronze.erp_px_cat_g1v2;
\copy bronze.erp_px_cat_g1v2 FROM '/home/owner/Documents/projects/sql-data-warehouse-project/00_datasets/source_erp/PX_CAT_G1V2.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',')
EOF