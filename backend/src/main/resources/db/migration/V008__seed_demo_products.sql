INSERT INTO products (category_id, name, slug, description, price, stock_quantity, status)
SELECT c.id, v.name, v.slug, v.description, v.price, v.stock_quantity, 'ACTIVE'
FROM (
    VALUES
        ('electronics', 'Developer Laptop Pro 14', 'developer-laptop-pro-14', 'Portable workstation for Java and frontend development.', 64999.90, 12),
        ('electronics', 'USB-C Productivity Dock', 'usb-c-productivity-dock', 'Multi-port dock with Ethernet, HDMI and power delivery.', 3499.90, 35),
        ('clothing', 'Everyday Tech Hoodie', 'everyday-tech-hoodie', 'Durable cotton hoodie with a clean workwear fit.', 1499.90, 48),
        ('home-garden', 'Ergonomic Desk Lamp', 'ergonomic-desk-lamp', 'Adjustable LED desk lamp for focused workspaces.', 899.90, 64),
        ('sports', 'Smart Training Bottle', 'smart-training-bottle', 'Insulated bottle for gym and outdoor training.', 699.90, 80)
) AS v(category_slug, name, slug, description, price, stock_quantity)
JOIN category c ON c.slug = v.category_slug
ON CONFLICT (category_id, slug) DO NOTHING;
