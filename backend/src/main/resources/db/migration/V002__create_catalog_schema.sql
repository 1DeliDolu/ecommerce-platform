-- Catalog schema: categories table
CREATE TABLE IF NOT EXISTS category (
    id            BIGSERIAL    PRIMARY KEY,
    name          VARCHAR(120) NOT NULL UNIQUE,
    slug          VARCHAR(140) NOT NULL UNIQUE,
    description   VARCHAR(1000),
    product_count INT          NOT NULL DEFAULT 0,
    status        VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
    created_at    DATE         NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT chk_category_status CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

-- Products table
CREATE TABLE IF NOT EXISTS products (
    id             BIGSERIAL        PRIMARY KEY,
    category_id    BIGINT           NOT NULL REFERENCES category(id),
    name           VARCHAR(160)     NOT NULL,
    slug           VARCHAR(180)     NOT NULL,
    description    VARCHAR(2000),
    price          NUMERIC(12, 2)   NOT NULL,
    stock_quantity INT              NOT NULL DEFAULT 0,
    status         VARCHAR(20)      NOT NULL DEFAULT 'ACTIVE',
    created_at     TIMESTAMP        NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMP,
    CONSTRAINT uk_product_category_slug UNIQUE (category_id, slug),
    CONSTRAINT chk_product_status CHECK (status IN ('ACTIVE', 'INACTIVE')),
    CONSTRAINT chk_product_price  CHECK (price >= 0),
    CONSTRAINT chk_product_stock  CHECK (stock_quantity >= 0)
);

-- Product images table
CREATE TABLE IF NOT EXISTS product_images (
    id                 BIGSERIAL    PRIMARY KEY,
    product_id         BIGINT       NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    original_file_name VARCHAR(255) NOT NULL,
    stored_file_name   VARCHAR(255) NOT NULL,
    relative_path      VARCHAR(600) NOT NULL,
    content_type       VARCHAR(100) NOT NULL,
    file_size          BIGINT       NOT NULL,
    image_order        INT          NOT NULL DEFAULT 0,
    primary_image      BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at         TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_product_images_product_id ON product_images(product_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id      ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_status           ON products(status);
