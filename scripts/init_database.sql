/*
===============================================================================
Database:       DataWarehouse
Description:    Data Warehouse database using the Medallion Architecture
                (Bronze -> Silver -> Gold)

Author:         Ismail Laouad
Created:        2026-09-22

Architecture:
    Bronze  -> Raw data ingestion / staging
    Silver  -> Cleaned and transformed data
    Gold    -> Business-ready data for analytics and reporting
===============================================================================
*/

-- ============================================================================
-- 1. Create Database
-- ============================================================================

USE master;
GO

IF DB_ID('DataWarehouse') IS NULL
BEGIN
    CREATE DATABASE DataWarehouse;
END;
GO

USE DataWarehouse;
GO


-- ============================================================================
-- 2. Create Schemas
-- ============================================================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'bronze'
)
BEGIN
    EXEC('CREATE SCHEMA bronze');
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'silver'
)
BEGIN
    EXEC('CREATE SCHEMA silver');
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'gold'
)
BEGIN
    EXEC('CREATE SCHEMA gold');
END;
GO


-- ============================================================================
-- 3. Verify Database Architecture
-- ============================================================================

SELECT
    name AS SchemaName
FROM sys.schemas
WHERE name IN ('bronze', 'silver', 'gold')
ORDER BY name;
GO
