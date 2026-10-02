/*
===============================================================================
    GOLD LAYER - DIMENSIONS AND FACT VIEW
===============================================================================
    Project     : DATAWarehouse
    Author      : Ismail Laouad
    Created     : 2026-10-02
    Description : Creates analytical views in the Gold Layer following a
                  star schema structure for reporting and analysis.

    Views:
        1. gold.dim_customers
        2. gold.dim_products
        3. gold.fact_sales

    Data Flow:
        Silver Layer -> Gold Layer
===============================================================================
*/


/*
===============================================================================
    VIEW: gold.dim_customers
===============================================================================
    Purpose:
        Combines customer information from CRM and ERP sources.

    Sources:
        - silver.crm_cust_info
        - silver.erp_cust_az12
        - silver.erp_loc_a101

    Transformations:
        - Generates a customer surrogate key using ROW_NUMBER().
        - Retrieves customer demographic and geographical information.
        - Uses CRM as the master source for gender information.
===============================================================================
*/

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER(ORDER BY ci.cst_key) AS customer_key,
    ci.cst_id                              AS customer_id,
    ci.cst_key                             AS customer_number,
    ci.cst_firstname                       AS first_name,
    ci.cst_lastname                        AS last_name,
    ci.cst_material_status                 AS marital_status,

    -- CRM is the master source for gender information.
    CASE
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END                                    AS gender,

    la.cntry                               AS country,
    ca.bdate                               AS birthdate,
    ci.cst_create_date                     AS create_date

FROM silver.crm_cust_info ci

LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;
GO


/*
===============================================================================
    VIEW: gold.dim_products
===============================================================================
    Purpose:
        Combines product information from CRM with product category details
        from the ERP system.

    Sources:
        - silver.crm_prd_info
        - silver.erp_px_cat_g1v2

    Transformations:
        - Generates a product surrogate key using ROW_NUMBER().
        - Enriches product records with category and subcategory information.
        - Retrieves product cost, product line, and start date.
        - Filters products using the existing product end-date condition.
===============================================================================
*/

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER(ORDER BY pr.prd_start_dt, pr.prd_key) AS product_key,
    pr.prd_id          AS product_id,
    pr.prd_key         AS product_number,
    pr.prd_nm          AS product_name,
    pr.cat_id          AS category_id,
    pr_ct.cat          AS category,
    pr_ct.subcat       AS subcategory,
    pr_ct.maintenance  AS maintenance,
    pr.prd_codt        AS product_cost,
    pr.prd_line        AS product_line,
    pr.prd_start_dt    AS start_date

FROM silver.crm_prd_info pr

LEFT JOIN silver.erp_px_cat_g1v2 pr_ct
    ON pr.cat_id = pr_ct.id

WHERE prd_end_dt IS NULL;
GO


/*
===============================================================================
    VIEW: gold.fact_sales
===============================================================================
    Purpose:
        Combines sales transactions with customer and product dimension keys
        to support analytical queries and reporting.

    Source:
        - silver.crm_sales_details

    Dimension Lookups:
        - gold.dim_products
        - gold.dim_customers

    Measures:
        - sales_amount
        - order_quantity
        - unit_price

    Date Attributes:
        - order_date
        - shipping_date
        - due_date
===============================================================================
*/

CREATE VIEW gold.fact_sales AS
SELECT
    sales.sls_ord_num    AS order_number,
    prod.product_key     AS product_key,
    cust.customer_key    AS customer_key,
    sales.sls_order_dt   AS order_date,
    sales.sls_ship_dt    AS shipping_date,
    sales.sls_due_dt     AS due_date,
    sales.sls_sales      AS sales_amount,
    sales.sls_quantity   AS order_quantity,
    sales.sls_price      AS unit_price

FROM silver.crm_sales_details sales

LEFT JOIN gold.dim_products prod
    ON sales.sls_prd_key = prod.product_number

LEFT JOIN gold.dim_customers cust
    ON sales.sls_cust_id = cust.customer_id;
GO


/*
===============================================================================
    END OF GOLD LAYER
===============================================================================
    The Gold Layer provides business-ready views for analytical queries,
    reporting, and visualization tools such as Power BI.
===============================================================================
*/
