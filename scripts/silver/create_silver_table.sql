/*
===============================================================================
Script:         Silver Layer - Table Creation
Author:         Ismail Laouad
Created:        2026-09-29
Project:        SQL Data Warehouse
Layer:          Silver

Description:
    This script creates the Silver layer tables used to store cleaned,
    standardized, and transformed data from the Bronze layer.

    The Silver layer represents the intermediate stage of the data warehouse
    pipeline where raw source data is:
        - Cleaned
        - Standardized
        - Validated
        - Deduplicated where required
        - Prepared for business-level transformations

Source Layers:
    - Bronze CRM tables
    - Bronze ERP tables

Target Schema:
    - silver

Tables Created:
    CRM:
        1. silver.crm_cust_info
        2. silver.crm_prd_info
        3. silver.crm_sales_details

    ERP:
        4. silver.erp_loc_a101
        5. silver.erp_cust_az12
        6. silver.erp_px_cat_g1v2

Process:
    1. Check whether Silver tables already exist.
    2. Drop existing tables to allow a clean recreation.
    3. Create the Silver tables with standardized data types.
    4. Add DWH metadata columns for tracking record creation.
    5. Prepare the Silver layer for the transformation/loading process.

Notes:
    - This script only creates the Silver layer table structures.
    - Data transformation and loading are handled by the Silver load procedure.
    - The dwh_create_date column is automatically populated using GETDATE().
===============================================================================
*/


-- ============================================================================
-- CRM TABLES
-- ============================================================================

PRINT '===============================================================================';
PRINT '>> CREATING CRM SILVER TABLES';
PRINT '===============================================================================';
PRINT '';


-- ----------------------------------------------------------------------------
-- CRM Customer Information
-- ----------------------------------------------------------------------------

PRINT '>> Creating table: silver.crm_cust_info';

IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info
(
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_material_status NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE,
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);
GO

PRINT '>> Table created successfully: silver.crm_cust_info';
PRINT '';


-- ----------------------------------------------------------------------------
-- CRM Product Information
-- ----------------------------------------------------------------------------

PRINT '>> Creating table: silver.crm_prd_info';

IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info
(
    prd_id           INT,
    prd_key          NVARCHAR(50),
    prd_nm           NVARCHAR(50),
    prd_cost         INT,
    prd_line         NVARCHAR(50),
    prd_start_dt     DATETIME,
    prd_end_dt       DATETIME,
    dwh_create_date  DATETIME2 DEFAULT GETDATE()
);
GO

PRINT '>> Table created successfully: silver.crm_prd_info';
PRINT '';


-- ----------------------------------------------------------------------------
-- CRM Sales Details
-- ----------------------------------------------------------------------------

PRINT '>> Creating table: silver.crm_sales_details';

IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details
(
    sls_ord_num      NVARCHAR(50),
    sls_prd_key      NVARCHAR(50),
    sls_cust_id      INT,
    sls_order_dt     INT,
    sls_ship_dt      INT,
    sls_due_dt       INT,
    sls_sales        INT,
    sls_quantity     INT,
    sls_price        INT,
    dwh_create_date  DATETIME2 DEFAULT GETDATE()
);
GO

PRINT '>> Table created successfully: silver.crm_sales_details';
PRINT '';


-- ============================================================================
-- ERP TABLES
-- ============================================================================

PRINT '===============================================================================';
PRINT '>> CREATING ERP SILVER TABLES';
PRINT '===============================================================================';
PRINT '';


-- ----------------------------------------------------------------------------
-- ERP Location
-- ----------------------------------------------------------------------------

PRINT '>> Creating table: silver.erp_loc_a101';

IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101
(
    cid             NVARCHAR(50),
    cntry           NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

PRINT '>> Table created successfully: silver.erp_loc_a101';
PRINT '';


-- ----------------------------------------------------------------------------
-- ERP Customer
-- ----------------------------------------------------------------------------

PRINT '>> Creating table: silver.erp_cust_az12';

IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12
(
    cid             NVARCHAR(50),
    bdate           DATE,
    gen             NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

PRINT '>> Table created successfully: silver.erp_cust_az12';
PRINT '';


-- ----------------------------------------------------------------------------
-- ERP Product Category
-- ----------------------------------------------------------------------------

PRINT '>> Creating table: silver.erp_px_cat_g1v2';

IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2
(
    id              NVARCHAR(50),
    cat             NVARCHAR(50),
    subcat          NVARCHAR(50),
    maintenance     NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

PRINT '>> Table created successfully: silver.erp_px_cat_g1v2';
PRINT '';


-- ============================================================================
-- COMPLETION MESSAGE
-- ============================================================================

PRINT '===============================================================================';
PRINT '>> SILVER LAYER TABLE CREATION COMPLETED SUCCESSFULLY';
PRINT '===============================================================================';
PRINT '';
PRINT 'CRM Tables:';
PRINT '    - silver.crm_cust_info';
PRINT '    - silver.crm_prd_info';
PRINT '    - silver.crm_sales_details';
PRINT '';
PRINT 'ERP Tables:';
PRINT '    - silver.erp_loc_a101';
PRINT '    - silver.erp_cust_az12';
PRINT '    - silver.erp_px_cat_g1v2';
PRINT '';
PRINT '>> Silver layer is ready for data transformation and loading.';
PRINT '===============================================================================';
GO    
