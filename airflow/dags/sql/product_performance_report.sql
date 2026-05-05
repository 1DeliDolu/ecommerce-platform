CREATE SCHEMA IF NOT EXISTS reports;

CREATE OR REPLACE VIEW reports.product_performance_report AS
SELECT
    p.product_id,
    p.name,
    p.status,
    i.stock_quantity,
    i.snapshot_date
FROM dw.dim_product p
LEFT JOIN dw.fact_inventory i ON i.product_key = p.product_key
ORDER BY p.name;
