-- Create view in the gold layer.
-- CRM is the master data while selecting the customer info.
-- For gender selection crm_cust_info is preferred.

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
     
