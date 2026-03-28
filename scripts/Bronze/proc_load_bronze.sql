/*
	--Bulk insert the data inside the tabels. firstrow=2, fieldtermminator=',',tablock.
	--Truncate the table so that it can always take the updated values.
	--Covered it into stored procedure with CREATE OR ALTER PROCEDURE
	--To know if there is an error we have created a CATCH.
*/

CREATE OR ALTER PROCEDURE Bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME ,
			@end_time DATETIME,
			@batch_start_time DATETIME,
			@batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=========================================================================================';
		PRINT 'Loading files into CRP';
		PRINT '=========================================================================================';

		PRINT '------------------------------------------------------------------------------------------';
		PRINT '>>>TRUNCATING INTO: Bronze.crm_cust_info';
		PRINT '------------------------------------------------------------------------------------------';
		TRUNCATE TABLE Bronze.crm_cust_info;
		
		SET @start_time = GETDATE();
		PRINT '..........................................................................................';
		PRINT '>>>INSERTING INTO: Bronze.crm_cust_info';
		PRINT '..........................................................................................';
		SET @start_time = GETDATE();
		Bulk insert Bronze.crm_cust_info
		From 'C:\Users\hp\OneDrive\Desktop\pow\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '------------------------------------------------------------------------------------------';
		PRINT '>>Loading Time: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS VARCHAR)+ 'ms';
		PRINT '------------------------------------------------------------------------------------------';
		PRINT '>>>TRUNCATING INTO: Bronze.crm_prd_info';
		PRINT '------------------------------------------------------------------------------------------';
		TRUNCATE TABLE Bronze.crm_prd_info;

		SET @start_time = GETDATE();
		PRINT '..........................................................................................';
		PRINT '>>>INSERTING INTO: Bronze.crm_prd_info';
		PRINT '..........................................................................................';
		BULK INSERT Bronze.crm_prd_info
		From 'C:\Users\hp\OneDrive\Desktop\pow\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR= ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '------------------------------------------------------------------------------------------';
		PRINT '>> Loading Time: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS VARCHAR) + 'ms';
		PRINT '------------------------------------------------------------------------------------------';
		PRINT '>>>TRUNCATING INTO: Bronze.crm_sales_info';
		PRINT '------------------------------------------------------------------------------------------';
		TRUNCATE TABLE Bronze.crm_sales_info;

		SET @start_time = GETDATE();
		PRINT '..........................................................................................';
		PRINT '>>>INSERTING INTO: Bronze.crm_sales_info';
		PRINT '..........................................................................................';
		BULK INSERT Bronze.crm_sales_info
		FROM 'C:\Users\hp\OneDrive\Desktop\pow\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
	    PRINT '------------------------------------------------------------------------------------------';
		PRINT '>>Loading time: ' + CAST(DATEDIFF(millisecond, @start_time , @end_time) AS VARCHAR) + 'ms';
		PRINT '------------------------------------------------------------------------------------------';
		PRINT '>>>TRUNCATING INTO: Bronze.erp_cust_az12';
		PRINT '------------------------------------------------------------------------------------------';
		TRUNCATE TABLE Bronze.erp_cust_az12;
		SET @start_time = GETDATE();
		PRINT '..........................................................................................';
		PRINT '>>>INSERTING INTO: Bronze.erp_cust_az12';
		PRINT '..........................................................................................';
		BULK INSERT Bronze.erp_cust_az12
		FROM 'C:\Users\hp\OneDrive\Desktop\pow\sql-data-warehouse-project-main\datasets\source_erp\cust_az12.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '------------------------------------------------------------------------------------------';
		PRINT '>>Loading Time:' + CAST(DATEDIFF(millisecond, @start_time , @end_time) AS VARCHAR) + 'ms';
		PRINT '------------------------------------------------------------------------------------------';
		PRINT '>>>TRUNCATING INTO: Bronze.erp_loc_a101';
		PRINT '------------------------------------------------------------------------------------------';
		TRUNCATE TABLE Bronze.erp_loc_a101;

		SET @start_time = GETDATE();
		PRINT '..........................................................................................';
		PRINT '>>>INSERTING INTO: Bronze.erp_loc_a101';
		PRINT '..........................................................................................';
		BULK INSERT Bronze.erp_loc_a101
		FROM 'C:\Users\hp\OneDrive\Desktop\pow\sql-data-warehouse-project-main\datasets\source_erp\loc_a101.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
	    PRINT '------------------------------------------------------------------------------------------';
		PRINT '>>Loading Time: ' + CAST(DATEDIFF(millisecond, @start_time , @end_time) AS VARCHAR) + 'ms';
		PRINT '------------------------------------------------------------------------------------------';
		PRINT '>>>TRUNCATING INTO: Bronze.erp_px_cat_giv2';
		PRINT '------------------------------------------------------------------------------------------';
		TRUNCATE TABLE Bronze.erp_px_cat_giv2

		SET @start_time = GETDATE();
		PRINT '..........................................................................................';
		PRINT '>>>INSERTING INTO: Bronze.erp_px_cat_giv2';
		PRINT '..........................................................................................';
		BULK INSERT Bronze.erp_px_cat_giv2
		FROM 'C:\Users\hp\OneDrive\Desktop\pow\sql-data-warehouse-project-main\datasets\source_erp\px_cat_giv2.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '..........................................................................................';
		PRINT '>>Loading Time: ' + CAST(DATEDIFF(millisecond, @start_time , @end_time) AS VARCHAR) + 'ms';

		SET @batch_end_time =GETDATE();
		PRINT '------------------';
		PRINT '>> Batch Loading Time: ' + CAST(DATEDIFF(millisecond, @batch_start_time, @batch_end_time) AS VARCHAR) + 'ms';
	END TRY

	BEGIN CATCH
		PRINT '========Catch Block=====';
		PRINT 'Error Message: '+ ERROR_MESSAGE();
		PRINT 'Error Message: '+ CAST (ERROR_NUMBER() AS VARCHAR);
		PRINT 'Error Message: '+ CAST (ERROR_STATE() AS VARCHAR);
	END CATCH
END;

EXEC Bronze.load_bronze; --For executing the procedure.

