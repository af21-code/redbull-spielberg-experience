-- ------------------------------------------------------------
-- Database: redbull (crealo con: CREATE DATABASE redbull; )
-- SET GLOBAL sql_mode = 'STRICT_ALL_TABLES';  -- consigliato
-- ------------------------------------------------------------
-- Usa:  mysql -u user -p redbull < db/schema.sql
-- ------------------------------------------------------------

DROP TABLE IF EXISTS products;
-- Categorie (minime per matchare l’UI e i DAO)
DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
  category_id   INT AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(100) NOT NULL UNIQUE,
  slug          VARCHAR(120) UNIQUE,
  description   TEXT NULL,
  is_active     TINYINT(1) NOT NULL DEFAULT 1,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Prodotti
CREATE TABLE products (
  product_id        INT AUTO_INCREMENT PRIMARY KEY,
  category_id       INT NULL,
  name              VARCHAR(150) NOT NULL,
  description       TEXT NULL,
  short_description VARCHAR(255) NULL,
  price             DECIMAL(10,2) NOT NULL DEFAULT 0.00,

  -- enum coerenti con model.Product
  product_type      ENUM('MERCHANDISE','EXPERIENCE') NOT NULL,
  experience_type   ENUM('F1','F2','NASCAR','STOCKCAR') NULL,

  stock_quantity    INT NULL,
  image_url         MEDIUMTEXT NULL,

  is_featured       BOOLEAN NOT NULL DEFAULT FALSE,
  is_active         BOOLEAN NOT NULL DEFAULT TRUE,

  created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_products_category
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Varianti di prodotto (taglie/colori) per MERCHANDISE
CREATE TABLE product_variants (
  variant_id      INT AUTO_INCREMENT PRIMARY KEY,
  product_id      INT NOT NULL,
  size            VARCHAR(50) NOT NULL,
  sku             VARCHAR(80) NULL,
  price_override  DECIMAL(10,2) NULL,
  stock_quantity  INT NULL,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_variant_product FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  UNIQUE KEY uq_product_size (product_id, size)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Indici utili per filtri/ordinamenti
CREATE INDEX idx_products_active    ON products(is_active);
CREATE INDEX idx_products_category  ON products(category_id);
CREATE INDEX idx_products_type      ON products(product_type);
CREATE INDEX idx_products_etype     ON products(experience_type);
CREATE INDEX idx_products_created   ON products(created_at);
CREATE INDEX idx_products_updated   ON products(updated_at);
CREATE INDEX idx_products_name_like ON products(name);

-- TABELLA DETTAGLI ORDINI
CREATE TABLE order_items (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id      INT NOT NULL,
  product_id    INT NOT NULL,
  product_name  VARCHAR(255) NOT NULL,
  size          VARCHAR(50) NULL,
  quantity      INT NOT NULL DEFAULT 1,
  price         DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_order_item_product FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- TABELLA CARRELLO
CREATE TABLE cart (
  cart_id      INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT NOT NULL,
  product_id    INT NOT NULL,
  size          VARCHAR(50) NOT NULL DEFAULT '',
  quantity      INT NOT NULL DEFAULT 1,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_cart_user FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_cart_product FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  UNIQUE KEY unique_cart_item (user_id, product_id, size, slot_id)
);
