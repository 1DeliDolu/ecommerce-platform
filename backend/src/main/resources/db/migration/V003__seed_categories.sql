-- Seed demo categories
INSERT INTO category (name, slug, description, product_count, status, created_at)
VALUES
    ('Electronics',  'electronics',  'Phones, laptops, and gadgets',      0, 'ACTIVE', CURRENT_DATE),
    ('Clothing',     'clothing',     'Men, women and kids apparel',        0, 'ACTIVE', CURRENT_DATE),
    ('Home & Garden','home-garden',  'Furniture, decor, and garden items', 0, 'ACTIVE', CURRENT_DATE),
    ('Sports',       'sports',       'Equipment and activewear',           0, 'ACTIVE', CURRENT_DATE)
ON CONFLICT (slug) DO NOTHING;
