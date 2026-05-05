ALTER TABLE app_user
    ALTER COLUMN role TYPE VARCHAR(255);

CREATE TABLE IF NOT EXISTS roles (
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(500),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS permissions (
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(120) NOT NULL UNIQUE,
    description VARCHAR(500),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_roles (
    user_id BIGINT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    role_id BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE IF NOT EXISTS role_permissions (
    role_id       BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id BIGINT NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE IF NOT EXISTS refresh_tokens (
    id         BIGSERIAL PRIMARY KEY,
    user_id    BIGINT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_user_email ON app_user(email);
CREATE INDEX IF NOT EXISTS idx_app_user_role ON app_user(role);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);

INSERT INTO roles (name, description)
VALUES
    ('ADMIN', 'Full platform administrator'),
    ('EMPLOYEE', 'Back office catalog operator'),
    ('CUSTOMER', 'Storefront customer')
ON CONFLICT (name) DO NOTHING;

INSERT INTO permissions (name, description)
VALUES
    ('ADMIN_PANEL_ACCESS', 'Access admin panel'),
    ('PRODUCT_READ', 'Read products'),
    ('PRODUCT_CREATE', 'Create products'),
    ('PRODUCT_UPDATE', 'Update products'),
    ('PRODUCT_DELETE', 'Delete products'),
    ('PRODUCT_IMAGE_UPLOAD', 'Upload product images'),
    ('PRODUCT_IMAGE_DELETE', 'Delete product images'),
    ('PRODUCT_IMAGE_SET_PRIMARY', 'Set primary product image'),
    ('CATEGORY_READ', 'Read categories'),
    ('CATEGORY_CREATE', 'Create categories'),
    ('CATEGORY_UPDATE', 'Update categories'),
    ('CATEGORY_DELETE', 'Delete categories'),
    ('ORDER_READ_OWN', 'Read own orders'),
    ('ORDER_READ_ALL', 'Read all orders'),
    ('USER_MANAGE', 'Manage users'),
    ('ROLE_MANAGE', 'Manage roles')
ON CONFLICT (name) DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.name IN (
    'ADMIN_PANEL_ACCESS', 'PRODUCT_READ', 'PRODUCT_CREATE', 'PRODUCT_UPDATE', 'PRODUCT_DELETE',
    'PRODUCT_IMAGE_UPLOAD', 'PRODUCT_IMAGE_DELETE', 'PRODUCT_IMAGE_SET_PRIMARY',
    'CATEGORY_READ', 'CATEGORY_CREATE', 'CATEGORY_UPDATE', 'CATEGORY_DELETE',
    'ORDER_READ_OWN', 'ORDER_READ_ALL', 'USER_MANAGE', 'ROLE_MANAGE'
)
WHERE r.name = 'ADMIN'
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.name IN (
    'ADMIN_PANEL_ACCESS', 'PRODUCT_READ', 'PRODUCT_CREATE', 'PRODUCT_UPDATE',
    'PRODUCT_IMAGE_UPLOAD', 'PRODUCT_IMAGE_SET_PRIMARY', 'CATEGORY_READ', 'ORDER_READ_OWN'
)
WHERE r.name = 'EMPLOYEE'
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.name IN ('PRODUCT_READ', 'ORDER_READ_OWN')
WHERE r.name = 'CUSTOMER'
ON CONFLICT DO NOTHING;
