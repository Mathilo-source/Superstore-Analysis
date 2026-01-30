-- order metrics
CREATE VIEW vw_order_metrics AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,

    COUNT(s.product_id) AS items_count,
    SUM(s.sales) AS order_sales,
    SUM(s.profit) AS order_profit,
    ROUND(SUM(s.profit) / NULLIF(SUM(s.sales), 0), 2) AS order_profit_margin,

    DATEDIFF(o.ship_date, o.order_date) AS shipping_days

FROM vw_orders_enriched o
JOIN vw_sales_cleaned s
    ON o.order_id = s.order_id

WHERE o.order_status = 'VALID'

GROUP BY o.order_id, o.customer_id, o.order_date;

-- customer metrtics
CREATE VIEW vw_customer_metrics AS
SELECT
    c.customer_id,
    c.customer_name,
    c.segment,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.order_sales) AS lifetime_sales,
    SUM(o.order_profit) AS lifetime_profit,
    ROUND(AVG(o.order_sales), 2) AS avg_order_value

FROM vw_order_metrics o
JOIN vw_customers_clean c
    ON o.customer_id = c.customer_id

GROUP BY c.customer_id, c.customer_name, c.segment;

-- monthly performance(trend analysis)
CREATE VIEW vw_monthly_performance AS
SELECT
    order_year,
    order_month,
    SUM(order_sales) AS monthly_sales,
    SUM(order_profit) AS monthly_profit,
    ROUND(SUM(order_profit) / NULLIF(SUM(order_sales), 0), 2) AS profit_margin
FROM vw_order_metrics
GROUP BY order_year, order_month;

-- Using these metrcs we can now analyze
-- Seasonality
-- Growth/decline
-- Profit vs revenue trends