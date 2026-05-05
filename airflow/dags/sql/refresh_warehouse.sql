TRUNCATE staging.orders;
TRUNCATE staging.order_items;
TRUNCATE staging.products;
TRUNCATE staging.audit_logs;

INSERT INTO staging.orders (
    id, order_number, user_email, status, subtotal, shipping_cost, tax,
    total_amount, payment_method, payment_reference, created_at
)
SELECT
    id, order_number, user_email, status, subtotal, shipping_cost, tax,
    total_amount, payment_method, payment_reference, created_at
FROM customer_orders;

INSERT INTO staging.order_items (
    id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total
)
SELECT id, order_id, product_id, product_name, product_slug, unit_price, quantity, line_total
FROM customer_order_items;

INSERT INTO staging.products (
    id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at
)
SELECT id, category_id, name, slug, price, stock_quantity, status, updated_at, created_at
FROM products;

INSERT INTO staging.audit_logs (
    id, actor_email, action, resource_type, resource_id, details, created_at
)
SELECT id, actor_email, action, resource_type, resource_id, details, created_at
FROM audit_logs;

INSERT INTO dw.dim_customer (email)
SELECT DISTINCT user_email
FROM staging.orders
WHERE user_email IS NOT NULL
ON CONFLICT (email) DO NOTHING;

INSERT INTO dw.dim_product (product_id, name, slug, category_id, current_price, status)
SELECT id, name, slug, category_id, price, status
FROM staging.products
ON CONFLICT (product_id) DO UPDATE SET
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    category_id = EXCLUDED.category_id,
    current_price = EXCLUDED.current_price,
    status = EXCLUDED.status;

INSERT INTO dw.dim_date (date_key, year, month, day)
SELECT DISTINCT
    created_at::date,
    EXTRACT(YEAR FROM created_at)::int,
    EXTRACT(MONTH FROM created_at)::int,
    EXTRACT(DAY FROM created_at)::int
FROM staging.orders
WHERE created_at IS NOT NULL
ON CONFLICT (date_key) DO NOTHING;

INSERT INTO dw.fact_orders (
    order_id, order_number, customer_key, date_key, status, subtotal, shipping_cost, tax, total_amount, item_count
)
SELECT
    o.id,
    o.order_number,
    c.customer_key,
    o.created_at::date,
    o.status,
    o.subtotal,
    o.shipping_cost,
    o.tax,
    o.total_amount,
    COALESCE(SUM(oi.quantity), 0)::int
FROM staging.orders o
LEFT JOIN staging.order_items oi ON oi.order_id = o.id
LEFT JOIN dw.dim_customer c ON c.email = o.user_email
GROUP BY o.id, o.order_number, c.customer_key, o.created_at, o.status, o.subtotal, o.shipping_cost, o.tax, o.total_amount
ON CONFLICT (order_id) DO UPDATE SET
    status = EXCLUDED.status,
    subtotal = EXCLUDED.subtotal,
    shipping_cost = EXCLUDED.shipping_cost,
    tax = EXCLUDED.tax,
    total_amount = EXCLUDED.total_amount,
    item_count = EXCLUDED.item_count;

INSERT INTO dw.fact_payments (
    payment_reference, order_id, date_key, payment_method, status, amount
)
SELECT
    payment_reference,
    id,
    created_at::date,
    payment_method,
    status,
    total_amount
FROM staging.orders
WHERE payment_reference IS NOT NULL
ON CONFLICT (payment_reference) DO UPDATE SET
    status = EXCLUDED.status,
    amount = EXCLUDED.amount;

INSERT INTO dw.fact_inventory (
    product_id, product_key, stock_quantity, snapshot_date
)
SELECT
    p.id,
    dp.product_key,
    p.stock_quantity,
    CURRENT_DATE
FROM staging.products p
JOIN dw.dim_product dp ON dp.product_id = p.id
ON CONFLICT (product_id) DO UPDATE SET
    product_key = EXCLUDED.product_key,
    stock_quantity = EXCLUDED.stock_quantity,
    snapshot_date = EXCLUDED.snapshot_date;
