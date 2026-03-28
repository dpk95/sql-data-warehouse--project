-- Create view in the gold layer.
-- CRM is the master data while selecting the customer info.
-- For gender selection crm_cust_info is preferred.

==================================
	Create the view 
	gold.dim_customer
==================================
CREATE schema gold;
DROP view gold.dim_customer
CREATE VIEW gold.dim_customer
AS
SELECT
	ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_num,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	li.ctry AS country,
	ci.cst_marital_status AS marital_status,
	CASE 
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master Table for gender selection
		ELSE COALESCE(ei.gen, 'n/a')
	END AS gender,
	ei.bdate AS birth_date,
	ci.cst_create_date AS create_date
FROM 
	Silver.crm_cust_info AS ci
LEFT JOIN
	Silver.erp_cust_az12 AS ei
	ON ci.cst_key = ei.cid
LEFT JOIN
	Silver.erp_loc_a101 AS li
	ON ci.cst_key = li.cid


==================================
	Create the view 
	gold.dim_product
==================================
DROP VIEW gold.dim_product
CREATE VIEW gold.dim_product 
AS
SELECT 
		ROW_NUMBER() OVER(ORDER BY prd.prd_start_dt,prd.prd_key) product_key,
		prd.prd_id AS product_id,
		prd.prd_key AS product_num,
		prd.prd_nm AS product_name,
		prd.cat_id AS category_id,
		ca.cat AS category,
		ca.subcat AS sub_category,
		ca.maintenance,
		prd.prd_cost AS   cost,
		prd.prd_line as product_line,
		prd.prd_start_dt AS start_date
	FROM 
		Silver.crm_prd_info prd
	LEFT JOIN 
		Silver.erp_px_cat_giv2 ca
		ON prd.cat_id = ca.id
	WHERE 
		prd_end_dt IS NULL --Filter out the historical data


==================================
	Create the view 
	gold.fact_sales
==================================
CREATE VIEW gold.fact_sales AS
SELECT 
	sa.sls_ord_num AS order_number,
	po.product_key,
	cu.customer_key,
	sa.sls_order_dt AS order_date,
	sa.sls_ship_dt AS ship_date,
	sa.sls_due_dt AS due_date,
	sa.sls_sales as sales_amount,
	sa.sls_quantity AS sales_quantity,
	sa.sls_price AS price
FROM Silver.crm_sales_info sa
LEFT JOIN gold.dim_product po
	ON sa.sls_prd_key = po.product_num
LEFT JOIN gold.dim_customer cu
	ON sa.sls_cust_id = cu.customer_id















