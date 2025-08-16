package model.dao.impl;

import model.CartItem;
import model.dao.CartDAO;
import utils.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAOImpl implements CartDAO {

    @Override
    public void upsertItem(int userId, int productId, Integer slotId, int quantity) throws Exception {
        String sql = """
            INSERT INTO cart (user_id, product_id, slot_id, quantity)
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity), updated_at = CURRENT_TIMESTAMP
        """;
        try (Connection c = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            if (slotId == null) ps.setNull(3, Types.INTEGER); else ps.setInt(3, slotId);
            ps.setInt(4, quantity);
            ps.executeUpdate();
        }
    }

    @Override
    public void removeItem(int userId, int productId, Integer slotId) throws Exception {
        String sql = "DELETE FROM cart WHERE user_id=? AND product_id=? AND ((slot_id IS NULL AND ? IS NULL) OR slot_id=?)";
        try (Connection c = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            if (slotId == null) { ps.setNull(3, Types.INTEGER); ps.setNull(4, Types.INTEGER); }
            else { ps.setInt(3, slotId); ps.setInt(4, slotId); }
            ps.executeUpdate();
        }
    }

    @Override
    public void clearCart(int userId) throws Exception {
        try (Connection c = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = c.prepareStatement("DELETE FROM cart WHERE user_id=?")) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    @Override
    public List<CartItem> findByUser(int userId) throws Exception {
        String sql = """
            SELECT c.product_id, c.slot_id, c.quantity,
                   p.name, p.image_url, p.price, p.product_type
            FROM cart c
            JOIN products p ON p.product_id = c.product_id
            WHERE c.user_id=?
        """;
        List<CartItem> items = new ArrayList<>();
        try (Connection c = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem it = new CartItem(
                        rs.getInt("product_id"),
                        (Integer) (rs.getObject("slot_id") == null ? null : rs.getInt("slot_id")),
                        rs.getString("name"),
                        rs.getString("image_url"),
                        rs.getBigDecimal("price"),
                        rs.getInt("quantity"),
                        rs.getString("product_type")
                    );
                    items.add(it);
                }
            }
        }
        return items;
    }

    @Override
    public void updateQuantity(int userId, int productId, Integer slotId, int quantity) throws Exception {
        String sql = "UPDATE cart SET quantity=?, updated_at=CURRENT_TIMESTAMP WHERE user_id=? AND product_id=? AND ((slot_id IS NULL AND ? IS NULL) OR slot_id=?)";
        try (Connection c = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, userId);
            ps.setInt(3, productId);
            if (slotId == null) { ps.setNull(4, Types.INTEGER); ps.setNull(5, Types.INTEGER); }
            else { ps.setInt(4, slotId); ps.setInt(5, slotId); }
            ps.executeUpdate();
        }
    }
}
