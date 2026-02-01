-- Demo seed non distruttivo: pulisce dati volatili (ordini/carrelli/slot) e reinserisce demo
USE red_bull_spielberg;

SET FOREIGN_KEY_CHECKS=0;
TRUNCATE TABLE order_items;
TRUNCATE TABLE orders;
TRUNCATE TABLE cart;
TRUNCATE TABLE time_slots;
-- Non tocchiamo product_variants/products per non creare nuovi prodotti
SET FOREIGN_KEY_CHECKS=1;

-- Categorie (inserimento idempotente)
INSERT IGNORE INTO categories (name, description, is_active) VALUES
('Driving Experiences', 'Red Bull Racing driving experiences on Spielberg circuit', 1),
('Apparel', 'Official Red Bull Racing clothing and accessories', 1),
('Models & Collectibles', 'Die-cast models and collectible items', 1);

-- Utenti demo (password demo in chiaro: da sostituire con hash in produzione)
INSERT IGNORE INTO users (email, password, first_name, last_name, user_type, is_active) VALUES
('admin@redbull.com', 'admin123', 'Red Bull', 'Admin', 'ADMIN', 1),
('user1@example.com', 'user123', 'Mario', 'Rossi', 'REGISTERED', 1),
('user2@example.com', 'user123', 'Giulia', 'Verdi', 'REGISTERED', 1),
('user3@example.com', 'user123', 'Luca', 'Bianchi', 'REGISTERED', 1);

-- Placeholder base64 (1x1 png trasparente)
SET @img = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Y0Nfg0AAAAASUVORK5CYII=';

-- Prodotti MERCH (idempotente)
INSERT IGNORE INTO products (category_id, name, description, short_description, price, product_type, stock_quantity, image_url, is_active, is_featured)
SELECT c.category_id, 'Red Bull Racing Team Cap', 'Cappellino ufficiale Red Bull Racing', 'Cap ufficiale', 39.99, 'MERCHANDISE', 200, @img, 1, 1
FROM categories c WHERE c.name='Apparel' LIMIT 1;
INSERT IGNORE INTO products (category_id, name, description, short_description, price, product_type, stock_quantity, image_url, is_active, is_featured)
SELECT c.category_id, 'Red Bull Racing Polo', 'Polo ufficiale del team', 'Polo team', 79.99, 'MERCHANDISE', 150, @img, 1, 1
FROM categories c WHERE c.name='Apparel' LIMIT 1;
INSERT IGNORE INTO products (category_id, name, description, short_description, price, product_type, stock_quantity, image_url, is_active, is_featured)
SELECT c.category_id, 'RB19 Modello 1:18', 'Modello die-cast RB19', 'Modello 1:18', 129.99, 'MERCHANDISE', 50, @img, 1, 0
FROM categories c WHERE c.name='Models & Collectibles' LIMIT 1;

-- Varianti/taglie (idempotente)
INSERT IGNORE INTO product_variants (product_id, size, sku, price_override, stock_quantity, is_active)
VALUES
((SELECT product_id FROM products WHERE name='Red Bull Racing Team Cap' LIMIT 1), 'UNICA', 'CAP-RB-ONE', NULL, 120, 1),
((SELECT product_id FROM products WHERE name='Red Bull Racing Polo' LIMIT 1), 'S', 'POLO-RB-S', NULL, 20, 1),
((SELECT product_id FROM products WHERE name='Red Bull Racing Polo' LIMIT 1), 'M', 'POLO-RB-M', NULL, 40, 1),
((SELECT product_id FROM products WHERE name='Red Bull Racing Polo' LIMIT 1), 'L', 'POLO-RB-L', NULL, 40, 1),
((SELECT product_id FROM products WHERE name='Red Bull Racing Polo' LIMIT 1), 'XL', 'POLO-RB-XL', NULL, 30, 1),
((SELECT product_id FROM products WHERE name='RB19 Modello 1:18' LIMIT 1), 'UNICA', 'RB19-118', NULL, 50, 1);

-- Esperienze (idempotente)
INSERT IGNORE INTO products (category_id, name, description, short_description, price, product_type, experience_type, image_url, is_active, is_featured)
SELECT c.category_id, 'Red Bull Ring Experience - Base', '3 giri con istruttore', 'Experience Base', 299.99, 'EXPERIENCE', 'BASE', @img, 1, 1
FROM categories c WHERE c.name='Driving Experiences' LIMIT 1;
INSERT IGNORE INTO products (category_id, name, description, short_description, price, product_type, experience_type, image_url, is_active, is_featured)
SELECT c.category_id, 'Red Bull Ring Experience - Premium', '5 giri con telemetry', 'Experience Premium', 499.99, 'EXPERIENCE', 'PREMIUM', @img, 1, 1
FROM categories c WHERE c.name='Driving Experiences' LIMIT 1;

-- Slot demo per experiences (idempotente)
INSERT IGNORE INTO time_slots (product_id, slot_date, slot_time, max_capacity, booked_capacity, is_available) VALUES
((SELECT product_id FROM products WHERE name='Red Bull Ring Experience - Base' LIMIT 1), CURDATE() + INTERVAL 2 DAY, '09:00:00', 2, 0, 1),
((SELECT product_id FROM products WHERE name='Red Bull Ring Experience - Base' LIMIT 1), CURDATE() + INTERVAL 2 DAY, '11:00:00', 2, 0, 1),
((SELECT product_id FROM products WHERE name='Red Bull Ring Experience - Premium' LIMIT 1), CURDATE() + INTERVAL 3 DAY, '10:00:00', 1, 0, 1),
((SELECT product_id FROM products WHERE name='Red Bull Ring Experience - Base' LIMIT 1), CURDATE() + INTERVAL 4 DAY, '09:00:00', 3, 0, 1),
((SELECT product_id FROM products WHERE name='Red Bull Ring Experience - Base' LIMIT 1), CURDATE() + INTERVAL 4 DAY, '11:00:00', 3, 0, 1),
((SELECT product_id FROM products WHERE name='Red Bull Ring Experience - Premium' LIMIT 1), CURDATE() + INTERVAL 5 DAY, '10:00:00', 2, 0, 1),
((SELECT product_id FROM products WHERE name='Red Bull Ring Experience - Premium' LIMIT 1), CURDATE() + INTERVAL 5 DAY, '14:00:00', 2, 0, 1);

