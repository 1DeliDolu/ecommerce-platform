CREATE TABLE IF NOT EXISTS cart_items (
    id          BIGSERIAL PRIMARY KEY,
    user_email  VARCHAR(255) NOT NULL,
    product_id  BIGINT       NOT NULL REFERENCES products(id),
    quantity    INT          NOT NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP,
    CONSTRAINT uk_cart_user_product UNIQUE (user_email, product_id),
    CONSTRAINT chk_cart_items_quantity CHECK (quantity > 0)
);

CREATE TABLE IF NOT EXISTS customer_orders (
    id                   BIGSERIAL PRIMARY KEY,
    order_number         VARCHAR(255)   NOT NULL UNIQUE,
    user_email           VARCHAR(255)   NOT NULL,
    status               VARCHAR(20)    NOT NULL,
    subtotal             NUMERIC(12, 2) NOT NULL,
    shipping_cost        NUMERIC(12, 2) NOT NULL,
    tax                  NUMERIC(12, 2) NOT NULL,
    total_amount         NUMERIC(12, 2) NOT NULL,
    shipping_full_name   VARCHAR(255)   NOT NULL,
    shipping_email       VARCHAR(255)   NOT NULL,
    shipping_phone       VARCHAR(255)   NOT NULL,
    shipping_street      VARCHAR(255)   NOT NULL,
    shipping_city        VARCHAR(255)   NOT NULL,
    shipping_postal_code VARCHAR(255)   NOT NULL,
    shipping_country     VARCHAR(255)   NOT NULL,
    payment_method       VARCHAR(255)   NOT NULL,
    payment_reference    VARCHAR(255)   NOT NULL,
    created_at           TIMESTAMP      NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_customer_orders_status CHECK (status IN ('CREATED', 'PAID', 'PAYMENT_FAILED', 'CANCELLED', 'SHIPPED', 'DELIVERED')),
    CONSTRAINT chk_customer_orders_amounts CHECK (subtotal >= 0 AND shipping_cost >= 0 AND tax >= 0 AND total_amount >= 0)
);

CREATE TABLE IF NOT EXISTS customer_order_items (
    id           BIGSERIAL PRIMARY KEY,
    order_id     BIGINT         NOT NULL REFERENCES customer_orders(id) ON DELETE CASCADE,
    product_id   BIGINT         NOT NULL REFERENCES products(id),
    product_name VARCHAR(255)   NOT NULL,
    product_slug VARCHAR(255)   NOT NULL,
    unit_price   NUMERIC(12, 2) NOT NULL,
    quantity     INT            NOT NULL,
    line_total   NUMERIC(12, 2) NOT NULL,
    CONSTRAINT chk_customer_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_customer_order_items_amounts CHECK (unit_price >= 0 AND line_total >= 0)
);

CREATE TABLE IF NOT EXISTS payments (
    id                BIGSERIAL PRIMARY KEY,
    order_id          BIGINT         NOT NULL REFERENCES customer_orders(id) ON DELETE CASCADE,
    payment_reference VARCHAR(255)   NOT NULL UNIQUE,
    method            VARCHAR(50)    NOT NULL,
    status            VARCHAR(50)    NOT NULL,
    amount            NUMERIC(12, 2) NOT NULL,
    created_at        TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_payments_amount CHECK (amount >= 0)
);

CREATE INDEX IF NOT EXISTS idx_cart_items_user_email ON cart_items(user_email);
CREATE INDEX IF NOT EXISTS idx_cart_items_product_id ON cart_items(product_id);
CREATE INDEX IF NOT EXISTS idx_customer_orders_user_email ON customer_orders(user_email);
CREATE INDEX IF NOT EXISTS idx_customer_orders_status ON customer_orders(status);
CREATE INDEX IF NOT EXISTS idx_customer_orders_created_at ON customer_orders(created_at);
CREATE INDEX IF NOT EXISTS idx_customer_order_items_order_id ON customer_order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_customer_order_items_product_id ON customer_order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_payments_order_id ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
