CREATE SCHEMA IF NOT EXISTS reports;

CREATE OR REPLACE VIEW reports.failed_payment_report AS
SELECT
    payment_reference,
    order_id,
    date_key,
    payment_method,
    amount
FROM dw.fact_payments
WHERE status = 'PAYMENT_FAILED'
ORDER BY date_key DESC;
