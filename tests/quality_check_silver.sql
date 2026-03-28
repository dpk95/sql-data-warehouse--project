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

			
