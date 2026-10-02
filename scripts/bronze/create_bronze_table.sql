/*
===============================================================================
Script:         02_create_bronze_tables.sql
Layer:          Bronze
Description:    Creates raw staging tables for CRM and ERP source data.

Architecture:
    Source Systems
         |
         v
      BRONZE
    Raw Data
         |
         v
      SILVER
    Cleaned Data
         |
         v
       GOLD
   Business Data

Notes:
    - Bronze tables store raw data from source CSV files.
    - No business transformations are applied at this stage.
    - Tables are recreated to ensure a clean loading environment.

Author:         Ismail Laouad
Created:        2026-09-23
===============================================================================
*/

USE DataWarehouse;
GO


-- ============================================================================
-- CRM TABLES
-- ============================================================================

PRINT 'Creating CRM Bronze Tables...';
GO


-- ----------------------------------------------------------------------------
-- CRM Customer Information
-- ----------------------------------------------------------------------------

IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info
(
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_material_status NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE
);
GO


-- ----------------------------------------------------------------------------
-- CRM Product Information
-- ----------------------------------------------------------------------------

IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info
(
    prd_id       INT,
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME
);
GO


-- ----------------------------------------------------------------------------
-- CRM Sales Details
-- ----------------------------------------------------------------------------

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details
(
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);
GO


-- ============================================================================
-- ERP TABLES
-- ============================================================================

PRINT 'Creating ERP Bronze Tables...';
GO


-- ----------------------------------------------------------------------------
-- ERP Location
-- ----------------------------------------------------------------------------

IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101
(
    cid   NVARCHAR(50),
    cntry NVARCHAR(50)
);
GO


-- ----------------------------------------------------------------------------
-- ERP Customer
-- ----------------------------------------------------------------------------

IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12
(
    cid  NVARCHAR(50),
    bdate DATE,
    gen   NVARCHAR(50)
);
GO


-- ----------------------------------------------------------------------------
-- ERP Product Category
-- ----------------------------------------------------------------------------

IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2
(
    id          NVARCHAR(50),
    cat         NVARCHAR(50),
    subcat      NVARCHAR(50),
    maintenance NVARCHAR(50)
);
GO


-- ============================================================================
-- COMPLETION MESSAGE
-- ============================================================================

PRINT '=======================================================';
PRINT 'Bronze Layer tables created successfully.';
PRINT '=======================================================';
GO
