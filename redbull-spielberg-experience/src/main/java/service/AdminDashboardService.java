package service;

import dto.DashboardStats;
import utils.DatabaseConnection;

import java.math.BigDecimal;
import java.sql.*;

public class AdminDashboardService {

    public DashboardStats getTodayStats() throws Exception {
        DashboardStats stats = new DashboardStats();

        try (Connection con = DatabaseConnection.getInstance().getConnection()) {

            // 1) Ordini di oggi + incasso di oggi (consideriamo tutti gli ordini di oggi;
            //    se vuoi solo i pagati aggiungi AND payment_status='PAID')
            String sqlToday = """
                SELECT COUNT(*) AS cnt, COALESCE(SUM(total_amount), 0) AS rev
                FROM orders
                WHERE DATE(order_date) = CURDATE()
            """;
            try (PreparedStatement ps = con.prepareStatement(sqlToday);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.setOrdersToday(rs.getInt("cnt"));
                    stats.setRevenueToday(rs.getBigDecimal("rev"));
                }
            }

            // 2) Ordini in attesa (puoi modificare l'insieme degli stati a piacere)
            String sqlPending = "SELECT COUNT(*) FROM orders WHERE status IN ('PENDING','PROCESSING')";
            try (PreparedStatement ps = con.prepareStatement(sqlPending);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) stats.setPendingCount(rs.getInt(1));
            }

            // 3) Prodotti sotto scorta (MERCHANDISE con stock <= 5)
            String sqlLowStock = """
                SELECT COUNT(*)
                FROM products
                WHERE product_type = 'MERCHANDISE' AND stock_quantity <= 5
            """;
            try (PreparedStatement ps = con.prepareStatement(sqlLowStock);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) stats.setLowStockCount(rs.getInt(1));
            }
        }

        // Null-safety
        if (stats.getRevenueToday() == null) stats.setRevenueToday(BigDecimal.ZERO);
        return stats;
    }
}