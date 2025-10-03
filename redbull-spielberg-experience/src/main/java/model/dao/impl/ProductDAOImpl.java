package model.dao.impl;

import model.Product;
import model.dao.ProductDAO;
import utils.DatabaseConnection;

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
            if (categoryId != null) ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) results.add(mapRow(rs));
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
                if (rs.next()) return mapRow(rs);
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
            if (categoryId != null) ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) results.add(mapRow(rs));
            }
        }
        return results;
    }

    // ========= Admin (lista legacy senza paging) =========
    @Override
    public List<Product> adminFindAll(Integer categoryId, String q, Boolean onlyInactive) throws Exception {
        StringBuilder sb = new StringBuilder(BASE_SELECT).append(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        appendFilters(sb, params, categoryId, q, onlyInactive);
        // Prima i record aggiornati di recente; quelli senza updated_at in coda
        sb.append(" ORDER BY (updated_at IS NULL), updated_at DESC, created_at DESC ");

        List<Product> results = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sb.toString())) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) results.add(mapRow(rs));
            }
        }
        return results;
    }

    @Override
    public Product adminFindById(int productId) throws Exception {
        String sql = BASE_SELECT + " WHERE product_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
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
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        throw new SQLException("Insert product failed: no ID obtained.");
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

    // ========= Admin: paginazione + ordinamento =========
    @Override
    public int adminCountAll(Integer categoryId, String q, Boolean onlyInactive) throws Exception {
        StringBuilder sb = new StringBuilder("SELECT COUNT(*) FROM products WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        appendFilters(sb, params, categoryId, q, onlyInactive);

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sb.toString())) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    @Override
    public List<Product> adminFindAllPaged(Integer categoryId, String q, Boolean onlyInactive,
                                           String sortBy, String sortDir,
                                           int offset, int limit) throws Exception {

        String orderBy = toSafeOrderBy(sortBy, sortDir);

        StringBuilder sb = new StringBuilder(BASE_SELECT).append(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        appendFilters(sb, params, categoryId, q, onlyInactive);

        sb.append(" ").append(orderBy).append(" LIMIT ? OFFSET ? ");

        List<Product> results = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sb.toString())) {
            int i = bindParams(ps, params);
            ps.setInt(i++, limit);
            ps.setInt(i, Math.max(0, offset));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) results.add(mapRow(rs));
            }
        }
        return results;
    }

    // ========= Helpers SQL =========
    private static void appendFilters(StringBuilder sb, List<Object> params,
                                      Integer categoryId, String q, Boolean onlyInactive) {
        if (categoryId != null) {
            sb.append(" AND category_id = ? ");
            params.add(categoryId);
        }
        if (q != null && !q.isBlank()) {
            sb.append(" AND LOWER(name) LIKE ? ");
            params.add("%" + q.toLowerCase().trim() + "%");
        }
        if (onlyInactive != null && onlyInactive) {
            sb.append(" AND is_active = 0 ");
        }
    }

    /** Restituisce l'ORDER BY con colonne whiteliste per evitare SQL injection. */
    private static String toSafeOrderBy(String sortBy, String sortDir) {
        String col;
        if (sortBy == null) col = "updated_at";
        else {
            switch (sortBy) {
                case "product_id":
                case "name":
                case "price":
                case "created_at":
                case "updated_at":
                case "is_active":
                case "is_featured":
                case "stock_quantity":
                    col = sortBy;
                    break;
                default:
                    col = "updated_at";
            }
        }
        String dir = "DESC";
        if (sortDir != null && sortDir.equalsIgnoreCase("asc")) dir = "ASC";
        return "ORDER BY " + col + " " + dir + ", product_id " + dir;
    }

    /** Bind in ordine tutti i parametri della lista; ritorna il prossimo indice libero. */
    private static int bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        int i = 1;
        for (Object p : params) {
            ps.setObject(i++, p);
        }
        return i;
    }

    // ========= Helpers mappatura =========
    private int bindUpsert(PreparedStatement ps, Product p) throws SQLException {
        int i = 1;
        // category_id
        if (p.getCategoryId() == null) ps.setNull(i++, Types.INTEGER); else ps.setInt(i++, p.getCategoryId());

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
        if (p.getStockQuantity() == null) ps.setNull(i++, Types.INTEGER); else ps.setInt(i++, p.getStockQuantity());

        ps.setString(i++, p.getImageUrl());

        // featured / active
        ps.setBoolean(i++, Boolean.TRUE.equals(p.getFeatured()));
        ps.setBoolean(i++, Boolean.TRUE.equals(p.getActive()));

        return i; // prossimo indice libero (serve per UPDATE)
    }

    private Product mapRow(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getInt("product_id"));
        p.setCategoryId((Integer) rs.getObject("category_id"));
        p.setName(rs.getString("name"));
        p.setDescription(rs.getString("description"));
        p.setShortDescription(rs.getString("short_description"));
        p.setPrice(rs.getBigDecimal("price"));

        // enum safe
        p.setProductType(safeProductType(rs.getString("product_type")));
        p.setExperienceType(safeExperienceType(rs.getString("experience_type")));

        Integer stock = (Integer) rs.getObject("stock_quantity");
        p.setStockQuantity(stock);

        p.setImageUrl(rs.getString("image_url"));
        p.setFeatured(rs.getBoolean("is_featured"));
        p.setActive(rs.getBoolean("is_active"));

        Timestamp cAt = rs.getTimestamp("created_at");
        Timestamp uAt = rs.getTimestamp("updated_at");
        if (cAt != null) p.setCreatedAt(cAt.toLocalDateTime());
        if (uAt != null) p.setUpdatedAt(uAt.toLocalDateTime());
        return p;
    }

    private static Product.ProductType safeProductType(String s) {
        if (s == null) return null;
        try { return Product.ProductType.valueOf(s); }
        catch (IllegalArgumentException e) { return null; }
    }

    private static Product.ExperienceType safeExperienceType(String s) {
        if (s == null) return null;
        try { return Product.ExperienceType.valueOf(s); }
        catch (IllegalArgumentException e) { return null; }
    }
}