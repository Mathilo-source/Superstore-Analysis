-- DATA CLEANING
-- checking for missing critical information

-- checking for missing  names
SELECT SUM(customer_name IS NULL) FROM customers;

-- it is impossible to have less than 0 sales
SELECT * FROM sales WHERE sales <= 0;

--  it is impossible to ship a product that has not been orderd
SELECT * FROM orders WHERE ship_date < order_date;

-- high discounts
SELECT * FROM sales WHERE discount >= 0.7;

-- creating a view on cleaned sales data
CREATE VIEW vw_sales_cleaned AS
SELECT
    s.order_id,
    s.product_id,
    s.sales,
    s.quantity,
    s.discount,
    s.profit,

    -- Derived metrics
    ROUND(s.profit / NULLIF(s.sales, 0), 2) AS profit_margin,

    -- Business flags
    CASE
        WHEN s.sales <= 0 THEN 'INVALID_SALES'
        WHEN s.quantity <= 0 THEN 'INVALID_QUANTITY'
        WHEN s.discount >= 0.7 THEN 'HIGH_DISCOUNT'
        WHEN s.profit < 0 THEN 'LOSS'
        ELSE 'NORMAL'
    END AS sale_status

FROM sales s;

-- created a view on the orrders table
CREATE VIEW vw_orders_enriched AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.ship_date,
    o.ship_mode,

    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,
    DATEDIFF(o.ship_date, o.order_date) AS shipping_days,

    CASE
        WHEN o.ship_date < o.order_date THEN 'DATE_ERROR'
        ELSE 'VALID'
    END AS order_status

FROM orders o;

-- Detecting duplicates
SELECT order_id, product_id, COUNT(*)
FROM sales
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

CREATE VIEW vw_sales_deduped AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY order_id, product_id
               ORDER BY sales DESC
           ) AS rn
    FROM sales
) t
WHERE rn = 1;


-- checking for null values
SELECT * FROM orders WHERE order_date IS NULL;
SELECT * FROM sales WHERE profit IS NULL;

CREATE VIEW vw_customers_clean AS
SELECT
    customer_id,
    COALESCE(customer_name, 'UNKNOWN') AS customer_name,
    COALESCE(city, 'UNKNOWN') AS city,
    COALESCE(segment, 'UNKNOWN') AS segment
FROM customers;

-- consistent case and getting rid of extra spaces
SET SQL_SAFE_UPDATES = 0;
UPDATE customers
SET customer_name = UPPER(TRIM(customer_name));

UPDATE customers
SET segment = UPPER(TRIM(segment));

UPDATE customers
SET region = UPPER(TRIM(region));

UPDATE orders
SET ship_mode = UPPER(TRIM(ship_mode));

UPDATE customers
SET country = UPPER(TRIM(country));

UPDATE customers
SET city = UPPER(TRIM(city));

UPDATE customers
SET state = UPPER(TRIM(state));
