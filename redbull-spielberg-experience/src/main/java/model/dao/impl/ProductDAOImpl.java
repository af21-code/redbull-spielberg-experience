package model.dao.impl;

import model.Product;
import model.dao.ProductDAO;
import utils.DatabaseConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAOImpl implements ProductDAO {

    private static final String BASE_SELECT = """
        SELECT product_id, category_id, name, description, short_description,
               price, product_type, experience_type, stock_quantity, image_url,
               is_featured, is_active, created_at, updated_at
        FROM products
    """;

    private Connection getConnection() throws Exception {
        // Usa il tuo singleton di connessione
        return DatabaseConnection.getInstance().getConnection();
    }

    @Override
    public List<Product> findActiveMerchandise(Integer categoryId) throws Exception {
        String sql = BASE_SELECT +
                " WHERE is_active = 1 AND product_type = 'MERCHANDISE' " +
                (categoryId != null ? " AND category_id = ? " : "") +
                " ORDER BY created_at DESC";

        List<Product> results = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            if (categoryId != null) {
                ps.setInt(1, categoryId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    results.add(mapRow(rs));
                }
            }
        }
        return results;
    }

    @Override
    public Product findById(int productId) throws Exception {
        String sql = BASE_SELECT + " WHERE product_id = ? AND is_active = 1";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    @Override
    public List<Product> findAll(Integer categoryId) throws Exception {
        String sql = BASE_SELECT +
                " WHERE is_active = 1 " +
                (categoryId != null ? " AND category_id = ? " : "") +
                " ORDER BY created_at DESC";

        List<Product> results = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            if (categoryId != null) {
                ps.setInt(1, categoryId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    results.add(mapRow(rs));
                }
            }
        }
        return results;
    }

    /**
     * Mappa una riga del ResultSet in un oggetto Product.
     * Adegua i set* ai campi effettivamente presenti nel tuo model.Product.
     */
    private Product mapRow(ResultSet rs) throws SQLException {
        Product p = new Product();

        p.setProductId(rs.getInt("product_id"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setName(rs.getString("name"));
        p.setDescription(rs.getString("description"));
        p.setShortDescription(rs.getString("short_description"));

        BigDecimal price = rs.getBigDecimal("price");
        p.setPrice(price);

        // Enum ProductType
        String productType = rs.getString("product_type");
        if (productType != null) {
            p.setProductType(Product.ProductType.valueOf(productType)); // "EXPERIENCE" | "MERCHANDISE"
        }

        // Enum ExperienceType (può essere null)
        String experienceType = rs.getString("experience_type");
        if (experienceType != null) {
            p.setExperienceType(Product.ExperienceType.valueOf(experienceType)); // "BASE" | "PREMIUM" | "ELITE"
        }

        // stock_quantity (può essere null per le EXPERIENCE)
        int stock = rs.getInt("stock_quantity");
        if (rs.wasNull()) {
            p.setStockQuantity(null);
        } else {
            p.setStockQuantity(stock);
        }

        p.setImageUrl(rs.getString("image_url"));
        p.setFeatured(rs.getBoolean("is_featured"));
        p.setActive(rs.getBoolean("is_active"));

        // Se nel tuo model hai createdAt/updatedAt, decommenta:
        // p.setCreatedAt(rs.getTimestamp("created_at").toInstant());
        // p.setUpdatedAt(rs.getTimestamp("updated_at").toInstant());

        return p;
    }
}