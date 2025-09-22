package model.dao.impl;

import model.CartItem;
import model.dao.OrderDAO;
import utils.DatabaseConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class OrderDAOImpl implements OrderDAO {

    @Override
    public String createOrder(int userId,
                              List<CartItem> cart,
                              String shippingAddress,
                              String billingAddress,
                              String notes,
                              String paymentMethod) throws Exception {

        if (cart == null || cart.isEmpty()) throw new IllegalArgumentException("Carrello vuoto.");

        BigDecimal total = BigDecimal.ZERO;
        for (CartItem it : cart) total = total.add(it.getTotal());

        String orderNumber = "RB-" + System.currentTimeMillis();

        try (Connection con = DatabaseConnection.getInstance().getConnection()) {
            con.setAutoCommit(false);

            int orderId;

            // Header ordine
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

            // Righe ordine (snapshot prezzo/nome + dettagli esperienza se presenti)
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

            // Aggiorna capacità slot (se presenti)
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

            // Aggiorna stock per MERCHANDISE
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
        }
    }

    @Override
    public List<Map<String, Object>> adminList(LocalDate from, LocalDate to, Integer userId) throws Exception {
        StringBuilder sql = new StringBuilder("""
            SELECT o.order_id,
                   o.order_number,
                   o.user_id,
                   CONCAT(u.first_name, ' ', u.last_name) AS customer_name,
                   o.total_amount,
                   o.status,
                   o.payment_status,
                   o.payment_method,
                   o.order_date
            FROM orders o
            LEFT JOIN users u ON u.user_id = o.user_id
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();

        if (from != null) {
            sql.append(" AND o.order_date >= ? ");
            params.add(Timestamp.valueOf(from.atStartOfDay()));
        }
        if (to != null) {
            sql.append(" AND o.order_date < ? ");
            params.add(Timestamp.valueOf(to.plusDays(1).atStartOfDay())); // half-open range
        }
        if (userId != null) {
            sql.append(" AND o.user_id = ? ");
            params.add(userId);
        }

        sql.append(" ORDER BY o.order_date DESC ");

        List<Map<String, Object>> rows = new ArrayList<>();
        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("order_id", rs.getInt("order_id"));
                    m.put("order_number", rs.getString("order_number"));
                    m.put("user_id", rs.getInt("user_id"));
                    m.put("customer_name", rs.getString("customer_name"));
                    m.put("total_amount", rs.getBigDecimal("total_amount"));
                    m.put("status", rs.getString("status"));
                    m.put("payment_status", rs.getString("payment_status"));
                    m.put("payment_method", rs.getString("payment_method"));
                    m.put("order_date", rs.getTimestamp("order_date"));
                    rows.add(m);
                }
            }
        }
        return rows;
    }

    // ========= NUOVI METODI per Admin / Paginazione / Filtri =========

    @Override
    public List<Map<String, Object>> findOrdersAdmin(
            java.sql.Date from,
            java.sql.Date to,
            String customerQuery,
            String status,
            int offset,
            int limit
    ) throws Exception {

        StringBuilder sql = new StringBuilder(
            "SELECT o.order_id, o.order_number, o.total_amount, o.status, o.payment_status, " +
            "DATE_FORMAT(o.order_date, '%Y-%m-%d %H:%i') AS order_date, " +
            "CONCAT(u.first_name, ' ', u.last_name, ' <', u.email, '>') AS customer " +
            "FROM orders o JOIN users u ON o.user_id = u.user_id WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (from != null) { sql.append(" AND DATE(o.order_date) >= ?"); params.add(from); }
        if (to   != null) { sql.append(" AND DATE(o.order_date) <= ?"); params.add(to); }

        if (customerQuery != null && !customerQuery.isBlank()) {
            sql.append(" AND (u.email LIKE ? OR u.first_name LIKE ? OR u.last_name LIKE ?)");
            String like = "%" + customerQuery + "%";
            params.add(like); params.add(like); params.add(like);
        }

        if (status != null && !status.isBlank()) {
            sql.append(" AND o.status = ?");
            params.add(status.toUpperCase());
        }

        sql.append(" ORDER BY o.order_date DESC LIMIT ? OFFSET ?");
        params.add(limit <= 0 ? 20 : limit);
        params.add(Math.max(0, offset));

        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof java.sql.Date) ps.setDate(i+1, (java.sql.Date) p);
                else if (p instanceof Integer)  ps.setInt(i+1, (Integer) p);
                else                            ps.setString(i+1, String.valueOf(p));
            }

            List<Map<String,Object>> out = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new HashMap<>();
                    row.put("order_id",       rs.getInt("order_id"));
                    row.put("order_number",   rs.getString("order_number"));
                    row.put("order_date",     rs.getString("order_date"));
                    row.put("customer",       rs.getString("customer"));
                    row.put("total_amount",   rs.getBigDecimal("total_amount"));
                    row.put("status",         rs.getString("status"));
                    row.put("payment_status", rs.getString("payment_status"));
                    out.add(row);
                }
            }
            return out;
        }
    }

    @Override
    public int countOrdersAdmin(
            java.sql.Date from,
            java.sql.Date to,
            String customerQuery,
            String status
    ) throws Exception {

        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM orders o JOIN users u ON o.user_id = u.user_id WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();

        if (from != null) { sql.append(" AND DATE(o.order_date) >= ?"); params.add(from); }
        if (to   != null) { sql.append(" AND DATE(o.order_date) <= ?"); params.add(to); }

        if (customerQuery != null && !customerQuery.isBlank()) {
            sql.append(" AND (u.email LIKE ? OR u.first_name LIKE ? OR u.last_name LIKE ?)");
            String like = "%" + customerQuery + "%";
            params.add(like); params.add(like); params.add(like);
        }

        if (status != null && !status.isBlank()) {
            sql.append(" AND o.status = ?");
            params.add(status.toUpperCase());
        }

        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof java.sql.Date) ps.setDate(i+1, (java.sql.Date) p);
                else                            ps.setString(i+1, String.valueOf(p));
            }

            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }
}