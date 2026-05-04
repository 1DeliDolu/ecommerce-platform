CREATE TABLE IF NOT EXISTS app_user (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(64) NOT NULL,
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS product (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price NUMERIC(12,2) NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO app_user (email, password_hash, role, enabled)
VALUES
('admin@example.com', '$2b$10$bqvU35kSc9sfljZQ5xke9e8tjID3gph4SIIfyPE/oxWhtTLcTn9zy', 'ADMIN', TRUE)
ON CONFLICT (email) DO NOTHING;

INSERT INTO product (name, description, price, stock)
VALUES
('Mechanical Keyboard', 'Hot-swappable TypeScript developer keyboard', 129.90, 25),
('Secure Laptop Stand', 'Ergonomic aluminium laptop stand', 49.90, 100),
('USB-C Dock', 'Multi-port productivity dock', 89.90, 40)
ON CONFLICT DO NOTHING;
