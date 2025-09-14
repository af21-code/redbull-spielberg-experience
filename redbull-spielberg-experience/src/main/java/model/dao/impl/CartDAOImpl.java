package model.dao.impl;

import model.CartItem;
import model.dao.CartDAO;
import utils.DatabaseConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class CartDAOImpl implements CartDAO {

    private final Connection externalCon; // può essere null

    public CartDAOImpl() { this.externalCon = null; }
    public CartDAOImpl(Connection con) { this.externalCon = con; }

    private interface SQLRun<T> { T run(Connection c) throws Exception; }
    private <T> T withCon(SQLRun<T> block) throws Exception {
        if (externalCon != null) return block.run(externalCon);
        try (Connection c = DatabaseConnection.getInstance().getConnection()) {
            return block.run(c);
        }
    }

    // Compatibilità: delega all’overload con dettagli null
    @Override
    public void upsertItem(int userId, int productId, Integer slotId, int quantity) throws Exception {
        upsertItem(userId, productId, slotId, quantity, null, null, null, null, null);
    }

    @Override
    public void upsertItem(int userId, int productId, Integer slotId, int quantity,
                           String driverName, String driverNumber, String companionName,
                           String vehicleCode, LocalDate eventDate) throws Exception {
        final String sql = """
            INSERT INTO cart (user_id, product_id, slot_id, quantity,
                              driver_name, driver_number, companion_name, vehicle_code, event_date)
            VALUES (?,?,?,?,?,?,?,?,?)
            ON DUPLICATE KEY UPDATE
                quantity        = quantity + VALUES(quantity),
                driver_name     = IFNULL(VALUES(driver_name), driver_name),
                driver_number   = IFNULL(VALUES(driver_number), driver_number),
                companion_name  = IFNULL(VALUES(companion_name), companion_name),
                vehicle_code    = IFNULL(VALUES(vehicle_code), vehicle_code),
                event_date      = IFNULL(VALUES(event_date), event_date),
                updated_at      = CURRENT_TIMESTAMP
        """;
        withCon(c -> {
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                int i = 1;
                ps.setInt(i++, userId);
                ps.setInt(i++, productId);
                if (slotId == null) ps.setNull(i++, Types.INTEGER); else ps.setInt(i++, slotId);
                ps.setInt(i++, Math.max(1, quantity));

                if (driverName == null || driverName.isBlank()) ps.setNull(i++, Types.VARCHAR); else ps.setString(i++, driverName);
                if (driverNumber == null || driverNumber.isBlank()) ps.setNull(i++, Types.VARCHAR); else ps.setString(i++, driverNumber);
                if (companionName == null || companionName.isBlank()) ps.setNull(i++, Types.VARCHAR); else ps.setString(i++, companionName);
                if (vehicleCode == null || vehicleCode.isBlank()) ps.setNull(i++, Types.VARCHAR); else ps.setString(i++, vehicleCode);
                if (eventDate == null) ps.setNull(i++, Types.DATE); else ps.setDate(i++, Date.valueOf(eventDate));

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
                   c.driver_name, c.driver_number, c.companion_name, c.vehicle_code, c.event_date,
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
                        it.setDriverName(rs.getString("driver_name"));
                        it.setDriverNumber(rs.getString("driver_number"));
                        it.setCompanionName(rs.getString("companion_name"));
                        it.setVehicleCode(rs.getString("vehicle_code"));
                        Date d = rs.getDate("event_date");
                        if (d != null) it.setEventDate(d.toLocalDate());
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