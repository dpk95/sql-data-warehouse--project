===================
	TEST-1
	cust_info
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
	cust_info
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
	prd_info
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
	prd_info
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
			
