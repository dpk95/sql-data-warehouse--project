/*
============================================================
Layer      : Bronze
Purpose    : Store raw customer data from CSV ingestion
Description: Creating tables for the Bronze layer
============================================================
*/

DROP TABLE IF EXISTS Bronze.crm_cust_info;
Create Table Bronze.crm_cust_info
(
cst_id int,
cst_key varchar(50),
cst_firstname varchar(50),
cst_lastname VARCHAR(50),
cst_marital_status varchar(50),
cst_gndr varchar(10),
cst_create_date Date
);

DROP TABLE IF EXISTS Bronze.crm_prd_info;
Create Table Bronze.crm_prd_info(
prd_id INT,
prd_key varchar(50),
prd_nm varchar(50),
prd_cost decimal(19,4),
prd_line varchar(50),
prd_start_dt date,
prd_end_dt date
);

DROP TABLE IF EXISTS Bronze.crm_sales_info;
Create Table Bronze.crm_sales_info(
sls_ord_num varchar(50),
sls_prd_key varchar(50),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_dt INT,
sls_sales INT,
sls_quantity INT,
sls_price INT
);

DROP TABLE IF EXISTS Bronze.erp_cust_az12;
Create Table Bronze.erp_cust_az12(
cid varchar(50),
bdate date,
gen varchar(50)
);

DROP TABLE IF EXISTS Bronze.erp_loc_a101;
Create Table Bronze.erp_loc_a101(
cid varchar(50),
ctry varchar(50)
);

DROP TABLE IF EXISTS Bronze.erp_px_cat_giv2;
Create Table Bronze.erp_px_cat_giv2(
id varchar(50),
cat varchar(50),
subcat varchar(50),
maintenance varchar(50)
);
