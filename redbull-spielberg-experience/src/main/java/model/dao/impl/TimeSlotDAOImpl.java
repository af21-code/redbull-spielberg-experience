package model.dao.impl;

import model.TimeSlot;
import model.dao.TimeSlotDAO;
import utils.DatabaseConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class TimeSlotDAOImpl implements TimeSlotDAO {

    private TimeSlot map(ResultSet rs) throws SQLException {
        TimeSlot ts = new TimeSlot();
        ts.setSlotId(rs.getInt("slot_id"));
        ts.setProductId(rs.getInt("product_id"));
        Date d = rs.getDate("slot_date");
        Time t = rs.getTime("slot_time");
        ts.setSlotDate(d != null ? d.toLocalDate() : null);
        ts.setSlotTime(t != null ? t.toLocalTime() : null);
        ts.setMaxCapacity(rs.getInt("max_capacity"));
        ts.setBookedCapacity(rs.getInt("booked_capacity"));
        ts.setAvailable(rs.getBoolean("is_available"));
        return ts;
    }

    @Override
    public List<TimeSlot> findAvailableByProduct(int productId) throws Exception {
        String sql = """
            SELECT slot_id, product_id, slot_date, slot_time, max_capacity, booked_capacity, is_available
            FROM time_slots
            WHERE product_id = ?
              AND is_available = 1
              AND booked_capacity < max_capacity
              AND slot_date >= CURDATE()
            ORDER BY slot_date, slot_time
        """;
        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                List<TimeSlot> list = new ArrayList<>();
                while (rs.next()) list.add(map(rs));
                return list;
            }
        }
    }

    @Override
    public List<TimeSlot> findAvailableByProductAndDate(int productId, LocalDate date) throws Exception {
        String sql = """
            SELECT slot_id, product_id, slot_date, slot_time, max_capacity, booked_capacity, is_available
            FROM time_slots
            WHERE product_id = ?
              AND slot_date = ?
              AND is_available = 1
              AND booked_capacity < max_capacity
            ORDER BY slot_time
        """;
        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setDate(2, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                List<TimeSlot> list = new ArrayList<>();
                while (rs.next()) list.add(map(rs));
                return list;
            }
        }
    }

    @Override
    public TimeSlot findById(int slotId) throws Exception {
        String sql = """
            SELECT slot_id, product_id, slot_date, slot_time, max_capacity, booked_capacity, is_available
            FROM time_slots
            WHERE slot_id = ?
        """;
        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, slotId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
                return null;
            }
        }
    }
}