-- Demo seed per taglie/varianti e ordini di esempio
-- Assicurati di aver applicato prima schema e migrazioni con product_variants e colonna size su cart/order_items
USE red_bull_spielberg;

-- Ripulisci tabelle principali (solo per ambienti demo!)
SET FOREIGN_KEY_CHECKS=0;
TRUNCATE TABLE order_items;
TRUNCATE TABLE orders;
TRUNCATE TABLE cart;
TRUNCATE TABLE product_variants;
TRUNCATE TABLE products;
TRUNCATE TABLE categories;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS=1;

-- Categorie
INSERT INTO categories (name, description, is_active) VALUES
('Driving Experiences', 'Red Bull Racing driving experiences on Spielberg circuit', 1),
('Apparel', 'Official Red Bull Racing clothing and accessories', 1),
('Models & Collectibles', 'Die-cast models and collectible items', 1);

-- Utenti (password in chiaro per demo)
INSERT INTO users (email, password, first_name, last_name, user_type, is_active) VALUES
('admin@redbull.com', 'admin123', 'Red Bull', 'Admin', 'ADMIN', 1),
('user1@example.com', 'user123', 'Mario', 'Rossi', 'REGISTERED', 1);

-- Prodotti MERCH
-- Piccolo placeholder base64 (1x1 png trasparente)
SET @img = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Y0Nfg0AAAAASUVORK5CYII=';
INSERT INTO products (category_id, name, description, short_description, price, product_type, stock_quantity, image_url, is_active, is_featured)
VALUES
(2, 'Red Bull Racing Team Cap', 'Cappellino ufficiale Red Bull Racing', 'Cap ufficiale', 39.99, 'MERCHANDISE', 200, @img, 1, 1),
(2, 'Red Bull Racing Polo', 'Polo ufficiale del team', 'Polo team', 79.99, 'MERCHANDISE', 150, @img, 1, 1),
(3, 'RB19 Modello 1:18', 'Modello die-cast RB19', 'Modello 1:18', 129.99, 'MERCHANDISE', 50, @img, 1, 0);

-- Varianti/taglie
INSERT INTO product_variants (product_id, size, sku, price_override, stock_quantity, is_active) VALUES
((SELECT product_id FROM products WHERE name='Red Bull Racing Team Cap' LIMIT 1), 'UNICA', 'CAP-RB-ONE', NULL, 120, 1),
((SELECT product_id FROM products WHERE name='Red Bull Racing Polo' LIMIT 1), 'S', 'POLO-RB-S', NULL, 20, 1),
((SELECT product_id FROM products WHERE name='Red Bull Racing Polo' LIMIT 1), 'M', 'POLO-RB-M', NULL, 40, 1),
((SELECT product_id FROM products WHERE name='Red Bull Racing Polo' LIMIT 1), 'L', 'POLO-RB-L', NULL, 40, 1),
((SELECT product_id FROM products WHERE name='Red Bull Racing Polo' LIMIT 1), 'XL', 'POLO-RB-XL', NULL, 30, 1),
((SELECT product_id FROM products WHERE name='RB19 Modello 1:18' LIMIT 1), 'UNICA', 'RB19-118', NULL, 50, 1);

-- Esperienze
INSERT INTO products (category_id, name, description, short_description, price, product_type, experience_type, image_url, is_active, is_featured)
VALUES
(1, 'Red Bull Ring Experience - Base', '3 giri con istruttore', 'Experience Base', 299.99, 'EXPERIENCE', 'BASE', @img, 1, 1),
(1, 'Red Bull Ring Experience - Premium', '5 giri con telemetry', 'Experience Premium', 499.99, 'EXPERIENCE', 'PREMIUM', @img, 1, 1);

-- Slot demo per experiences
INSERT INTO time_slots (product_id, slot_date, slot_time, max_capacity, booked_capacity, is_available) VALUES
((SELECT product_id FROM products WHERE name='Red Bull Ring Experience - Base' LIMIT 1), CURDATE() + INTERVAL 2 DAY, '09:00:00', 2, 0, 1),
((SELECT product_id FROM products WHERE name='Red Bull Ring Experience - Base' LIMIT 1), CURDATE() + INTERVAL 2 DAY, '11:00:00', 2, 0, 1),
((SELECT product_id FROM products WHERE name='Red Bull Ring Experience - Premium' LIMIT 1), CURDATE() + INTERVAL 3 DAY, '10:00:00', 1, 0, 1);

-- Ordine demo per user1 con taglia
INSERT INTO orders (user_id, order_number, total_amount, status, payment_status, payment_method, shipping_address, billing_address, notes)
VALUES ((SELECT user_id FROM users WHERE email='user1@example.com'), 'RB-DEMO-0001', 199.97, 'CONFIRMED', 'PAID', 'CARD', 'Via Demo 1, Milano', 'Via Demo 1, Milano', 'Ordine di esempio');

INSERT INTO order_items (order_id, product_id, slot_id, quantity, unit_price, total_price, product_name, size)
VALUES
((SELECT order_id FROM orders WHERE order_number='RB-DEMO-0001'), (SELECT product_id FROM products WHERE name='Red Bull Racing Polo'), NULL, 2, 79.99, 159.98, 'Red Bull Racing Polo', 'M'),
((SELECT order_id FROM orders WHERE order_number='RB-DEMO-0001'), (SELECT product_id FROM products WHERE name='RB19 Modello 1:18'), NULL, 1, 129.99, 129.99, 'RB19 Modello 1:18', 'UNICA');

-- Aggiorna stock coerente con l'ordine demo
UPDATE product_variants SET stock_quantity = stock_quantity - 2 WHERE product_id=(SELECT product_id FROM products WHERE name='Red Bull Racing Polo') AND size='M';
UPDATE product_variants SET stock_quantity = stock_quantity - 1 WHERE product_id=(SELECT product_id FROM products WHERE name='RB19 Modello 1:18') AND size='UNICA';
UPDATE products SET stock_quantity = stock_quantity - 1 WHERE name='RB19 Modello 1:18';
