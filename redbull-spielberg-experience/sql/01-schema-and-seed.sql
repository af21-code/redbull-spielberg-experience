-- DEV ONLY: this script DROPS and recreates the database
SET NAMES utf8mb4;
SET time_zone = '+00:00';

DROP DATABASE red_bull_spielberg;
CREATE DATABASE red_bull_spielberg;
USE red_bull_spielberg;

-- =============================================
-- TABELLA UTENTI
-- =============================================
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    user_type ENUM('VISITOR', 'REGISTERED', 'PREMIUM', 'ADMIN') DEFAULT 'REGISTERED',
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =============================================
-- TABELLA CATEGORIE PRODOTTI
-- =============================================
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- TABELLA PRODOTTI/ESPERIENZE
-- =============================================
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    price DECIMAL(10,2) NOT NULL,
    product_type ENUM('EXPERIENCE', 'MERCHANDISE') NOT NULL,
    experience_type ENUM('BASE', 'PREMIUM', 'ELITE') NULL,
    stock_quantity INT DEFAULT 0,
    image_url VARCHAR(500),
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- =============================================
-- TABELLA SLOT TEMPORALI (per esperienze di guida)
-- =============================================
CREATE TABLE time_slots (
    slot_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    slot_date DATE NOT NULL,
    slot_time TIME NOT NULL,
    max_capacity INT DEFAULT 1,
    booked_capacity INT DEFAULT 0,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    UNIQUE KEY unique_slot (product_id, slot_date, slot_time)
);

-- =============================================
-- TABELLA ORDINI
-- =============================================
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'PROCESSING', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
    payment_status ENUM('PENDING', 'PAID', 'FAILED', 'REFUNDED') DEFAULT 'PENDING',
    payment_method VARCHAR(50),
    shipping_address TEXT,
    billing_address TEXT,
    notes TEXT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- =============================================
-- TABELLA DETTAGLI ORDINI
-- =============================================
CREATE TABLE order_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    slot_id INT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (slot_id) REFERENCES time_slots(slot_id)
);

-- =============================================
-- TABELLA CARRELLO
-- =============================================
CREATE TABLE cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    slot_id INT NULL,
    quantity INT NOT NULL DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (slot_id) REFERENCES time_slots(slot_id),
    UNIQUE KEY unique_cart_item (user_id, product_id, slot_id)
);

