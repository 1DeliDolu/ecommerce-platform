CREATE SCHEMA IF NOT EXISTS reports;

CREATE OR REPLACE VIEW reports.customer_order_summary AS
SELECT
    c.email,
    COUNT(o.order_id) AS order_count,
    SUM(o.total_amount) AS total_spend,
    MAX(o.date_key) AS last_order_date
FROM dw.dim_customer c
LEFT JOIN dw.fact_orders o ON o.customer_key = c.customer_key
GROUP BY c.email
ORDER BY total_spend DESC NULLS LAST;
