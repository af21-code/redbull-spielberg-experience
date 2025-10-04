-- ------------------------------------------------------------
-- Database: redbull (crealo con: CREATE DATABASE redbull; )
-- SET GLOBAL sql_mode = 'STRICT_ALL_TABLES';  -- consigliato
-- ------------------------------------------------------------
-- Usa:  mysql -u user -p redbull < db/schema.sql
-- ------------------------------------------------------------

DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;

-- Categorie (minime per matchare l’UI: 1=Merch, 2=Experience)
CREATE TABLE categories (
  category_id   INT AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(100) NOT NULL UNIQUE,
  slug          VARCHAR(120) UNIQUE,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
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
  image_url         VARCHAR(255) NULL,

  is_featured       BOOLEAN NOT NULL DEFAULT FALSE,
  is_active         BOOLEAN NOT NULL DEFAULT TRUE,

  created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_products_category
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Indici utili per filtri/ordinamenti
CREATE INDEX idx_products_active    ON products(is_active);
CREATE INDEX idx_products_category  ON products(category_id);
CREATE INDEX idx_products_type      ON products(product_type);
CREATE INDEX idx_products_etype     ON products(experience_type);
CREATE INDEX idx_products_created   ON products(created_at);
CREATE INDEX idx_products_updated   ON products(updated_at);
CREATE INDEX idx_products_name_like ON products(name);