------------------------
  Test
  customer_dim_layer
-----------------------

-- Check if there is any duplicates.
SELECT cst_id, COUNT(*)
FROM (
	SELECT 
		ci.cst_id,
		ci.cst_key,
		ci.cst_firstname,
		ci.cst_lastname,
		ci.cst_marital_status,
		CASE
			WHEN ci.cst_gndr = 'n/a' THEN ei.gen
			ELSE ci.cst_gndr
			END AS cst_gndr,
		ci.cst_create_date,
		ei.bdate,
		ei.gen,
		li.ctry
	FROM 
		Silver.crm_cust_info AS ci
	LEFT JOIN
		Silver.erp_cust_az12 AS ei
		ON ci.cst_key = ei.cid
	LEFT JOIN
		Silver.erp_loc_a101 AS li
		ON ci.cst_key = li.cid
     ) t
GROUP BY cst_id
HAVING COUNT(*) >1 


-- Checking the gender column
-- Assume the crm_cust_info table as the main table
-- Checking the distinct values from the gender table and than arrange it accordingly.
SELECT 
	DISTINCT ci.cst_gndr,
	ei.gen,
	CASE 
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master Table for gender selection
		ELSE COALESCE(ei.gen, 'n/a')
		END gen_test
FROM 
	Silver.crm_cust_info AS ci
LEFT JOIN
	Silver.erp_cust_az12 AS ei
	ON ci.cst_key = ei.cid
LEFT JOIN
	Silver.erp_loc_a101 AS li
	ON ci.cst_key = li.cid


------------------------
    Test
  product_dim_layer
------------------------
  
-- Filter out the historical data and then
--Checking the duplicates since prd_key is unique 
SELECT prd_key,
	COUNT(*)
FROM(
	SELECT 
		prd.prd_id, 
		prd.cat_id,
		ca.cat,
		ca.subcat,
		prd.prd_key,
		prd.prd_nm,
		prd.prd_cost,
		prd.prd_line,
		ca.maintenance,
		prd.prd_start_dt,
		prd.prd_end_dt
	FROM 
		Silver.crm_prd_info prd
	LEFT JOIN 
		Silver.erp_px_cat_giv2 ca
		ON prd.cat_id = ca.id
	WHERE 
		prd_end_dt IS NULL --Filter out the current product cost
			) t
GROUP BY prd_key
Having COUNT(*)>1

-- For each subcategory there is a cat_id
SELECT 
		DISTINCT 
		prd.cat_id,
		ca.subcat
FROM 
	Silver.crm_prd_info prd
LEFT JOIN 
	Silver.erp_px_cat_giv2 ca
	ON prd.cat_id = ca.id




------------------------
    Test
  Gold_fact_layer
------------------------
SELECT 
	cu.customer_key,
	COUNT(*)
FROM gold.fact_sales ft
LEFT JOIN gold.dim_customer cu
	ON ft.customer_key = cu.customer_key
GROUP BY cu.customer_key
HAVING COUNT(*)>1


SELECT *
FROM gold.fact_sales ft
LEFT JOIN gold.dim_customer cu
	ON ft.customer_key = cu.customer_key
WHERE cu.customer_key IS NULL


