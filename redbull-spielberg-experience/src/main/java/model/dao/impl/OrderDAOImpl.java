package model.dao.impl;

import model.CartItem;
import model.dao.OrderDAO;
import utils.DatabaseConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;

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

            // Righe ordine (snapshot + dettagli esperienza)
            String insItem = """
                INSERT INTO order_items
                  (order_id, product_id, slot_id, quantity, unit_price, total_price, product_name,
                   driver_name, driver_number, companion_name, vehicle_code, event_date)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
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
                    ps.setString(9, it.getDriverNumber());
                    ps.setString(10, it.getCompanionName());
                    ps.setString(11, it.getVehicleCode());
                    if (it.getEventDate() != null) {
                        ps.setDate(12, java.sql.Date.valueOf(it.getEventDate()));
                    } else {
                        ps.setNull(12, Types.DATE);
                    }
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            // Aggiorna capacità slot (se presenti) -> + quantità per riga
            String updSlot = """
               UPDATE time_slots
               SET booked_capacity = LEAST(max_capacity, booked_capacity + ?),
                   is_available = CASE WHEN (booked_capacity + ?) >= max_capacity THEN 0 ELSE 1 END
               WHERE slot_id = ?
            """;
            try (PreparedStatement ps = con.prepareStatement(updSlot)) {
                for (CartItem it : cart) {
                    if (it.getSlotId() != null) {
                        int q = Math.max(1, it.getQuantity());
                        ps.setInt(1, q);
                        ps.setInt(2, q);
                        ps.setInt(3, it.getSlotId());
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
                        ps.setInt(1, Math.max(1, it.getQuantity()));
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
            params.add(Timestamp.valueOf(to.plusDays(1).atStartOfDay()));
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

    // ========= LISTE ADMIN con filtri/paginazione =========

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
            "SELECT o.order_id, o.order_number, o.total_amount, o.status, o.payment_status, o.payment_method, " +
            "o.order_date, " +
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
                    row.put("order_id",        rs.getInt("order_id"));
                    row.put("order_number",    rs.getString("order_number"));
                    row.put("order_date",      rs.getTimestamp("order_date"));
                    row.put("customer",        rs.getString("customer"));
                    row.put("total_amount",    rs.getBigDecimal("total_amount"));
                    row.put("status",          rs.getString("status"));
                    row.put("payment_status",  rs.getString("payment_status"));
                    row.put("payment_method",  rs.getString("payment_method"));
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

    // ========= DETTAGLIO ORDINE & AZIONI ADMIN =========

    /** Header singolo ordine. */
    @Override
    public Map<String, Object> findOrderHeader(int orderId) throws Exception {
        String sql = """
            SELECT
              o.order_id,
              o.user_id,
              o.order_number,
              o.total_amount,
              o.status,
              o.payment_status,
              o.payment_method,
              o.carrier,
              o.tracking_code,
              o.shipping_address,
              o.billing_address,
              o.notes,
              o.order_date,
              o.estimated_delivery,
              o.shipped_at,
              u.first_name AS buyer_first_name,
              u.last_name  AS buyer_last_name,
              u.email      AS buyer_email,
              u.phone_number AS buyer_phone
            FROM orders o
            JOIN users u ON u.user_id = o.user_id
            WHERE o.order_id = ?
        """;

        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Map<String,Object> m = new HashMap<>();
                m.put("order_id",           rs.getInt("order_id"));
                m.put("user_id",            rs.getInt("user_id"));
                m.put("order_number",       rs.getString("order_number"));
                m.put("total_amount",       rs.getBigDecimal("total_amount"));
                m.put("status",             rs.getString("status"));
                m.put("payment_status",     rs.getString("payment_status"));
                m.put("payment_method",     rs.getString("payment_method"));
                m.put("carrier",            rs.getString("carrier"));
                m.put("tracking_code",      rs.getString("tracking_code"));
                m.put("shipping_address",   rs.getString("shipping_address"));
                m.put("billing_address",    rs.getString("billing_address"));
                m.put("notes",              rs.getString("notes"));
                m.put("order_date",         rs.getTimestamp("order_date"));
                m.put("estimated_delivery", rs.getDate("estimated_delivery"));
                m.put("shipped_at",         rs.getTimestamp("shipped_at"));
                // "delivered_at" opzionale
                m.put("buyer_first_name",   rs.getString("buyer_first_name"));
                m.put("buyer_last_name",    rs.getString("buyer_last_name"));
                m.put("buyer_email",        rs.getString("buyer_email"));
                m.put("buyer_phone",        rs.getString("buyer_phone"));
                return m;
            }
        }
    }

    /** Articoli ordine. */
    @Override
    public List<Map<String,Object>> findOrderItems(int orderId) throws Exception {
        String sql = """
            SELECT
              oi.item_id AS order_item_id,
              oi.product_id,
              oi.product_name,
              oi.quantity,
              oi.unit_price,
              oi.total_price,
              oi.driver_name,
              oi.driver_number,
              oi.companion_name,
              oi.vehicle_code,
              oi.event_date,
              p.image_url
            FROM order_items oi
            LEFT JOIN products p ON p.product_id = oi.product_id
            WHERE oi.order_id = ?
            ORDER BY oi.item_id ASC
        """;

        List<Map<String,Object>> list = new ArrayList<>();
        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> r = new HashMap<>();
                    r.put("order_item_id",   rs.getInt("order_item_id"));
                    r.put("product_id",      rs.getInt("product_id"));
                    r.put("product_name",    rs.getString("product_name"));
                    r.put("quantity",        rs.getInt("quantity"));
                    r.put("unit_price",      rs.getBigDecimal("unit_price"));
                    r.put("total_price",     rs.getBigDecimal("total_price"));
                    r.put("driver_name",     rs.getString("driver_name"));
                    r.put("driver_number",   rs.getString("driver_number"));
                    r.put("companion_name",  rs.getString("companion_name"));
                    r.put("vehicle_code",    rs.getString("vehicle_code"));
                    r.put("event_date",      rs.getDate("event_date"));
                    r.put("image_url",       rs.getString("image_url"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    /** Aggiorna tracking; valorizza shipped_at se non presente. */
    @Override
    public boolean updateTracking(int orderId, String carrier, String trackingCode) throws Exception {
        String sql = """
            UPDATE orders
               SET carrier = ?, tracking_code = ?,
                   shipped_at = COALESCE(shipped_at, NOW())
             WHERE order_id = ?
        """;
        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, carrier);
            ps.setString(2, trackingCode);
            ps.setInt(3, orderId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Segna ordine come COMPLETED; se 'delivered_at' non esiste, fallback. */
    @Override
    public boolean markCompleted(int orderId) throws Exception {
        String sqlWithDelivered = """
            UPDATE orders
               SET status = 'COMPLETED',
                   delivered_at = COALESCE(delivered_at, NOW())
             WHERE order_id = ?
               AND status <> 'CANCELLED'
        """;
        String sqlWithoutDelivered = "UPDATE orders SET status='COMPLETED' WHERE order_id=? AND status <> 'CANCELLED'";

        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sqlWithDelivered)) {
            ps.setInt(1, orderId);
            int n = ps.executeUpdate();
            return n > 0;
        } catch (java.sql.SQLSyntaxErrorException e) {
            try (Connection con = DatabaseConnection.getInstance().getConnection();
                 PreparedStatement ps2 = con.prepareStatement(sqlWithoutDelivered)) {
                ps2.setInt(1, orderId);
                return ps2.executeUpdate() > 0;
            }
        }
    }

    /** Annulla ordine: ripristina stock MERCHANDISE, libera capacità slot in base a SUM(quantità), imposta stato CANCELLED. */
    @Override
    public boolean cancelOrder(int orderId) throws Exception {
        Connection con = DatabaseConnection.getInstance().getConnection();
        boolean success = false;
        try {
            con.setAutoCommit(false);

            // 1) Blocco riga ordine e verifica stato / spedizione
            String checkSql = "SELECT status, shipped_at FROM orders WHERE order_id=? FOR UPDATE";
            String status = null;
            Timestamp shippedAt = null;
            try (PreparedStatement ps = con.prepareStatement(checkSql)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        status = rs.getString("status");
                        shippedAt = rs.getTimestamp("shipped_at");
                    }
                }
            }
            if (status == null) { con.rollback(); return false; }
            if ("CANCELLED".equalsIgnoreCase(status) || "COMPLETED".equalsIgnoreCase(status) || shippedAt != null) {
                con.rollback();
                return false;
            }

            // 2) Ripristina stock per MERCHANDISE
            String restockSql = """
                UPDATE products p
                JOIN order_items oi ON oi.product_id = p.product_id
                SET p.stock_quantity = p.stock_quantity + oi.quantity
                WHERE oi.order_id = ? AND p.product_type = 'MERCHANDISE'
            """;
            try (PreparedStatement ps = con.prepareStatement(restockSql)) {
                ps.setInt(1, orderId);
                ps.executeUpdate();
            }

            // 3) Libera capacità slot in base alla somma delle quantità
            String slotCountsSql = """
                SELECT slot_id, SUM(quantity) AS qty
                FROM order_items
                WHERE order_id=? AND slot_id IS NOT NULL
                GROUP BY slot_id
            """;
            try (PreparedStatement ps = con.prepareStatement(slotCountsSql)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    String updSlot = """
                        UPDATE time_slots
                        SET booked_capacity = GREATEST(0, booked_capacity - ?),
                            is_available   = CASE WHEN (booked_capacity - ?) < max_capacity THEN 1 ELSE 0 END
                        WHERE slot_id = ?
                    """;
                    try (PreparedStatement up = con.prepareStatement(updSlot)) {
                        while (rs.next()) {
                            int slotId = rs.getInt("slot_id");
                            int qty    = Math.max(1, rs.getInt("qty"));
                            up.setInt(1, qty);
                            up.setInt(2, qty);
                            up.setInt(3, slotId);
                            up.addBatch();
                        }
                        up.executeBatch();
                    }
                }
            }

            // 4) Stato ordine -> CANCELLED
            int updated;
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE orders SET status='CANCELLED' WHERE order_id=?")) {
                ps.setInt(1, orderId);
                updated = ps.executeUpdate();
            }

            con.commit();
            success = updated > 0;
            return success;
        } catch (Exception ex) {
            try { if (con != null) con.rollback(); } catch (Exception ignore) {}
            throw ex;
        } finally {
            try { if (con != null) con.close(); } catch (Exception ignore) {}
        }
    }
}