-- =============================================
-- TABELLA SESSIONI UTENTE
-- =============================================
CREATE TABLE user_sessions (
    session_id VARCHAR(255) PRIMARY KEY,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- =============================================
-- INSERIMENTO DATI INIZIALI
-- =============================================

-- Inserisci categorie
INSERT INTO categories (name, description) VALUES
('Driving Experiences', 'Red Bull Racing driving experiences on Spielberg circuit'),
('Apparel', 'Official Red Bull Racing clothing and accessories'),
('Models & Collectibles', 'Die-cast models and collectible items'),
('Accessories', 'Red Bull Racing branded accessories');

-- Inserisci admin di default
INSERT INTO users (email, password, first_name, last_name, user_type) VALUES
('admin@redbull.com', 'admin123', 'Red Bull', 'Admin', 'ADMIN');

-- Inserisci esperienze di guida
INSERT INTO products (category_id, name, description, short_description, price, product_type, experience_type, image_url, is_featured) VALUES
(1, 'Red Bull Ring Experience - Base', 'Experience the thrill of driving a Red Bull Racing car on the legendary Spielberg circuit. This base package includes 3 laps with professional instruction.', 'Drive a Red Bull Racing car for 3 exciting laps', 299.99, 'EXPERIENCE', 'BASE', 'images/experience-base.jpg', TRUE),
(1, 'Red Bull Ring Experience - Premium', 'Take your driving experience to the next level with 5 laps, telemetry data analysis, and a personalized racing suit.', 'Premium experience with 5 laps and telemetry analysis', 499.99, 'EXPERIENCE', 'PREMIUM', 'images/experience-premium.jpg', TRUE),
(1, 'Red Bull Ring Experience - Elite', 'The ultimate Red Bull Racing experience with 10 laps, private coaching session, pit lane tour, and exclusive merchandise.', 'Ultimate experience with 10 laps and exclusive access', 999.99, 'EXPERIENCE', 'ELITE', 'images/experience-elite.jpg', TRUE);

-- Inserisci merchandising
INSERT INTO products (category_id, name, description, short_description, price, product_type, stock_quantity, image_url) VALUES
(2, 'Red Bull Racing Team Cap', 'Official Red Bull Racing team cap worn by drivers and crew', 'Official team cap with Red Bull Racing logo', 39.99, 'MERCHANDISE', 100, 'images/cap.jpg'),
(2, 'Red Bull Racing Hoodie', 'Premium quality hoodie with Red Bull Racing branding', 'Comfortable hoodie with team branding', 89.99, 'MERCHANDISE', 50, 'images/hoodie.jpg'),
(3, 'RB19 Die-Cast Model 1:18', 'Detailed 1:18 scale model of the championship-winning RB19', 'Highly detailed die-cast model of RB19', 129.99, 'MERCHANDISE', 25, 'images/model-rb19.jpg');

-- Inserisci alcuni slot temporali per le esperienze
INSERT INTO time_slots (product_id, slot_date, slot_time, max_capacity) VALUES
(1, '2025-08-15', '09:00:00', 2),
(1, '2025-08-15', '11:00:00', 2),
(1, '2025-08-15', '14:00:00', 2),
(1, '2025-08-15', '16:00:00', 2),
(2, '2025-08-15', '10:00:00', 1),
(2, '2025-08-15', '15:00:00', 1),
(3, '2025-08-15', '13:00:00', 1);

SHOW TABLES;

SELECT 
    'categories' as tabella, COUNT(*) as righe FROM categories
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL
SELECT 'time_slots', COUNT(*) FROM time_slots;

SELECT product_id, name, product_type, is_active FROM products WHERE product_type='MERCHANDISE';


SET SQL_SAFE_UPDATES = 0;

-- Aggiornamento identità shop --
USE red_bull_spielberg;

START TRANSACTION;

-- CAP
UPDATE products
SET short_description = 'Cappellino ufficiale della squadra con logo Red Bull Racing',
    description       = 'Cappellino ufficiale Red Bull Racing con logo ricamato e materiali di qualità.',
    is_active         = TRUE
WHERE product_type = 'MERCHANDISE'
  AND name = 'Red Bull Racing Team Cap';

-- HOODIE -> POLO (ricorda di avere l'immagine polo.jpg in /images)
UPDATE products
SET name              = 'Red Bull Racing Polo',
    short_description = 'Comoda polo con il marchio della squadra',
    description       = 'Polo ufficiale Red Bull Racing, confortevole e con dettagli del team.',
    image_url         = 'images/polo.jpg',
    is_active         = TRUE
WHERE product_type = 'MERCHANDISE'
  AND name = 'Red Bull Racing Hoodie';

-- RB19 model
UPDATE products
SET name              = 'RB19 Modello scala 1:18',
    short_description = 'Modello altamente dettagliato dell\'RB19',
    description       = 'Modello die-cast in scala 1:18 della RB19 con dettagli da collezione.',
    is_active         = TRUE
WHERE product_type = 'MERCHANDISE'
  AND name = 'RB19 Die-Cast Model 1:18';

COMMIT;

SET SQL_SAFE_UPDATES = 1;

-- Verifica
SELECT product_id, name, short_description, price, image_url
FROM products
WHERE product_type='MERCHANDISE';

SELECT COUNT(*) AS merch
FROM products
WHERE product_type='MERCHANDISE' AND is_active=1;

SELECT product_id,name,short_description,price,image_url,stock_quantity
FROM products
WHERE product_type='MERCHANDISE';

-- Aggiornamento spedizione --
USE red_bull_spielberg;

-- 1) Aggiungi colonne di tracking all'ordine
ALTER TABLE orders
  ADD COLUMN carrier VARCHAR(50) NULL AFTER payment_method,
  ADD COLUMN tracking_code VARCHAR(64) NULL AFTER carrier,
  ADD COLUMN shipped_at TIMESTAMP NULL AFTER tracking_code,
  ADD COLUMN estimated_delivery DATE NULL AFTER shipped_at;

-- 2) (Facoltativi) indici utili
CREATE INDEX idx_orders_user_date ON orders(user_id, order_date);
CREATE INDEX idx_orders_tracking ON orders(tracking_code);

