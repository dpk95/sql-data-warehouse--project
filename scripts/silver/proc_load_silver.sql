/*
	--Insert the data inside the tables.
	--Truncate the table so that it can always take the updated values.
	--Covered it into stored procedure with CREATE OR ALTER PROCEDURE
	--To know if there is an error we have created a CATCH.
	--Used variables so that can get the time for loading.
*/


CREATE OR ALTER Procedure Silver.load_silver
AS
BEGIN
	DECLARE @start_time DATETIME,
			 @end_time DATETIME,
			 @batch_start_time DATETIME,
			 @batch_end_time DATETIME
	BEGIN TRY
			
			SET @batch_start_time = GETDATE();
			PRINT '=================LOADING CRM============================='
			SET @start_time = GETDATE();
			PRINT '>>> Truncating into: Silver.crm_cust_info <<<';
			TRUNCATE TABLE Silver.crm_cust_info
			PRINT '>>> Insert Into:Silver.crm_cust_info <<<';
			INSERT INTO 
				Silver.crm_cust_info(
					cst_id,
					cst_key,
					cst_firstname,
					cst_lastname,
					cst_gndr,
					cst_marital_status,
					cst_create_date
				)	
			SELECT 
				cst_id,
				cst_key,
				TRIM(cst_firstname) AS cst_firstname, -- Remove unwanted spaces
				TRIM(cst_lastname) AS cst_lastname,
				CASE
					WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
					WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' -- Handled the abbrivated values with full string
					ELSE 'n/a'
					END AS cst_gndr,
					CASE
					WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
					WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married' -- Handled the abbrivated values with full string
					ELSE 'n/a'
					END AS cst_marital_status,
				cst_create_date 
			FROM(
				SELECT 
					*,
					ROW_NUMBER()
						OVER(
							PARTITION BY cst_id 
							ORDER BY cst_create_date DESC -- Removing the duplicates by arranging the date
							) Ranking
				FROM 
					Bronze.crm_cust_info
				WHERE cst_id IS NOT NULL
				) AS info
			WHERE Ranking = 1

			SET @end_time = GETDATE();
			PRINT 'Loading Time:' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS VARCHAR) + 'ms';
			PRINT '-----------------'

			PRINT '=================='
			SET @start_time = GETDATE();
			PRINT '>>> Truncating into: Silver.crm_prd_info <<<';
			TRUNCATE TABLE Silver.crm_prd_info
			PRINT '>>> Insert Into: Silver.crm_prd_info <<<';
			INSERT INTO Silver.crm_prd_info(
				prd_id,
				cat_id,
				prd_key,
				prd_nm,
				prd_cost,
				prd_line,
				prd_start_dt,
				prd_end_dt)

			SELECT 
				prd_id,
				REPLACE (SUBSTRING(prd_key, 1, 5),'-','_') cat_id, --Extract Category ID
				SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key, -- Extract Product Key
				prd_nm,
				CAST(ISNULL(prd_cost, 0)AS INT) AS prd_cost, -- Replaced NULL values with zero and cast it to INT
				CASE 
					WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
					WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
					WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
					WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
					ELSE 'n/a'
				END AS prd_line, -- Map the Product Line codes with Discriptive Values
				prd_start_dt,
				DATEADD(
					DAY, 
					-1, 
					LEAD(prd_start_dt) OVER(
										PARTITION BY prd_key 
										ORDER BY prd_start_dt))
										AS prd_end_dt -- Calculate the End-date as one day before the Start-date 
			FROM Bronze.crm_prd_info

			SET @end_time = GETDATE();
			PRINT 'Loading Time: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS VARCHAR) + 'ms';
			PRINT '-------------------';


			SET @start_time= GETDATE();
			PRINT '==================';
			PRINT '>>> Truncating into: Silver.crm_sales_info <<<';
			TRUNCATE TABLE Silver.crm_sales_info
			PRINT '>>> Insert Into: Silver.crm_sales_info <<<';
			INSERT INTO Silver.crm_sales_info(
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				sls_order_dt,
				sls_ship_dt,
				sls_due_dt,
				sls_sales,
				sls_quantity,
				sls_price
				)

			SELECT 
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				CAST(CAST(CASE 
						WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
						ELSE (sls_order_dt) 
						END AS VARCHAR) AS DATE) AS sls_order_dt, -- Check the date authenticity and than changed it to Date format
				CAST(CAST(CASE 
						WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
						ELSE (sls_ship_dt)
						END AS VARCHAR) AS DATE) AS sls_ship_dt,-- Check the date authenticity and than changed it to Date format
				CAST(CAST(CASE 
						WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
						ELSE (sls_due_dt)
						END AS VARCHAR) AS DATE) AS sls_due_dt,-- Check the date authenticity and than changed it to Date format
				CASE 
				WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != ABS(sls_price) * sls_quantity
					THEN ABS(sls_price) * sls_quantity
				ELSE sls_sales
				END AS sls_sales, -- Change the sales data with sales price and sales quantity
				sls_quantity,
				CASE 
					WHEN sls_price <= 0 OR sls_price IS NULL
						THEN sls_sales/sls_quantity
					ELSE sls_price
					END as sls_price -- Cleaning the price data with sales and quantity
			FROM
				Bronze.crm_sales_info
			SET @end_time = GETDATE();
			PRINT 'Loading Time: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS VARCHAR) + 'ms';
			PRINT '-------------------';

			PRINT '==============LOADING ERP======================'
			SET @start_time= GETDATE();
			PRINT '==================';
			PRINT '>>> Truncating into: Silver.erp_cust_az12 <<<';
			TRUNCATE TABLE Silver.erp_cust_az12
			PRINT '>>> Insert Into: Silver.erp_cust_az12 <<<';
			INSERT INTO Silver.erp_cust_az12(
				cid,
				bdate,
				gen)

			SELECT 
				CASE 
					WHEN cid LIKE 'NAS%'
						THEN TRIM(SUBSTRING(cid, 4, LEN(cid))) -- Removed the prefix 'NAS' if present
					ELSE TRIM(cid) 
				END AS cid, 
				CASE 
					WHEN bdate > GETDATE() THEN NULL -- Cleaned and changed the future Birth_dt to NULL
					ELSE bdate
					END 
				bdate,
				CASE
					WHEN UPPER(TRIM(gen)) IN ('F','Female') then 'Female' -- Normalise the gender values and handle the unknown cases
					WHEN UPPER(TRIM(gen)) IN ('M','Male') THEN 'Male'
					ELSE 'n/a'
				END gen
			FROM Bronze.erp_cust_az12
			SET @end_time = GETDATE();
			PRINT 'Time Loading: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS VARCHAR) + 'ms';
			PRINT '-------------------';


			SET @start_time= GETDATE();
			PRINT '==================';
			PRINT '>>> Truncating into: Silver.erp_loc_a101 <<<';
			TRUNCATE TABLE Silver.erp_loc_a101
			PRINT '>>> Insert Into: Silver.erp_loc_az101 <<<';
			INSERT INTO Silver.erp_loc_a101(cid,ctry)
			SELECT 
				REPLACE(cid, '-', '') as cid, -- Removed '-' from cid
				CASE 
					WHEN TRIM(ctry) IN ('US','USA') THEN 'United States' -- Handled the various unknown values
					WHEN TRIM(ctry) = 'DE' THEN 'Germany'
					WHEN TRIM(ctry) = ''OR TRIM(ctry) IS NULL THEN 'n/a'
					ELSE TRIM(ctry)
					END AS ctry
			FROM Bronze.erp_loc_a101
			SET @end_time = GETDATE();
			PRINT 'Time Loading: '+ CAST(DATEDIFF(millisecond, @start_time, @end_time) AS VARCHAR) + 'ms';
			PRINT '-------------------';


			SET @start_time= GETDATE();
			PRINT '==================';
			PRINT '>>> Truncating into: Silver.erp_px_cat_giv2 <<<';
			TRUNCATE TABLE Silver.erp_px_cat_giv2
			PRINT '>>> Insert Into: Silver.erp_px_cat_giv2 <<<';
			INSERT INTO Silver.erp_px_cat_giv2(id, cat, subcat, maintenance)
			SELECT id, TRIM(cat), TRIM(subcat), maintenance 
			FROM Bronze.erp_px_cat_giv2
			SET @end_time = GETDATE();
			PRINT 'Loading Time: '+ CAST(DATEDIFF(millisecond, @start_time, @end_time) AS VARCHAR)+ 'ms' ;
			PRINT '----------------'

			PRINT '================='
			SET @batch_end_time = GETDATE();
			PRINT 'Loading Time of Procedure: ' + CAST(DATEDIFF(millisecond, @batch_start_time, @batch_end_time) AS VARCHAR) + 'ms';
	END TRY

	BEGIN CATCH
			PRINT '=====ERROR LOADING====';
			PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
			PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS VARCHAR);
	END CATCH

END;

EXEC Silver.load_silver
SELECT *  FROM Silver.erp_cust_az12
