package model.dao.impl;

import model.Product;
import model.dao.ProductDAO;
import utils.DatabaseConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class ProductDAOImpl implements ProductDAO {

    private Product mapRow(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getInt("product_id"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setName(rs.getString("name"));
        p.setDescription(rs.getString("description"));
        p.setShortDescription(rs.getString("short_description"));
        p.setPrice(rs.getBigDecimal("price"));

        String ptype = rs.getString("product_type");
        if (ptype != null) {
            p.setProductType(Product.ProductType.valueOf(ptype));
        }

        String etype = rs.getString("experience_type");
        if (etype != null) {
            p.setExperienceType(Product.ExperienceType.valueOf(etype));
        }

        Object stockObj = rs.getObject("stock_quantity");
        p.setStockQuantity(stockObj != null ? rs.getInt("stock_quantity") : null);

        p.setImageUrl(rs.getString("image_url"));
        p.setFeatured(rs.getBoolean("is_featured"));
        p.setActive(rs.getBoolean("is_active"));

        Timestamp cAt = rs.getTimestamp("created_at");
        if (cAt != null) p.setCreatedAt(cAt.toLocalDateTime());

        Timestamp uAt = rs.getTimestamp("updated_at");
        if (uAt != null) p.setUpdatedAt(uAt.toLocalDateTime());

        return p;
        }

    @Override
    public List<Product> findAll(Integer categoryId) throws Exception {
        String baseSql = """
            SELECT product_id, category_id, name, description, short_description,
                   price, product_type, experience_type, stock_quantity, image_url,
                   is_featured, is_active, created_at, updated_at
            FROM products
            WHERE is_active = 1
            """;
        String order = " ORDER BY created_at DESC";

        String sql = baseSql + (categoryId != null ? " AND category_id = ?" : "") + order;

        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            if (categoryId != null) {
                ps.setInt(1, categoryId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                List<Product> out = new ArrayList<>();
                while (rs.next()) {
                    out.add(mapRow(rs));
                }
                return out;
            }
        }
    }

    @Override
    public Product findById(int productId) throws Exception {
        String sql = """
            SELECT product_id, category_id, name, description, short_description,
                   price, product_type, experience_type, stock_quantity, image_url,
                   is_featured, is_active, created_at, updated_at
            FROM products
            WHERE is_active = 1 AND product_id = ?
            """;

        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
                return null;
            }
        }
    }
}