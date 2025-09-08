package model.dao.impl;

import model.Order;
import model.OrderItem;
import model.dao.OrderQueryDAO;
import utils.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderQueryDAOImpl implements OrderQueryDAO {

    private Order mapOrder(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setOrderId(rs.getInt("order_id"));
        o.setOrderNumber(rs.getString("order_number"));
        o.setTotalAmount(rs.getBigDecimal("total_amount"));
        o.setStatus(rs.getString("status"));
        o.setPaymentStatus(rs.getString("payment_status"));
        o.setPaymentMethod(rs.getString("payment_method"));
        o.setCarrier(rs.getString("carrier"));
        o.setTrackingCode(rs.getString("tracking_code"));
        o.setShippedAt((Timestamp) rs.getObject("shipped_at"));
        o.setEstimatedDelivery((java.sql.Date) rs.getObject("estimated_delivery"));
        o.setOrderDate(rs.getTimestamp("order_date"));
        return o;
    }

    @Override
    public List<Order> findRecentByUser(int userId, int limit) throws Exception {
        String sql = """
            SELECT order_id, order_number, total_amount, status, payment_status, payment_method,
                   carrier, tracking_code, shipped_at, estimated_delivery, order_date
            FROM orders
            WHERE user_id = ?
            ORDER BY order_date DESC
            LIMIT ?
        """;
        List<Order> list = new ArrayList<>();
        try (Connection c = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapOrder(rs));
            }
        }
        return list;
    }

    @Override
    public List<Order> findRecentAll(int limit) throws Exception {
        String sql = """
            SELECT order_id, order_number, total_amount, status, payment_status, payment_method,
                   carrier, tracking_code, shipped_at, estimated_delivery, order_date
            FROM orders
            ORDER BY order_date DESC
            LIMIT ?
        """;
        List<Order> list = new ArrayList<>();
        try (Connection c = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapOrder(rs));
            }
        }
        return list;
    }

    @Override
    public List<OrderItem> findItemsByOrder(int orderId) throws Exception {
        String sql = """
            SELECT item_id, order_id, product_id, slot_id, quantity, unit_price, total_price, product_name
            FROM order_items
            WHERE order_id = ?
            ORDER BY item_id ASC
        """;
        List<OrderItem> items = new ArrayList<>();
        try (Connection c = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem it = new OrderItem();
                    it.setItemId(rs.getInt("item_id"));
                    it.setOrderId(rs.getInt("order_id"));
                    it.setProductId(rs.getInt("product_id"));
                    it.setSlotId((Integer) (rs.getObject("slot_id") == null ? null : rs.getInt("slot_id")));
                    it.setQuantity(rs.getInt("quantity"));
                    it.setUnitPrice(rs.getBigDecimal("unit_price"));
                    it.setTotalPrice(rs.getBigDecimal("total_price"));
                    it.setProductName(rs.getString("product_name"));
                    items.add(it);
                }
            }
        }
        return items;
    }
}