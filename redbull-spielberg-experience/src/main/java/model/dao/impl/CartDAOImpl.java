package model.dao.impl;

import model.CartItem;
import model.dao.CartDAO;
import utils.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Implementazione del CartDAO.
 * Supporta sia l'uso con Connection esterna (transazioni manuali)
 * sia l'uso "standalone" (apre/chiude la connessione per ogni metodo).
 */
public class CartDAOImpl implements CartDAO {

    private final Connection externalCon; // può essere null

    public CartDAOImpl() {
        this.externalCon = null;
    }

    public CartDAOImpl(Connection con) {
        this.externalCon = con;
    }

    // Esegue la lambda usando la connection esterna se presente, altrimenti ne apre una nuova
    private interface SQLRun<T> { T run(Connection c) throws Exception; }
    private <T> T withCon(SQLRun<T> block) throws Exception {
        if (externalCon != null) {
            return block.run(externalCon);
        }
        try (Connection c = DatabaseConnection.getInstance().getConnection()) {
            return block.run(c);
        }
    }

    @Override
    public void upsertItem(int userId, int productId, Integer slotId, int quantity) throws Exception {
        final String sql = """
            INSERT INTO cart (user_id, product_id, slot_id, quantity)
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                quantity = quantity + VALUES(quantity),
                updated_at = CURRENT_TIMESTAMP
        """;
        withCon(c -> {
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, productId);
                if (slotId == null) ps.setNull(3, Types.INTEGER); else ps.setInt(3, slotId);
                ps.setInt(4, Math.max(1, quantity));
                ps.executeUpdate();
            }
            return null;
        });
    }

    @Override
    public void removeItem(int userId, int productId, Integer slotId) throws Exception {
        final String sql = "DELETE FROM cart WHERE user_id=? AND product_id=? AND " +
                (slotId == null ? "slot_id IS NULL" : "slot_id=?");
        withCon(c -> {
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                int i = 1;
                ps.setInt(i++, userId);
                ps.setInt(i++, productId);
                if (slotId != null) ps.setInt(i++, slotId);
                ps.executeUpdate();
            }
            return null;
        });
    }

    @Override
    public void clearCart(int userId) throws Exception {
        withCon(c -> {
            try (PreparedStatement ps = c.prepareStatement("DELETE FROM cart WHERE user_id=?")) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
            return null;
        });
    }

    @Override
    public List<CartItem> findByUser(int userId) throws Exception {
        final String sql = """
            SELECT c.product_id, c.slot_id, c.quantity,
                   p.name, p.image_url, p.price, p.product_type
            FROM cart c
            JOIN products p ON p.product_id = c.product_id
            WHERE c.user_id=?
        """;
        return withCon(c -> {
            List<CartItem> items = new ArrayList<>();
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Integer slotId = (rs.getObject("slot_id") == null) ? null : rs.getInt("slot_id");
                        CartItem it = new CartItem(
                            rs.getInt("product_id"),
                            slotId,
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
        });
    }

    @Override
    public void updateQuantity(int userId, int productId, Integer slotId, int quantity) throws Exception {
        if (quantity <= 0) {
            removeItem(userId, productId, slotId);
            return;
        }
        final String sql = "UPDATE cart SET quantity=?, updated_at=CURRENT_TIMESTAMP " +
                "WHERE user_id=? AND product_id=? AND " +
                (slotId == null ? "slot_id IS NULL" : "slot_id=?");
        withCon(c -> {
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                int i = 1;
                ps.setInt(i++, Math.max(1, quantity));
                ps.setInt(i++, userId);
                ps.setInt(i++, productId);
                if (slotId != null) ps.setInt(i++, slotId);
                ps.executeUpdate();
            }
            return null;
        });
    }
}