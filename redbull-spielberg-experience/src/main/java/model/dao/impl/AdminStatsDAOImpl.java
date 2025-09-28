package model.dao.impl;

import model.dao.AdminStatsDAO;
import utils.DatabaseConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

public class AdminStatsDAOImpl implements AdminStatsDAO {

    private Connection getConnection() throws Exception {
        return DatabaseConnection.getInstance().getConnection();
    }

    @Override
    public int countOrdersToday() throws Exception {
        String sql = "SELECT COUNT(*) FROM orders WHERE DATE(order_date) = CURRENT_DATE";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            return rs.getInt(1);
        }
    }

    @Override
    public BigDecimal sumRevenueToday() throws Exception {
        // Ricavi del giorno, escludendo gli ordini cancellati
        String sql = """
                SELECT COALESCE(SUM(total_amount), 0)
                FROM orders
                WHERE DATE(order_date) = CURRENT_DATE
                  AND status <> 'CANCELLED'
                """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            BigDecimal v = rs.getBigDecimal(1);
            return (v == null) ? BigDecimal.ZERO : v;
        }
    }

    @Override
    public int countOrdersInLastDays(int days) throws Exception {
        if (days < 0) days = 0;
        String sql = "SELECT COUNT(*) FROM orders WHERE order_date >= (NOW() - INTERVAL ? DAY)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    @Override
    public BigDecimal sumRevenueInLastDays(int days) throws Exception {
        if (days < 0) days = 0;
        String sql = """
                SELECT COALESCE(SUM(total_amount), 0)
                FROM orders
                WHERE order_date >= (NOW() - INTERVAL ? DAY)
                  AND status <> 'CANCELLED'
                """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                BigDecimal v = rs.getBigDecimal(1);
                return (v == null) ? BigDecimal.ZERO : v;
            }
        }
    }

    @Override
    public int countNewUsersInLastDays(int days) throws Exception {
        if (days < 0) days = 0;
        String sql = "SELECT COUNT(*) FROM users WHERE registration_date >= (NOW() - INTERVAL ? DAY)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    @Override
    public Map<String, Integer> countByStatuses(String... statuses) throws Exception {
        Map<String, Integer> out = new HashMap<>();
        if (statuses == null || statuses.length == 0) return out;

        StringBuilder in = new StringBuilder();
        for (int i = 0; i < statuses.length; i++) {
            if (i > 0) in.append(',');
            in.append('?');
        }

        String sql = "SELECT status, COUNT(*) AS cnt FROM orders WHERE status IN (" + in + ") GROUP BY status";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < statuses.length; i++) {
                ps.setString(i + 1, statuses[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.put(rs.getString("status"), rs.getInt("cnt"));
                }
            }
        }
        // Assicura chiavi mancanti con 0
        for (String s : statuses) out.putIfAbsent(s, 0);
        return out;
    }

    @Override
    public List<Map<String, Object>> latestOrders(int limit) throws Exception {
        if (limit <= 0) limit = 5;
        String sql = """
                SELECT o.order_id,
                       o.order_number,
                       o.total_amount,
                       o.status,
                       o.order_date,
                       CONCAT(u.first_name, ' ', u.last_name) AS customer
                FROM orders o
                LEFT JOIN users u ON u.user_id = o.user_id
                ORDER BY o.order_date DESC
                LIMIT ?
                """;
        List<Map<String,Object>> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> r = new HashMap<>();
                    r.put("order_id",     rs.getInt("order_id"));
                    r.put("order_number", rs.getString("order_number"));
                    r.put("total_amount", rs.getBigDecimal("total_amount"));
                    r.put("status",       rs.getString("status"));
                    r.put("order_date",   rs.getTimestamp("order_date"));
                    r.put("customer",     rs.getString("customer"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    @Override
    public List<Map<String, Object>> topProductsLastDays(int days, int limit) throws Exception {
        if (days  <= 0) days = 7;
        if (limit <= 0) limit = 5;

        String sql = """
                SELECT
                    oi.product_id,
                    oi.product_name,
                    SUM(oi.quantity)     AS qty,
                    SUM(oi.total_price)  AS revenue
                FROM order_items oi
                JOIN orders o ON o.order_id = oi.order_id
                WHERE o.order_date >= (NOW() - INTERVAL ? DAY)
                GROUP BY oi.product_id, oi.product_name
                ORDER BY revenue DESC, qty DESC
                LIMIT ?
                """;

        List<Map<String,Object>> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, days);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> r = new HashMap<>();
                    r.put("product_id",   rs.getInt("product_id"));
                    r.put("product_name", rs.getString("product_name"));
                    r.put("qty",          rs.getInt("qty"));
                    r.put("revenue",      rs.getBigDecimal("revenue"));
                    list.add(r);
                }
            }
        }
        return list;
    }
}