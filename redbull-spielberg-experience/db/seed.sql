-- Esegui dopo schema.sql
-- mysql -u user -p redbull < db/seed.sql

-- Categorie con ID fissi (l’UI li usa già)
INSERT INTO categories (category_id, name, slug) VALUES
  (1, 'Merch',      'merch'),
  (2, 'Experience', 'experience')
ON DUPLICATE KEY UPDATE name=VALUES(name), slug=VALUES(slug);

-- Prodotti demo: 3 merch + 2 experience
INSERT INTO products
  (category_id, name, description, short_description, price,
   product_type, experience_type, stock_quantity, image_url,
   is_featured, is_active, created_at, updated_at)
VALUES
  (1, 'Cappellino Team', 'Cappellino ufficiale Red Bull Racing',
   'Cappellino RB', 34.90, 'MERCHANDISE', NULL, 120,
   'https://picsum.photos/seed/rb-cap/640/400', 1, 1, NOW(), NOW()),

  (1, 'Felpa Team 2025', 'Felpa ufficiale stagione 2025',
   'Felpa RB 2025', 89.00, 'MERCHANDISE', NULL, 45,
   'https://picsum.photos/seed/rb-hoodie/640/400', 1, 1, NOW(), NOW()),

  (1, 'Borraccia RB', 'Borraccia termica 750ml',
   'Borraccia', 24.50, 'MERCHANDISE', NULL, 300,
   'https://picsum.photos/seed/rb-bottle/640/400', 0, 1, NOW(), NOW()),

  (2, 'Hot Lap F1', 'Giro in pista su monoposto F1 a Spielberg',
   'Hot Lap F1', 1299.00, 'EXPERIENCE', 'F1', NULL,
   'https://picsum.photos/seed/f1-hotlap/640/400', 1, 1, NOW(), NOW()),

  (2, 'Esperienza NASCAR', 'Sessione guidata con vettura NASCAR',
   'NASCAR Drive', 799.00, 'EXPERIENCE', 'NASCAR', NULL,
   'https://picsum.photos/seed/nascar/640/400', 0, 1, NOW(), NOW());