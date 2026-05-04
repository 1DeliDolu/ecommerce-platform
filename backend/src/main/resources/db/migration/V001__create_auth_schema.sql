-- Auth schema: users table
CREATE TABLE IF NOT EXISTS app_user (
    id            BIGSERIAL PRIMARY KEY,
    email         VARCHAR(255)  NOT NULL UNIQUE,
    password_hash VARCHAR(255)  NOT NULL,
    role          VARCHAR(50)   NOT NULL DEFAULT 'CUSTOMER',
    enabled       BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Seed default admin user
-- Password: admin123  (BCrypt hash for admin123 - for reference only, actual seeding done by DataInitializer.java)
-- $2a$12$k8Y1THPD8MUJYkyFmdzAFOhR6e4TqyBT8jEzFG1ROm.ElEJ4RJBXO