-- 3) Seed: un ordine demo per l’admin
INSERT INTO orders (user_id, order_number, total_amount, status, payment_status, payment_method,
                    carrier, tracking_code, shipped_at, estimated_delivery)
SELECT u.user_id, 'RB-TEST-0001', 79.98, 'PROCESSING', 'PAID', 'CARD',
       'DHL', '00340434161234567890', NOW(), DATE_ADD(CURDATE(), INTERVAL 3 DAY)
FROM users u WHERE u.email='admin@redbull.com' LIMIT 1;

-- 4) Riga articolo demo (Cap x2)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price, product_name)
SELECT o.order_id, p.product_id, 2, p.price, p.price*2, p.name
FROM orders o
JOIN products p ON p.name='Red Bull Racing Team Cap'
WHERE o.order_number='RB-TEST-0001';

-- Update --
USE red_bull_spielberg;

ALTER TABLE order_items
  ADD COLUMN driver_name     VARCHAR(100) NULL AFTER product_name,
  ADD COLUMN companion_name  VARCHAR(100) NULL AFTER driver_name,
  ADD COLUMN vehicle_code    VARCHAR(50)  NULL AFTER companion_name,
  ADD COLUMN event_date      DATE         NULL AFTER vehicle_code;

CREATE INDEX idx_order_items_slot ON order_items(slot_id);


SELECT DISTINCT slot_date
FROM time_slots
WHERE product_id IN (1,2) AND slot_date >= CURDATE()
ORDER BY slot_date
LIMIT 20;

USE red_bull_spielberg;

-- 1) pulisci eventuali slot futuri dei prodotti 1 e 2 (facoltativo ma consigliato)
DELETE FROM time_slots
WHERE product_id IN (1,2) AND slot_date >= CURDATE();

-- 2) genera slot per i prossimi 21 giorni
SET @start = CURDATE();

-- product 1 (Base): 09:00, 11:00, 15:00 - capienza 2
INSERT INTO time_slots (product_id, slot_date, slot_time, max_capacity, booked_capacity, is_available)
SELECT 1, DATE_ADD(@start, INTERVAL d DAY), t, 2, 0, 1
FROM (
  SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
  UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
  UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13
  UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18
  UNION ALL SELECT 19 UNION ALL SELECT 20
) days
CROSS JOIN (SELECT '09:00:00' t UNION ALL SELECT '11:00:00' UNION ALL SELECT '15:00:00') times;

-- product 2 (Premium): 10:00, 13:00, 16:00 - capienza 1
INSERT INTO time_slots (product_id, slot_date, slot_time, max_capacity, booked_capacity, is_available)
SELECT 2, DATE_ADD(@start, INTERVAL d DAY), t, 1, 0, 1
FROM (
  SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
  UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
  UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13
  UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18
  UNION ALL SELECT 19 UNION ALL SELECT 20
) days
CROSS JOIN (SELECT '10:00:00' t UNION ALL SELECT '13:00:00' UNION ALL SELECT '16:00:00') times;

-- 3) verifica che ci siano slot futuri
SELECT product_id, slot_date, slot_time
FROM time_slots
WHERE slot_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 21 DAY)
ORDER BY slot_date, slot_time
LIMIT 60;

USE red_bull_spielberg;

-- 1) Salva anche il numero pilota negli articoli d’ordine
ALTER TABLE order_items
  ADD COLUMN driver_number VARCHAR(4) NULL AFTER driver_name;

-- 2) (Consigliato) Salva i dettagli della prenotazione anche nel carrello
ALTER TABLE cart
  ADD COLUMN driver_name     VARCHAR(100) NULL AFTER quantity,
  ADD COLUMN driver_number   VARCHAR(4)   NULL AFTER driver_name,
  ADD COLUMN companion_name  VARCHAR(100) NULL AFTER driver_number,
  ADD COLUMN vehicle_code    VARCHAR(50)  NULL AFTER companion_name,
  ADD COLUMN event_date      DATE         NULL AFTER vehicle_code;

-- 3) Indici utili (opzionali)
CREATE INDEX idx_cart_user ON cart(user_id);
CREATE INDEX idx_time_slots_product_date ON time_slots(product_id, slot_date);



