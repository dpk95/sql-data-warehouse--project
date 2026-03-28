===================
	TEST-1
	crm_cust_info
===================
--Check for Nulls or Duplicates in Bronze.crm_cst_id.
--Expectation: No Results.
SELECT 
	cst_id, 
	COUNT (*)
FROM Silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*)>1 OR cst_id IS NULL;

--Solved through CTE
WITH cust_info AS(
				SELECT *,
					ROW_NUMBER()
					OVER(
						PARTITION BY cst_id
						ORDER BY cst_create_date DESC
					) ranking
				FROM Bronze.crm_cust_info
	)
DELETE 
FROM cust_info
where ranking>1 OR cst_id is null;

-- Solved through Sub-query
SELECT *
FROM(
	SELECT 
		*,
		ROW_NUMBER()
			OVER(
				PARTITION BY cst_id 
				ORDER BY cst_create_date DESC
				) Ranking
	FROM 
		Bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
	) AS info
WHERE Ranking = 1 


--Checking for Unwanted Spaces.
--Expectations : No Results.

SELECT 
	cst_lastname
FROM Silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname ,
	TRIM(cst_lastname) AS cst_lastname,
	cst_gndr,
	cst_marital_status,
	cst_create_date
FROM Bronze.crm_cust_info;

======================
	TEST-2
	crm_cust_info
======================
--Data Standardisation and Consistency
--Change cst_gndr = M,F as Male & Female.
-- Change cst_marital_status= M or S as Married and single.
-- Use UPPER() & TRIM().

Select DISTINCT cst_marital_status
FROM Silver.crm_cust_info

SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname ,
	TRIM(cst_lastname) AS cst_lastname,
	CASE
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		ELSE 'n/a'
		END AS cst_gndr,
		CASE
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		ELSE 'n/a'
		END AS cst_marital_status,
	cst_create_date
FROM Bronze.crm_cust_info; 

======================================
	Test -1
	crm_prd_info
======================================

-- Checking the prd_id with duplicates
-- Expectations: NO Results
SELECT prd_id, COUNT(*)
FROM Silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*)>1

-- Seperate the main string prd_key to cat_key and than check it with other table's data.
-- To check if all the data in SUBSTRING(prd_key,7,LEN(prd_key) is available in (SELECT sls_prd_key FROM Bronze.crm_sales_info)
-- 'WHERE SUBSTRING(prd_key,7,LEN(prd_key)) IN (SELECT sls_prd_key FROM Bronze.crm_sales_info)'


-- Check for Unwanted Spaces in prd_nm
-- Expectation: No Result

SELECT 
	prd_nm 
FROM 
	Silver.crm_prd_info
WHERE 
	prd_nm != TRIM(prd_nm)

=================================
	Test-2
	crm_prd_info
=================================
-- Checking the prd_cost column with Negative and Null values
-- Removing the NULL values with default values
SELECT 
	prd_cost
FROM 
	Silver.crm_prd_info
WHERE 
	prd_cost < 0 OR prd_cost IS NULL

-- Data Standardisation & Consistency
SELECT DISTINCT 
	prd_line
FROM 
	Silver.crm_prd_info

-- Check for valid date orders
-- And than arrange them in order 
SELECT 
	*
FROM 
	Silver.crm_prd_info
WHERE
	prd_end_dt < prd_start_dt

-- Arrange the start_dt in partition of prd_key
-- Than arrange the end_dt 
-- By using the Leading start_dt as the base
-- ADDDATE to substract the end_dt so that no overlapping can be done.
SELECT
	prd_start_dt,
	ADDDATE(
		DAY,
		-1,
		LEAD(prd_start_dt) 
	OVER(
		PARTITION BY prd_key ORDER BY prd_start_dt)) 
			AS prd_end_dt

==========================
	Test -1
	crm_sales_info
==========================

--This shows that the prd_key is unique for same order_number and customer_id.
--Here for the same customer_id the order_number is same as there can be multiple products ordered by him.
--Therefor the order_number can be same.

SELECT 
	sls_ord_num,
	COUNT(*)
FROM 
	Bronze.crm_sales_info
GROUP BY 
	sls_ord_num
HAVING 
	COUNT(*)>1

-- Data Cleaning 
-- Clecking for spaces
WHERE 
	sls_ord_num != TRIM(sls_ord_num)

-- To Check data consistency
-- Check all the values availabe in sales_product_key.
WHERE 
	sls_prd_key NOT IN (Select prd_key FROM Silver.crm_prd_info)

WHERE 
	sls_cust_id NOT IN (Select cst_id FROM Silver.crm_cust_info)

--Checking the Order date Due date and Shipping date.
-- If order date is 0 OR the length of the order date is not 8 than the date is wrong so convert it to NULL
-- Also check if Order_date is smaller than Shipping_dt, which is smaller than Due_dt.

Where 
	sls_order_dt = 0 OR
	LEN(sls_order_dt) != 8 

WHERE
	sls_order_dt > sls_ship_dt > sls_due_dt

-- Check if Price, Quantity and Sales are zero or negative.
-- Check if Sales = Price* Quantity
SELECT 
	sls_sales,
	sls_quantity,
	sls_price
	/*CASE 
	WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != ABS(sls_price) * sls_quantity
		THEN ABS(sls_price) * sls_quantity
	ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	sls_price AS sls_price_old,
	CASE 
		WHEN sls_price <= 0 OR sls_price IS NULL
			THEN sls_sales/sls_quantity
		ELSE sls_price
		END as sls_price*/
FROM Silver.crm_sales_info
WHERE 
	sls_sales IS NULL OR sls_sales<= 0 OR sls_quantity IS NULL OR sls_quantity <= 0
	OR sls_price IS NULL OR sls_price <= 0 OR sls_sales != sls_price * sls_quantity
ORDER BY sls_sales
			


================================
	Test-1 
	erp_cust_az12
================================

-- Check if the Birth_dt is obselete (future date of birth)
-- Replaced it with NULL
SELECT 
	bdate
FROM Silver.erp_cust_az12
WHERE
	 bdate > GETDATE() 


-- In ERP the customer_ID is cleaned (NAS removed)
-- Matched with customer_key from CRM Customer_info
SELECT * 
FROM Silver.erp_cust_az12
WHERE 
	cid  
	NOT IN (SELECT cst_key FROM Silver.crm_cust_info) 

-- Checked the distince values with Customer_gender
-- Than cleaned the date with customer_gender either male or female or n/a.
SELECT distinct gen
	FROM Silver.erp_cust_az12

	
======================
	Test-1
	erp_loc_a101
======================
-- Checked the cid of erp_location table with cst of crm_customer_info table
-- Removed the hyphen(-) 
SELECT 
	cid,
FROM Bronze.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key from Silver.crm_cust_info)

-- Normalisation and Data Consistency
-- Handling the unknown values
SELECT 
	DISTINCT CASE 
		WHEN TRIM(ctry) IN ('US','USA') THEN 'United States'
		WHEN TRIM(ctry) = 'DE' THEN 'Germany'
		WHEN TRIM(ctry) = ''OR TRIM(ctry) IS NULL THEN 'n/a'
		ELSE TRIM(ctry)
		END AS ctry_new
FROM Bronze.erp_loc_a101



