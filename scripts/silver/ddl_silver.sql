/*
============================================================
Layer      : Silver
Purpose    : Creating a table
============================================================
*/
  
CREATE SCHEMA Silver;
DROP TABLE IF EXISTS Silver.crm_cust_info;
Create Table Silver.crm_cust_info
(
cst_id int,
cst_key varchar(50),
cst_firstname varchar(50),
cst_lastname VARCHAR(50),
cst_marital_status varchar(50),
cst_gndr varchar(10),
cst_create_date Date,
dwh_create_date DATETIME DEFAULT GETDATE()
);

DROP TABLE IF EXISTS Silver.crm_prd_info;
Create Table Silver.crm_prd_info(
prd_id INT,
cat_id VARCHAR(50),
prd_key varchar(50),
prd_nm varchar(50),
prd_cost decimal(19,4),
prd_line varchar(50),
prd_start_dt date,
prd_end_dt date,
dwh_create_date DATETIME DEFAULT GETDATE()
);

DROP TABLE IF EXISTS Silver.crm_sales_info;
Create Table Silver.crm_sales_info(
sls_ord_num varchar(50),
sls_prd_key varchar(50),
sls_cust_id INT,
sls_order_dt DATE,
sls_ship_dt DATE,
sls_due_dt DATE,
sls_sales INT,
sls_quantity INT,
sls_price INT,
dwh_create_date DATETIME DEFAULT GETDATE()
);

DROP TABLE IF EXISTS Silver.erp_cust_az12;
Create Table Silver.erp_cust_az12(
cid varchar(50),
bdate DATE,
gen varchar(50),
dwh_create_date DATETIME DEFAULT GETDATE()
);

DROP TABLE IF EXISTS Silver.erp_loc_a101;
Create Table Silver.erp_loc_a101(
cid varchar(50),
ctry varchar(50),
dwh_create_date DATETIME DEFAULT GETDATE()
);

DROP TABLE IF EXISTS Silver.erp_px_cat_giv2;
Create Table Silver.erp_px_cat_giv2(
id varchar(50),
cat varchar(50),
subcat varchar(50),
maintenance varchar(50),
dwh_create_date DATETIME DEFAULT GETDATE()
);
