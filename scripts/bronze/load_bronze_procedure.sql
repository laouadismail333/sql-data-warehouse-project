/*
===============================================================================
Procedure:      bronze.load_bronze
Description:    Loads raw CRM and ERP data from CSV files into the Bronze layer.

Process:
    1. Truncate existing Bronze tables.
    2. Load raw CSV data using BULK INSERT.
    3. Measure load duration for each table.
    4. Measure total Bronze layer load duration.
    5. Handle and propagate errors.

Source Systems:
    - CRM
    - ERP

Target Layer:
    - Bronze

Author:         Ismail Laouad
Created:        2026-09-23
===============================================================================
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    DECLARE 
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME;

    SET @batch_start_time = GETDATE();

    BEGIN TRY

        PRINT '<<< ======================================================== >>>';
        PRINT '                    LOADING Bronze Layer';
        PRINT '<<< ======================================================== >>>';

        PRINT '<<< ======================================================== >>>';
        PRINT '                    Loading CRM Tables';
        PRINT '<<< ======================================================== >>>';


        SET @start_time = GETDATE();

        PRINT '// Truncating TABLE bronze.crm_cust_info';

        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '// Inserting DATA using BULK INSERT IN TABLE bronze.crm_cust_info';

        BULK INSERT bronze.crm_cust_info
        FROM 'D:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);


        SET @start_time = GETDATE();

        PRINT '// Truncating TABLE bronze.crm_prd_info';

        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '// Inserting DATA using BULK INSERT IN TABLE bronze.crm_prd_info';

        BULK INSERT bronze.crm_prd_info
        FROM 'D:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);


        SET @start_time = GETDATE();

        PRINT '// Truncating TABLE bronze.crm_sales_details';

        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '// Inserting DATA using BULK INSERT IN TABLE bronze.crm_sales_details';

        BULK INSERT bronze.crm_sales_details
        FROM 'D:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);


        PRINT '<<< ======================================================== >>>';
        PRINT '                    Loading ERP Tables';
        PRINT '<<< ======================================================== >>>';


        SET @start_time = GETDATE();

        PRINT '// Truncating TABLE bronze.erp_loc_a101';

        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '// Inserting DATA using BULK INSERT IN TABLE bronze.erp_loc_a101';

        BULK INSERT bronze.erp_loc_a101
        FROM 'D:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);


        SET @start_time = GETDATE();

        PRINT '// Truncating TABLE bronze.erp_cust_az12';

        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '// Inserting DATA using BULK INSERT IN TABLE bronze.erp_cust_az12';

        BULK INSERT bronze.erp_cust_az12
        FROM 'D:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);


        SET @start_time = GETDATE();

        PRINT '// Truncating TABLE bronze.erp_px_cat_g1v2';

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '// Inserting DATA using BULK INSERT IN TABLE bronze.erp_px_cat_g1v2';

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'D:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR);


        PRINT '>>> ===================================================================';
        PRINT '>>> ===================================================================';

        SET @batch_end_time = GETDATE();

        PRINT '>>> Load Duration of bronze layer: '
            + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR);

    END TRY

    BEGIN CATCH

        PRINT '===========================================';

        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';

        PRINT 'ERROR Message: ' + ERROR_MESSAGE();

        PRINT 'ERROR Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);

        PRINT 'ERROR Line: ' + CAST(ERROR_LINE() AS NVARCHAR);

        PRINT '===========================================';

    END CATCH;

END;
GO

EXEC bronze.load_bronze;
GO
