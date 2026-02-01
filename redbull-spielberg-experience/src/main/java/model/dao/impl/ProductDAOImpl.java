package model.dao.impl;

import model.Product;
import model.ProductVariant;
import model.dao.ProductDAO;
import utils.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class ProductDAOImpl implements ProductDAO {

    private static final String BASE_SELECT = """
                SELECT product_id, category_id, name, description, short_description,
                       price, product_type, experience_type, stock_quantity, image_url,
                       is_featured, is_active, created_at, updated_at
                FROM products
            """;

    // whitelist colonne ordinabili
    private static final Map<String, String> SORT_MAP = Map.ofEntries(
            Map.entry("name", "name"),
            Map.entry("price", "price"),
            Map.entry("stock", "stock_quantity"),
            Map.entry("active", "is_active"),
            Map.entry("featured", "is_featured"),
            Map.entry("created", "created_at"),
            Map.entry("updated", "updated_at"),
            Map.entry("ptype", "product_type"),
            Map.entry("etype", "experience_type"));

    private Connection getConnection() throws Exception {
        return DatabaseConnection.getInstance().getConnection();
    }

    // ========= Public / Shop =========
    @Override
    public List<Product> findActiveMerchandise(Integer categoryId) throws Exception {
        String sql = BASE_SELECT +
                " WHERE is_active = 1 AND product_type = 'MERCHANDISE' " +
                (categoryId != null ? " AND category_id = ? " : "") +
                " ORDER BY created_at DESC";

        List<Product> results = new ArrayList<>();
        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            if (categoryId != null)
                ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = mapRow(rs);
                    p.setVariants(loadVariants(con, p.getProductId(), true));
                    results.add(p);
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
                    Product p = mapRow(rs);
                    p.setVariants(loadVariants(con, p.getProductId(), true));
                    return p;
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
            if (categoryId != null)
                ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = mapRow(rs);
                    p.setVariants(loadVariants(con, p.getProductId(), true));
                    results.add(p);
                }
            }
        }
        return results;
    }

    // ========= Admin - senza paginazione (compat) =========
    @Override
    public List<Product> adminFindAll(Integer categoryId, String q, Boolean onlyInactive) throws Exception {
        StringBuilder sb = new StringBuilder(BASE_SELECT).append(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        appendFilters(sb, params, categoryId, q, onlyInactive);
        // prima i record aggiornati; poi creati
        sb.append(" ORDER BY (updated_at IS NULL), updated_at DESC, created_at DESC ");

        List<Product> results = new ArrayList<>();
        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sb.toString())) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = mapRow(rs);
                    p.setVariants(loadVariants(con, p.getProductId(), false));
                    results.add(p);
                }
            }
        }
        return results;
    }

    // ========= Admin - con paginazione e ordinamento =========
    @Override
    public List<Product> adminFindAllPaged(Integer categoryId, String q, Boolean onlyInactive,
            String sort, String dir, int limit, int offset) throws Exception {
        StringBuilder sb = new StringBuilder(BASE_SELECT).append(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        appendFilters(sb, params, categoryId, q, onlyInactive);

        String sortCol = SORT_MAP.getOrDefault(safeLower(sort), "updated_at");
        String sortDir = "asc".equalsIgnoreCase(dir) ? "ASC" : "DESC";

        sb.append(" ORDER BY ").append(sortCol).append(' ').append(sortDir)
                .append(", created_at DESC ");

        sb.append(" LIMIT ? OFFSET ? ");
        params.add(limit);
        params.add(offset);

        List<Product> results = new ArrayList<>();
        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sb.toString())) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = mapRow(rs);
                    p.setVariants(loadVariants(con, p.getProductId(), false));
                    results.add(p);
                }
            }
        }
        return results;
    }

    @Override
    public int adminCount(Integer categoryId, String q, Boolean onlyInactive) throws Exception {
        StringBuilder sb = new StringBuilder("SELECT COUNT(*) FROM products WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        appendFilters(sb, params, categoryId, q, onlyInactive);

        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sb.toString())) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        }
        return 0;
    }

    @Override
    public Product adminFindById(int productId) throws Exception {
        String sql = BASE_SELECT + " WHERE product_id = ?";
        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = mapRow(rs);
                    p.setVariants(loadVariants(con, p.getProductId(), false));
                    return p;
                }
            }
        }
        return null;
    }

    @Override
    public int insert(Product p) throws Exception {
        String sql = """
                    INSERT INTO products
                      (category_id, name, description, short_description, price,
                       product_type, experience_type, stock_quantity, image_url,
                       is_featured, is_active, created_at, updated_at)
                    VALUES (?,?,?,?,?,?,?,?,?,?,?, NOW(), NOW())
                """;
        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            bindUpsert(ps, p);
            ps.executeUpdate();
            Integer newId = null;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) newId = rs.getInt(1);
            }
            if (newId == null) throw new SQLException("Insert product failed: no ID obtained.");
            p.setProductId(newId);
            saveVariants(con, p, true);
            return newId;
        }
    }

    @Override
    public void update(Product p) throws Exception {
        String sql = """
                    UPDATE products SET
                      category_id=?, name=?, description=?, short_description=?, price=?,
                      product_type=?, experience_type=?, stock_quantity=?, image_url=?,
                      is_featured=?, is_active=?, updated_at=NOW()
                    WHERE product_id=?
                """;
        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            int idx = bindUpsert(ps, p);
            ps.setInt(idx, p.getProductId());
            ps.executeUpdate();
            saveVariants(con, p, false);
        }
    }

    @Override
    public void softDelete(int productId) throws Exception {
        setActive(productId, false);
    }

    @Override
    public void setActive(int productId, boolean active) throws Exception {
        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(
                        "UPDATE products SET is_active=?, updated_at=NOW() WHERE product_id=?")) {
            ps.setBoolean(1, active);
            ps.setInt(2, productId);
            ps.executeUpdate();
        }
    }

    @Override
    public void setFeatured(int productId, boolean featured) throws Exception {
        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(
                        "UPDATE products SET is_featured=?, updated_at=NOW() WHERE product_id=?")) {
            ps.setBoolean(1, featured);
            ps.setInt(2, productId);
            ps.executeUpdate();
        }
    }

    // ========= Helpers =========

    private static void appendFilters(StringBuilder sb, List<Object> params,
            Integer categoryId, String q, Boolean onlyInactive) {
        if (categoryId != null) {
            sb.append(" AND category_id = ? ");
            params.add(categoryId);
        }
        if (q != null && !q.isBlank()) {
            sb.append(" AND LOWER(name) LIKE ? ");
            params.add("%" + q.toLowerCase(Locale.ITALIAN).trim() + "%");
        }
        if (onlyInactive != null && onlyInactive) {
            sb.append(" AND is_active = 0 ");
        }
    }

    private static void bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object v = params.get(i);
            if (v == null) {
                ps.setNull(i + 1, Types.NULL);
            } else if (v instanceof Integer) {
                ps.setInt(i + 1, (Integer) v);
            } else if (v instanceof String) {
                ps.setString(i + 1, (String) v);
            } else if (v instanceof Boolean) {
                ps.setBoolean(i + 1, (Boolean) v);
            } else {
                ps.setObject(i + 1, v);
            }
        }
    }

    private static String safeLower(String s) {
        return s == null ? "" : s.toLowerCase(Locale.ITALIAN);
    }

    private int bindUpsert(PreparedStatement ps, Product p) throws SQLException {
        int i = 1;
        // category_id
        if (p.getCategoryId() == null)
            ps.setNull(i++, Types.INTEGER);
        else
            ps.setInt(i++, p.getCategoryId());
        ps.setString(i++, p.getName());
        ps.setString(i++, p.getDescription());
        ps.setString(i++, p.getShortDescription());
        ps.setBigDecimal(i++, p.getPrice());

        // product_type / experience_type
        ps.setString(i++, p.getProductType() == null ? null : p.getProductType().name());
        if (p.getExperienceType() == null) {
            ps.setNull(i++, Types.VARCHAR);
        } else {
            ps.setString(i++, p.getExperienceType().name());
        }

        // stock_quantity
        if (p.getStockQuantity() == null)
            ps.setNull(i++, Types.INTEGER);
        else
            ps.setInt(i++, p.getStockQuantity());

        ps.setString(i++, p.getImageUrl());

        // featured / active
        ps.setBoolean(i++, Boolean.TRUE.equals(p.getFeatured()));
        ps.setBoolean(i++, Boolean.TRUE.equals(p.getActive()));

        return i;
    }

    private Product mapRow(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getInt("product_id"));
        p.setCategoryId((Integer) rs.getObject("category_id"));
        p.setName(rs.getString("name"));
        p.setDescription(rs.getString("description"));
        p.setShortDescription(rs.getString("short_description"));
        p.setPrice(rs.getBigDecimal("price"));

        p.setProductType(safeProductType(rs.getString("product_type")));
        p.setExperienceType(safeExperienceType(rs.getString("experience_type")));

        Integer stock = (Integer) rs.getObject("stock_quantity");
        p.setStockQuantity(stock);

        p.setImageUrl(rs.getString("image_url"));
        p.setFeatured(rs.getBoolean("is_featured"));
        p.setActive(rs.getBoolean("is_active"));

        Timestamp cAt = rs.getTimestamp("created_at");
        Timestamp uAt = rs.getTimestamp("updated_at");
        if (cAt != null)
            p.setCreatedAt(cAt.toLocalDateTime());
        if (uAt != null)
            p.setUpdatedAt(uAt.toLocalDateTime());
        return p;
    }

    private List<ProductVariant> loadVariants(Connection con, int productId, boolean onlyActive) throws SQLException {
        final String sql = "SELECT variant_id, size, sku, price_override, stock_quantity, is_active, created_at, updated_at " +
                "FROM product_variants WHERE product_id=?" + (onlyActive ? " AND is_active=1" : "") + " ORDER BY variant_id";
        List<ProductVariant> variants = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariant v = new ProductVariant();
                    v.setVariantId(rs.getInt("variant_id"));
                    v.setProductId(productId);
                    v.setSize(rs.getString("size"));
                    v.setSku(rs.getString("sku"));
                    v.setPriceOverride(rs.getBigDecimal("price_override"));
                    v.setStockQuantity((Integer) rs.getObject("stock_quantity"));
                    v.setActive(rs.getBoolean("is_active"));
                    Timestamp cAt = rs.getTimestamp("created_at");
                    Timestamp uAt = rs.getTimestamp("updated_at");
                    if (cAt != null) v.setCreatedAt(cAt.toLocalDateTime());
                    if (uAt != null) v.setUpdatedAt(uAt.toLocalDateTime());
                    variants.add(v);
                }
            }
        }
        return variants;
    }

    private void saveVariants(Connection con, Product p, boolean isInsert) throws SQLException {
        if (p.getVariants() == null) return;
        // simple approach: delete old (if update) then insert all
        if (!isInsert) {
            try (PreparedStatement del = con.prepareStatement("DELETE FROM product_variants WHERE product_id=?")) {
                del.setInt(1, p.getProductId());
                del.executeUpdate();
            }
        }
        final String ins = "INSERT INTO product_variants (product_id, size, sku, price_override, stock_quantity, is_active, created_at, updated_at) " +
                "VALUES (?,?,?,?,?,?, NOW(), NOW())";
        try (PreparedStatement ps = con.prepareStatement(ins)) {
            for (ProductVariant v : p.getVariants()) {
                int i = 1;
                ps.setInt(i++, p.getProductId());
                ps.setString(i++, v.getSize());
                if (v.getSku() == null || v.getSku().isBlank()) ps.setNull(i++, Types.VARCHAR); else ps.setString(i++, v.getSku());
                if (v.getPriceOverride() == null) ps.setNull(i++, Types.DECIMAL); else ps.setBigDecimal(i++, v.getPriceOverride());
                if (v.getStockQuantity() == null) ps.setNull(i++, Types.INTEGER); else ps.setInt(i++, v.getStockQuantity());
                ps.setBoolean(i++, Boolean.TRUE.equals(v.getActive()));
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private static Product.ProductType safeProductType(String s) {
        if (s == null)
            return null;
        try {
            return Product.ProductType.valueOf(s);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private static Product.ExperienceType safeExperienceType(String s) {
        if (s == null)
            return null;
        try {
            return Product.ExperienceType.valueOf(s);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
