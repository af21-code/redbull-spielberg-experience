package model.dao.impl;

import model.CartItem;
import model.dao.OrderDAO;
import utils.DatabaseConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.List;

public class OrderDAOImpl implements OrderDAO {

    @Override
    public String createOrder(int userId, List<CartItem> cart, String shippingAddress,
                              String billingAddress, String notes, String paymentMethod) throws Exception {

        if (cart == null || cart.isEmpty()) throw new IllegalArgumentException("Carrello vuoto.");

        BigDecimal total = BigDecimal.ZERO;
        for (CartItem it : cart) total = total.add(it.getTotal());

        String orderNumber = "RB-" + System.currentTimeMillis();

        try (Connection con = DatabaseConnection.getInstance().getConnection()) {
            con.setAutoCommit(false);

            int orderId;

            // Header
            String insOrder = """
                INSERT INTO orders
                  (user_id, order_number, total_amount, status, payment_status, payment_method,
                   shipping_address, billing_address, notes, order_date)
                VALUES (?,?,?,?,?,?,?,?,?,NOW())
            """;
            try (PreparedStatement ps = con.prepareStatement(insOrder, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, userId);
                ps.setString(2, orderNumber);
                ps.setBigDecimal(3, total);
                ps.setString(4, "CONFIRMED");
                ps.setString(5, "PAID");
                ps.setString(6, paymentMethod);
                ps.setString(7, shippingAddress);
                ps.setString(8, billingAddress);
                ps.setString(9, notes);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (!rs.next()) throw new SQLException("Generazione ID ordine fallita.");
                    orderId = rs.getInt(1);
                }
            }

            // Righe (snapshot prezzo/nome + dettagli esperienza)
            String insItem = """
                INSERT INTO order_items
                  (order_id, product_id, slot_id, quantity, unit_price, total_price, product_name,
                   driver_name, companion_name, vehicle_code, event_date)
                VALUES (?,?,?,?,?,?,?,?,?,?,?)
            """;
            try (PreparedStatement ps = con.prepareStatement(insItem)) {
                for (CartItem it : cart) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, it.getProductId());
                    if (it.getSlotId() == null) ps.setNull(3, Types.INTEGER); else ps.setInt(3, it.getSlotId());
                    ps.setInt(4, it.getQuantity());
                    ps.setBigDecimal(5, it.getUnitPrice());
                    ps.setBigDecimal(6, it.getTotal());
                    ps.setString(7, it.getProductName());
                    ps.setString(8, it.getDriverName());
                    ps.setString(9, it.getCompanionName());
                    ps.setString(10, it.getVehicleCode());
                    if (it.getEventDate() != null) ps.setDate(11, Date.valueOf(it.getEventDate())); else ps.setNull(11, Types.DATE);
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            // Update slot capacity (solo se presente uno slot_id)
            String updSlot = """
               UPDATE time_slots
               SET booked_capacity = booked_capacity + 1,
                   is_available = CASE WHEN (booked_capacity + 1) >= max_capacity THEN 0 ELSE 1 END
               WHERE slot_id = ?
            """;
            try (PreparedStatement ps = con.prepareStatement(updSlot)) {
                for (CartItem it : cart) {
                    if (it.getSlotId() != null) {
                        ps.setInt(1, it.getSlotId());
                        ps.addBatch();
                    }
                }
                ps.executeBatch();
            }

            // Update stock per MERCHANDISE
            String updStock = """
               UPDATE products
               SET stock_quantity = GREATEST(0, stock_quantity - ?)
               WHERE product_id = ? AND product_type = 'MERCHANDISE'
            """;
            try (PreparedStatement ps = con.prepareStatement(updStock)) {
                for (CartItem it : cart) {
                    if ("MERCHANDISE".equalsIgnoreCase(it.getProductType())) {
                        ps.setInt(1, it.getQuantity());
                        ps.setInt(2, it.getProductId());
                        ps.addBatch();
                    }
                }
                ps.executeBatch();
            }

            con.commit();
            return orderNumber;

        } catch (Exception e) {
            throw e;
        }
    }
}