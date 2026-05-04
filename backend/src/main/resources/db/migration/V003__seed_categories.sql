-- Seed demo categories
INSERT INTO category (name, slug, description, status)
VALUES
    ('Electronics',  'electronics',  'Phones, laptops, and gadgets',      'ACTIVE'),
    ('Clothing',     'clothing',     'Men, women and kids apparel',        'ACTIVE'),
    ('Home & Garden','home-garden',  'Furniture, decor, and garden items', 'ACTIVE'),
    ('Sports',       'sports',       'Equipment and activewear',           'ACTIVE')
ON CONFLICT (slug) DO NOTHING;