-- Ordini demo distribuiti su date diverse
INSERT IGNORE INTO orders (user_id, order_number, total_amount, status, payment_status, payment_method, shipping_address, billing_address, notes, order_date)
VALUES ((SELECT user_id FROM users WHERE email='user1@example.com' LIMIT 1), 'RB-DEMO-0001', 289.97, 'CONFIRMED', 'PAID', 'CARD', 'Via Demo 1, Milano', 'Via Demo 1, Milano', 'Ordine di esempio', NOW() - INTERVAL 9 DAY);
INSERT IGNORE INTO orders (user_id, order_number, total_amount, status, payment_status, payment_method, shipping_address, billing_address, notes, order_date)
VALUES ((SELECT user_id FROM users WHERE email='user2@example.com' LIMIT 1), 'RB-DEMO-0002', 209.97, 'CONFIRMED', 'PAID', 'CARD', 'Via Demo 2, Torino', 'Via Demo 2, Torino', 'Demo merch multiprodotto', NOW() - INTERVAL 6 DAY);
INSERT IGNORE INTO orders (user_id, order_number, total_amount, status, payment_status, payment_method, shipping_address, billing_address, notes, order_date)
VALUES ((SELECT user_id FROM users WHERE email='user3@example.com' LIMIT 1), 'RB-DEMO-0003', 299.99, 'CONFIRMED', 'PAID', 'CARD', 'Via Demo 3, Roma', 'Via Demo 3, Roma', 'Demo experience base', NOW() - INTERVAL 3 DAY);
INSERT IGNORE INTO orders (user_id, order_number, total_amount, status, payment_status, payment_method, shipping_address, billing_address, notes, order_date)
VALUES ((SELECT user_id FROM users WHERE email='user1@example.com' LIMIT 1), 'RB-DEMO-0004', 579.97, 'CONFIRMED', 'PAID', 'CARD', 'Via Demo 1, Milano', 'Via Demo 1, Milano', 'Demo experience premium + merch', NOW() - INTERVAL 1 DAY);

INSERT IGNORE INTO order_items (order_id, product_id, slot_id, quantity, unit_price, total_price, product_name, size)
VALUES
((SELECT order_id FROM orders WHERE order_number='RB-DEMO-0001' LIMIT 1), (SELECT product_id FROM products WHERE name='Red Bull Racing Polo' LIMIT 1), NULL, 2, 79.99, 159.98, 'Red Bull Racing Polo', 'M'),
((SELECT order_id FROM orders WHERE order_number='RB-DEMO-0001' LIMIT 1), (SELECT product_id FROM products WHERE name='RB19 Modello 1:18' LIMIT 1), NULL, 1, 129.99, 129.99, 'RB19 Modello 1:18', 'UNICA'),
((SELECT order_id FROM orders WHERE order_number='RB-DEMO-0002' LIMIT 1), (SELECT product_id FROM products WHERE name='Red Bull Racing Team Cap' LIMIT 1), NULL, 2, 39.99, 79.98, 'Red Bull Racing Team Cap', 'UNICA'),
((SELECT order_id FROM orders WHERE order_number='RB-DEMO-0002' LIMIT 1), (SELECT product_id FROM products WHERE name='Red Bull Racing Polo' LIMIT 1), NULL, 1, 79.99, 79.99, 'Red Bull Racing Polo', 'L'),
((SELECT order_id FROM orders WHERE order_number='RB-DEMO-0003' LIMIT 1), (SELECT product_id FROM products WHERE name='Red Bull Ring Experience - Base' LIMIT 1),
 (SELECT slot_id FROM time_slots WHERE product_id=(SELECT product_id FROM products WHERE name='Red Bull Ring Experience - Base' LIMIT 1) AND slot_date=CURDATE() + INTERVAL 2 DAY AND slot_time='09:00:00' LIMIT 1),
 1, 299.99, 299.99, 'Red Bull Ring Experience - Base', NULL),
((SELECT order_id FROM orders WHERE order_number='RB-DEMO-0004' LIMIT 1), (SELECT product_id FROM products WHERE name='Red Bull Ring Experience - Premium' LIMIT 1),
 (SELECT slot_id FROM time_slots WHERE product_id=(SELECT product_id FROM products WHERE name='Red Bull Ring Experience - Premium' LIMIT 1) AND slot_date=CURDATE() + INTERVAL 3 DAY AND slot_time='10:00:00' LIMIT 1),
 1, 499.99, 499.99, 'Red Bull Ring Experience - Premium', NULL),
((SELECT order_id FROM orders WHERE order_number='RB-DEMO-0004' LIMIT 1), (SELECT product_id FROM products WHERE name='Red Bull Racing Team Cap' LIMIT 1), NULL, 2, 39.99, 79.98, 'Red Bull Racing Team Cap', 'UNICA');

-- Non tocchiamo stock/prodotti: eventuali aggiustamenti vanno fatti manualmente per i test
