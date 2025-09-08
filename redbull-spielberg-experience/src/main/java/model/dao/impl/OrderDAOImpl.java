package model.dao.impl;

import model.CartItem;
import model.dao.OrderDAO;
import utils.DatabaseConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.Instant;
import java.util.List;

public class OrderDAOImpl implements OrderDAO {

    @Override
    public String createOrder(int userId, List<CartItem> items, String shipping, String billing, String notes, String payment) throws Exception {
        if (items == null || items.isEmpty()) throw new IllegalArgumentException("Carrello vuoto.");

        String orderNumber = "RB-" + Instant.now().toEpochMilli();

        String insertOrderSql = """
            INSERT INTO orders (user_id, order_number, total_amount, status, payment_status, payment_method, shipping_address, billing_address, notes)
            VALUES (?, ?, ?, 'PENDING', 'PENDING', ?, ?, ?, ?)
        """;

        String insertItemSql = """
            INSERT INTO order_items (order_id, product_id, slot_id, quantity, unit_price, total_price, product_name)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """;

        try (Connection con = DatabaseConnection.getInstance().getConnection()) {
            con.setAutoCommit(false);

            // totale
            BigDecimal total = BigDecimal.ZERO;
            for (CartItem it : items) {
                total = total.add(it.getTotal());
            }

            // crea ordine
            long orderId;
            try (PreparedStatement ps = con.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, userId);
                ps.setString(2, orderNumber);
                ps.setBigDecimal(3, total);
                ps.setString(4, payment);
                ps.setString(5, shipping);
                ps.setString(6, billing);
                ps.setString(7, notes);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (!rs.next()) throw new SQLException("Impossibile ottenere order_id.");
                    orderId = rs.getLong(1);
                }
            }

            // per ogni item
            for (CartItem it : items) {
                BigDecimal lineTotal = it.getTotal();

                // inserisci riga ordine
                try (PreparedStatement ps = con.prepareStatement(insertItemSql)) {
                    ps.setLong(1, orderId);
                    ps.setInt(2, it.getProductId());
                    if (it.getSlotId() == null) ps.setNull(3, Types.INTEGER); else ps.setInt(3, it.getSlotId());
                    ps.setInt(4, it.getQuantity());
                    ps.setBigDecimal(5, it.getUnitPrice());
                    ps.setBigDecimal(6, lineTotal);
                    ps.setString(7, it.getProductName());
                    ps.executeUpdate();
                }

                // gestisci stock MERCHANDISE
                if ("MERCHANDISE".equalsIgnoreCase(it.getProductType())) {
                    String decStock = """
                        UPDATE products SET stock_quantity = stock_quantity - ?
                        WHERE product_id = ? AND product_type='MERCHANDISE' AND stock_quantity >= ?
                    """;
                    try (PreparedStatement ps = con.prepareStatement(decStock)) {
                        ps.setInt(1, it.getQuantity());
                        ps.setInt(2, it.getProductId());
                        ps.setInt(3, it.getQuantity());
                        int affected = ps.executeUpdate();
                        if (affected == 0) {
                            con.rollback();
                            throw new IllegalStateException("Stock insufficiente per: " + it.getProductName());
                        }
                    }
                }

                // gestisci slot EXPERIENCE (se presente slot_id)
                if (it.getSlotId() != null) {
                    String book = """
                        UPDATE time_slots
                        SET booked_capacity = booked_capacity + ?
                        WHERE slot_id = ?
                          AND is_available = 1
                          AND (booked_capacity + ?) <= max_capacity
                    """;
                    try (PreparedStatement ps = con.prepareStatement(book)) {
                        ps.setInt(1, it.getQuantity());
                        ps.setInt(2, it.getSlotId());
                        ps.setInt(3, it.getQuantity());
                        int affected = ps.executeUpdate();
                        if (affected == 0) {
                            con.rollback();
                            throw new IllegalStateException("Lo slot selezionato non è più disponibile.");
                        }
                    }
                }
            }

            con.commit();
            return orderNumber;

        } catch (Exception ex) {
            throw ex;
        }
    }
}