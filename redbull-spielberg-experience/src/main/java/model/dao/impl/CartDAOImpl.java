package model.dao.impl;

import model.CartItem;
import model.dao.CartDAO;
import utils.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAOImpl implements CartDAO {

    @Override
    public void addOrIncrement(int userId, int productId, Integer slotId, int quantity) throws Exception {
        String sql = """
            INSERT INTO cart (user_id, product_id, slot_id, quantity)
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity), updated_at = CURRENT_TIMESTAMP
            """;
        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            if (slotId == null) ps.setNull(3, Types.INTEGER); else ps.setInt(3, slotId);
            ps.setInt(4, quantity);
            ps.executeUpdate();
        }
    }

    @Override
    public void updateQuantity(int userId, int productId, Integer slotId, int quantity) throws Exception {
        if (quantity <= 0) {
            removeItem(userId, productId, slotId);
            return;
        }
        String sql = """
            UPDATE cart
               SET quantity = ?, updated_at = CURRENT_TIMESTAMP
             WHERE user_id = ? AND product_id = ? AND
                   ((slot_id IS NULL AND ? IS NULL) OR (slot_id = ?))
            """;
        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, userId);
            ps.setInt(3, productId);
            if (slotId == null) { ps.setNull(4, Types.INTEGER); ps.setNull(5, Types.INTEGER); }
            else { ps.setInt(4, slotId); ps.setInt(5, slotId); }
            ps.executeUpdate();
        }
    }

    @Override
    public void removeItem(int userId, int productId, Integer slotId) throws Exception {
        String sql = """
            DELETE FROM cart
             WHERE user_id = ? AND product_id = ? AND
                   ((slot_id IS NULL AND ? IS NULL) OR (slot_id = ?))
            """;
        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            if (slotId == null) { ps.setNull(3, Types.INTEGER); ps.setNull(4, Types.INTEGER); }
            else { ps.setInt(3, slotId); ps.setInt(4, slotId); }
            ps.executeUpdate();
        }
    }

    @Override
    public void clearCart(int userId) throws Exception {
        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM cart WHERE user_id = ?")) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    @Override
    public List<CartItem> findByUser(int userId) throws Exception {
        String sql = """
            SELECT c.product_id, c.slot_id, c.quantity,
                   p.name AS product_name, p.image_url, p.price
            FROM cart c
            JOIN products p ON p.product_id = c.product_id
            WHERE c.user_id = ?
            ORDER BY c.updated_at DESC, c.added_at DESC
            """;
        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                List<CartItem> list = new ArrayList<>();
                while (rs.next()) {
                    CartItem ci = new CartItem();
                    ci.setProductId(rs.getInt("product_id"));
                    Object slotObj = rs.getObject("slot_id");
                    ci.setSlotId(slotObj == null ? null : rs.getInt("slot_id"));
                    ci.setQuantity(rs.getInt("quantity"));
                    ci.setProductName(rs.getString("product_name"));
                    ci.setImageUrl(rs.getString("image_url"));
                    ci.setUnitPrice(rs.getBigDecimal("price"));
                    list.add(ci);
                }
                return list;
            }
        }
    }
}