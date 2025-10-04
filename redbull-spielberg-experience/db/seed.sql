-- Esegui dopo schema.sql
-- mysql -u user -p redbull < db/seed.sql

-- =========================
-- Categories (upsert)
-- =========================
INSERT INTO categories (category_id, name, slug, description, is_active, created_at, updated_at) VALUES
  (1, 'Merch',      'merch',      'Merchandise & apparel',                 1, NOW(), NOW()),
  (2, 'Experience', 'experience', 'Track experiences & driving sessions',  1, NOW(), NOW())
ON DUPLICATE KEY UPDATE
  name        = VALUES(name),
  slug        = VALUES(slug),
  description = VALUES(description),
  is_active   = VALUES(is_active),
  updated_at  = NOW();

-- =========================
-- Products demo (insert-if-not-exists by name)
-- =========================

-- Cappellino Team
INSERT INTO products
  (category_id, name, description, short_description, price,
   product_type, experience_type, stock_quantity, image_url,
   is_featured, is_active, created_at, updated_at)
SELECT
  1, 'Cappellino Team', 'Cappellino ufficiale Red Bull Racing',
  'Cappellino RB', 34.90, 'MERCHANDISE', NULL, 120,
  'https://picsum.photos/seed/rb-cap/640/400', 1, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Cappellino Team');

-- Felpa Team 2025
INSERT INTO products
  (category_id, name, description, short_description, price,
   product_type, experience_type, stock_quantity, image_url,
   is_featured, is_active, created_at, updated_at)
SELECT
  1, 'Felpa Team 2025', 'Felpa ufficiale stagione 2025',
  'Felpa RB 2025', 89.00, 'MERCHANDISE', NULL, 45,
  'https://picsum.photos/seed/rb-hoodie/640/400', 1, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Felpa Team 2025');

-- Borraccia RB
INSERT INTO products
  (category_id, name, description, short_description, price,
   product_type, experience_type, stock_quantity, image_url,
   is_featured, is_active, created_at, updated_at)
SELECT
  1, 'Borraccia RB', 'Borraccia termica 750ml',
  'Borraccia', 24.50, 'MERCHANDISE', NULL, 300,
  'https://picsum.photos/seed/rb-bottle/640/400', 0, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Borraccia RB');

-- Hot Lap F1
INSERT INTO products
  (category_id, name, description, short_description, price,
   product_type, experience_type, stock_quantity, image_url,
   is_featured, is_active, created_at, updated_at)
SELECT
  2, 'Hot Lap F1', 'Giro in pista su monoposto F1 a Spielberg',
  'Hot Lap F1', 1299.00, 'EXPERIENCE', 'F1', NULL,
  'https://picsum.photos/seed/f1-hotlap/640/400', 1, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Hot Lap F1');

-- Esperienza NASCAR
INSERT INTO products
  (category_id, name, description, short_description, price,
   product_type, experience_type, stock_quantity, image_url,
   is_featured, is_active, created_at, updated_at)
SELECT
  2, 'Esperienza NASCAR', 'Sessione guidata con vettura NASCAR',
  'NASCAR Drive', 799.00, 'EXPERIENCE', 'NASCAR', NULL,
  'https://picsum.photos/seed/nascar/640/400', 0, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Esperienza NASCAR');