/*
===============================================================================
Procedure:      silver.load_silver
Author:         Ismail Laouad
Created:        2026-09-29
Project:        SQL Data Warehouse
Layer:          Silver

Description:
    Loads cleaned, standardized, and transformed data from the Bronze layer
    into the Silver layer of the data warehouse.

    The Silver layer is responsible for transforming raw Bronze data into
    clean and standardized datasets that are ready for further integration
    and business-level modeling in the Gold layer.

Source Tables:
    CRM:
        - bronze.crm_cust_info
        - bronze.crm_prd_info
        - bronze.crm_sales_details

    ERP:
        - bronze.erp_cust_az12
        - bronze.erp_loc_a101
        - bronze.erp_px_cat_g1v2

Target Tables:
    CRM:
        - silver.crm_cust_info
        - silver.crm_prd_info
        - silver.crm_sales_details

    ERP:
        - silver.erp_cust_az12
        - silver.erp_loc_a101
        - silver.erp_px_cat_g1v2

Transformations Performed:
    CRM Customer:
        - Remove duplicate customer records.
        - Keep the latest customer record based on creation date.
        - Trim first and last names.
        - Standardize marital status.
        - Standardize gender values.

    CRM Product:
        - Extract category ID from product key.
        - Standardize product key.
        - Replace NULL product costs with zero.
        - Standardize product line descriptions.
        - Convert product start dates to DATE.
        - Generate product end dates using LEAD().

    CRM Sales:
        - Remove duplicate sales order records.
        - Standardize product keys.
        - Convert integer date values into DATE.
        - Validate and recalculate sales amounts.
        - Correct invalid or missing prices.
        - Preserve valid sales quantities.

    ERP Customer:
        - Remove the 'NAS' prefix from customer IDs.
        - Validate birth dates.
        - Standardize gender values.

    ERP Location:
        - Remove '-' characters from customer IDs.
        - Standardize country names.
        - Handle missing country values.

    ERP Product Category:
        - Load category data from Bronze without additional transformations.

Process:
    1. Record batch start time.
    2. Truncate existing Silver tables.
    3. Transform and load data from Bronze.
    4. Measure execution time for each table.
    5. Display inserted row counts.
    6. Display total Silver layer execution time.
    7. Handle errors using TRY...CATCH.

Error Handling:
    - Captures SQL error message.
    - Captures SQL error number.
    - Captures SQL error line.
    - Displays an error summary if the Silver load fails.

Important:
    - This procedure performs a full refresh of the Silver layer.
    - Existing Silver data is removed using TRUNCATE TABLE before loading.
    - Transformation logic is intentionally separated from the Bronze layer
      to preserve raw source data.
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    DECLARE
        @start_time       DATETIME,
        @end_time         DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time   DATETIME;

    SET @batch_start_time = GETDATE();

    BEGIN TRY

        PRINT '===============================================================================';
        PRINT '>> STARTING SILVER LAYER LOAD';
        PRINT '===============================================================================';
        PRINT '';

        /*===============================================================================
            TABLE: silver.crm_cust_info
        ===============================================================================*/

        PRINT '===============================================================================';
        PRINT '>> Starting Load: silver.crm_cust_info';
        PRINT '>> Step 1: Truncating Table';
        PRINT '===============================================================================';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Step 2: Inserting Transformed Data Into silver.crm_cust_info';

        INSERT INTO silver.crm_cust_info
        (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_material_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS trimmed_firstname,
            TRIM(cst_lastname) AS trimmed_lastname,

            CASE
                WHEN UPPER(TRIM(cst_material_status)) = 'S'
                    THEN 'Single'
                WHEN UPPER(TRIM(cst_material_status)) = 'M'
                    THEN 'Married'
                ELSE 'n/a'
            END AS cst_material_status,

            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'F'
                    THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M'
                    THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr,

            cst_create_date

        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER
                (
                    PARTITION BY cst_id
                    ORDER BY cst_create_date DESC
                ) AS flag_last

            FROM bronze.crm_cust_info

        ) t

        WHERE flag_last = 1;

        SET @end_time = GETDATE();

        PRINT '>> Rows Inserted: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
        PRINT '>> Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';
        PRINT '>> Completed Load: silver.crm_cust_info';
        PRINT '';


        /*===============================================================================
            TABLE: silver.crm_prd_info
        ===============================================================================*/

        PRINT '===============================================================================';
        PRINT '>> Starting Load: silver.crm_prd_info';
        PRINT '>> Step 1: Truncating Table';
        PRINT '===============================================================================';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> Step 2: Inserting Transformed Data Into silver.crm_prd_info';

        INSERT INTO silver.crm_prd_info
        (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_codt,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,

            REPLACE(
                SUBSTRING(prd_key, 1, 5),
                '-',
                '_'
            ) AS cat_id,

            SUBSTRING(
                prd_key,
                7,
                LEN(prd_key)
            ) AS prd_key,

            prd_nm,

            ISNULL(
                prd_codt,
                0
            ) AS prd_codt,

            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,

            CAST(prd_start_dt AS DATE) AS prd_start_dt,

            CAST(
                LEAD(prd_start_dt) OVER
                (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt
                ) - 1
                AS DATE
            ) AS prd_end_dt

        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();

        PRINT '>> Rows Inserted: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
        PRINT '>> Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';
        PRINT '>> Completed Load: silver.crm_prd_info';
        PRINT '';


        /*===============================================================================
            TABLE: silver.crm_sales_details
        ===============================================================================*/

        PRINT '===============================================================================';
        PRINT '>> Starting Load: silver.crm_sales_details';
        PRINT '>> Step 1: Truncating Table';
        PRINT '===============================================================================';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>> Step 2: Inserting Transformed Data Into silver.crm_sales_details';

        INSERT INTO silver.crm_sales_details
        (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_price,
            sls_quantity
        )
        SELECT
            sls_ord_num,

            SUBSTRING(
                sls_prd_key,
                1,
                7
            ) AS sls_prd_key,

            sls_cust_id,

            TRY_CAST(
                CAST(
                    NULLIF(sls_order_dt, 0)
                    AS VARCHAR(8)
                )
                AS DATE
            ) AS sls_order_dt,

            TRY_CAST(
                CAST(sls_ship_dt AS VARCHAR(8))
                AS DATE
            ) AS sls_ship_dt,

            TRY_CAST(
                CAST(sls_due_dt AS VARCHAR(8))
                AS DATE
            ) AS sls_due_dt,

            CASE
                WHEN sls_sales IS NULL
                     OR sls_sales <= 0
                     OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales,

            CASE
                WHEN sls_price IS NULL
                     OR sls_price <= 0
                THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE ABS(sls_price)
            END AS sls_price,

            sls_quantity

        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER
                (
                    PARTITION BY sls_ord_num
                    ORDER BY sls_ord_num
                ) AS flag_last

            FROM bronze.crm_sales_details

        ) AS t

        WHERE flag_last = 1;

        SET @end_time = GETDATE();

        PRINT '>> Rows Inserted: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
        PRINT '>> Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';
        PRINT '>> Completed Load: silver.crm_sales_details';
        PRINT '';


        /*===============================================================================
            TABLE: silver.erp_cust_az12
        ===============================================================================*/

        PRINT '===============================================================================';
        PRINT '>> Starting Load: silver.erp_cust_az12';
        PRINT '>> Step 1: Truncating Table';
        PRINT '===============================================================================';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT '>> Step 2: Inserting Transformed Data Into silver.erp_cust_az12';

        INSERT INTO silver.erp_cust_az12
        (
            cid,
            bdate,
            gen
        )
        SELECT

            CASE
                WHEN cid LIKE 'NAS%'
                THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END AS cid,

            CASE
                WHEN bdate < '1924-01-01'
                     OR bdate > GETDATE()
                THEN NULL
                ELSE bdate
            END AS bdate,

            CASE
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE')
                THEN 'Female'

                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')
                THEN 'Male'

                ELSE 'n/a'
            END AS gen

        FROM bronze.erp_cust_az12;

        SET @end_time = GETDATE();

        PRINT '>> Rows Inserted: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
        PRINT '>> Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';
        PRINT '>> Completed Load: silver.erp_cust_az12';
        PRINT '';


        /*===============================================================================
            TABLE: silver.erp_loc_a101
        ===============================================================================*/

        PRINT '===============================================================================';
        PRINT '>> Starting Load: silver.erp_loc_a101';
        PRINT '>> Step 1: Truncating Table';
        PRINT '===============================================================================';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT '>> Step 2: Inserting Transformed Data Into silver.erp_loc_a101';

        INSERT INTO silver.erp_loc_a101
        (
            cid,
            cntry
        )
        SELECT

            REPLACE(
                cid,
                '-',
                ''
            ) AS cid,

            CASE
                WHEN UPPER(TRIM(cntry)) = 'DE'
                THEN 'Germany'

                WHEN UPPER(TRIM(cntry)) IN ('USA', 'US')
                THEN 'United States'

                WHEN cntry IS NULL
                     OR TRIM(cntry) = ''
                THEN 'n/a'

                ELSE TRIM(cntry)
            END AS cntry

        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();

        PRINT '>> Rows Inserted: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
        PRINT '>> Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';
        PRINT '>> Completed Load: silver.erp_loc_a101';
        PRINT '';


        /*===============================================================================
            TABLE: silver.erp_px_cat_g1v2
        ===============================================================================*/

        PRINT '===============================================================================';
        PRINT '>> Starting Load: silver.erp_px_cat_g1v2';
        PRINT '>> Step 1: Truncating Table';
        PRINT '===============================================================================';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT '>> Step 2: Inserting Data Into silver.erp_px_cat_g1v2';

        INSERT INTO silver.erp_px_cat_g1v2
        (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();

        PRINT '>> Rows Inserted: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
        PRINT '>> Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';
        PRINT '>> Completed Load: silver.erp_px_cat_g1v2';
        PRINT '';


        /*===============================================================================
            SILVER LAYER SUMMARY METRICS
        ===============================================================================*/

        SET @batch_end_time = GETDATE();

        PRINT '===============================================================================';
        PRINT '>> SILVER LAYER LOAD COMPLETED SUCCESSFULLY';
        PRINT '>> Total Batch Execution Time: '
              + CAST(
                    DATEDIFF(
                        SECOND,
                        @batch_start_time,
                        @batch_end_time
                    ) AS NVARCHAR
                )
              + ' seconds';
        PRINT '===============================================================================';

    END TRY

    BEGIN CATCH

        PRINT '===========================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'ERROR Message: ' + ERROR_MESSAGE();
        PRINT 'ERROR Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'ERROR Line:    ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT '===========================================';

    END CATCH
END;
GO
