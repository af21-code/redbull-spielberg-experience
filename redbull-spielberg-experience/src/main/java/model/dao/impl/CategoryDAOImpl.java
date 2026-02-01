package model.dao.impl;

import model.Category;
import model.dao.CategoryDAO;
import utils.DatabaseConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAOImpl implements CategoryDAO {

    private interface SQLRun<T> { T run(Connection c) throws Exception; }
    private <T> T withCon(SQLRun<T> block) {
        try (Connection c = DatabaseConnection.getInstance().getConnection()) {
            return block.run(c);
        } catch (Exception e) {
            if (e instanceof RuntimeException) throw (RuntimeException) e;
            throw new RuntimeException(e);
        }
    }

    private Category mapRow(ResultSet rs) throws SQLException {
        int id = rs.getInt("category_id");
        String name = rs.getString("name");
        String description = rs.getString("description");
        boolean isActive = rs.getBoolean("is_active");
        Timestamp ts = rs.getTimestamp("created_at");
        LocalDateTime createdAt = (ts != null) ? ts.toLocalDateTime() : null;

        return new Category(id, name, description, isActive, createdAt);
    }

    @Override
    public List<Category> findAllActive() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM categories WHERE is_active = 1 ORDER BY name ASC";
        System.out.println("[CategoryDAO] Executing findAllActive query: " + sql);
        withCon(c -> {
            try (PreparedStatement ps = c.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Category cat = mapRow(rs);
                    System.out.println("[CategoryDAO] Found category: " + cat.getCategoryId() + " - " + cat.getName());
                    list.add(cat);
                }
                System.out.println("[CategoryDAO] Total categories found: " + list.size());
            }
            return null;
        });
        return list;
    }

    @Override
    public List<Category> adminFindAllPaged(String q, Boolean onlyInactive, String sort, String dir, int limit,
            int offset) {
        List<Category> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("SELECT * FROM categories WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sql.append("AND (name LIKE ? OR description LIKE ?) ");
            params.add("%" + q + "%");
            params.add("%" + q + "%");
        }

        if (onlyInactive != null) {
            if (onlyInactive) {
                sql.append("AND is_active = 0 ");
            } else {
                // If checking "onlyActive", we would use is_active = 1.
                // The parameter is "onlyInactive", usually if true -> show inactive.
                // If false (or null), usually we ignore filter or show all?
                // Based on typically logic:
                // If "onlyInactive" is TRUE, show ONLY inactive.
                // If "onlyInactive" is FALSE, show ALL? Or show only active?
                // Let's assume common behavior: filter only if necessary.
                // Re-reading logic in ProductDAO typically: usually it's a filter toggle.
            }
        }

        // Sort
        // Whitelist columns
        String orderBy = "name";
        if (sort != null && (sort.equals("category_id") || sort.equals("name") || sort.equals("created_at")
                || sort.equals("is_active"))) {
            orderBy = sort;
        }
        String orderDir = "ASC";
        if ("DESC".equalsIgnoreCase(dir)) {
            orderDir = "DESC";
        }
        sql.append("ORDER BY ").append(orderBy).append(" ").append(orderDir).append(" ");

        sql.append("LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        withCon(c -> {
            try (PreparedStatement ps = c.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapRow(rs));
                    }
                }
            }
            return null;
        });

        return list;
    }

    @Override
    public Category adminFindById(int id) {
        String sql = "SELECT * FROM categories WHERE category_id = ?";
        return withCon(c -> {
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapRow(rs);
                    }
                }
            }
            return null;
        });
    }

    @Override
    public void insert(Category category) {
        String sql = "INSERT INTO categories (name, description, is_active) VALUES (?, ?, ?)";
        withCon(c -> {
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setString(1, category.getName());
                ps.setString(2, category.getDescription());
                ps.setBoolean(3, category.isActive());
                ps.executeUpdate();
            }
            return null;
        });
    }

    @Override
    public void update(Category category) {
        String sql = "UPDATE categories SET name = ?, description = ?, is_active = ? WHERE category_id = ?";
        withCon(c -> {
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setString(1, category.getName());
                ps.setString(2, category.getDescription());
                ps.setBoolean(3, category.isActive());
                ps.setInt(4, category.getCategoryId());
                ps.executeUpdate();
            }
            return null;
        });
    }
}
