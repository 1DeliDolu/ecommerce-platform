CREATE SCHEMA IF NOT EXISTS reports;

CREATE OR REPLACE VIEW reports.daily_sales_report AS
SELECT
    date_key,
    COUNT(*) AS order_count,
    SUM(item_count) AS item_count,
    SUM(total_amount) AS gross_sales
FROM dw.fact_orders
GROUP BY date_key
ORDER BY date_key DESC;
