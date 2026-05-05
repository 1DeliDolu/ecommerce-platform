CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS dw;

CREATE TABLE IF NOT EXISTS staging.orders (
    id BIGINT PRIMARY KEY,
    order_number VARCHAR(255),
    user_email VARCHAR(255),
    status VARCHAR(40),
    subtotal NUMERIC(12, 2),
    shipping_cost NUMERIC(12, 2),
    tax NUMERIC(12, 2),
    total_amount NUMERIC(12, 2),
    payment_method VARCHAR(255),
    payment_reference VARCHAR(255),
    created_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.order_items (
    id BIGINT PRIMARY KEY,
    order_id BIGINT,
    product_id BIGINT,
    product_name VARCHAR(255),
    product_slug VARCHAR(255),
    unit_price NUMERIC(12, 2),
    quantity INT,
    line_total NUMERIC(12, 2)
);

CREATE TABLE IF NOT EXISTS staging.products (
    id BIGINT PRIMARY KEY,
    category_id BIGINT,
    name VARCHAR(160),
    slug VARCHAR(180),
    price NUMERIC(12, 2),
    stock_quantity INT,
    status VARCHAR(20),
    updated_at TIMESTAMP,
    created_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.audit_logs (
    id BIGINT PRIMARY KEY,
    actor_email VARCHAR(255),
    action VARCHAR(120),
    resource_type VARCHAR(120),
    resource_id VARCHAR(120),
    details TEXT,
    created_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS dw.dim_customer (
    customer_key BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dw.dim_product (
    product_key BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL UNIQUE,
    name VARCHAR(160),
    slug VARCHAR(180),
    category_id BIGINT,
    current_price NUMERIC(12, 2),
    status VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS dw.dim_date (
    date_key DATE PRIMARY KEY,
    year INT NOT NULL,
    month INT NOT NULL,
    day INT NOT NULL
);

CREATE TABLE IF NOT EXISTS dw.fact_orders (
    order_id BIGINT PRIMARY KEY,
    order_number VARCHAR(255),
    customer_key BIGINT REFERENCES dw.dim_customer(customer_key),
    date_key DATE REFERENCES dw.dim_date(date_key),
    status VARCHAR(40),
    subtotal NUMERIC(12, 2),
    shipping_cost NUMERIC(12, 2),
    tax NUMERIC(12, 2),
    total_amount NUMERIC(12, 2),
    item_count INT
);

CREATE TABLE IF NOT EXISTS dw.fact_payments (
    payment_reference VARCHAR(255) PRIMARY KEY,
    order_id BIGINT REFERENCES dw.fact_orders(order_id),
    date_key DATE REFERENCES dw.dim_date(date_key),
    payment_method VARCHAR(255),
    status VARCHAR(40),
    amount NUMERIC(12, 2)
);

CREATE TABLE IF NOT EXISTS dw.fact_inventory (
    product_id BIGINT PRIMARY KEY,
    product_key BIGINT REFERENCES dw.dim_product(product_key),
    stock_quantity INT,
    snapshot_date DATE
);
