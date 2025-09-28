package service;

import model.CartItem;
import model.dao.CartDAO;
import model.dao.impl.CartDAOImpl;
import utils.DatabaseConnection;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.math.BigDecimal;

public class CheckoutService {

  public static final class Input {
    public final String shipping, billing, notes, payment;
    public Input(String shipping, String billing, String notes, String payment) {
      this.shipping = shipping; this.billing = billing; this.notes = notes; this.payment = payment;
    }
  }

  public static final class Result {
    public final String orderNumber;
    public Result(String orderNumber) { this.orderNumber = orderNumber; }
  }

  public Result checkout(long userId, String idempotencyKey, Input in, List<CartItem> cart) throws Exception {
    if (cart == null || cart.isEmpty()) throw new IllegalStateException("Carrello vuoto");

    try (Connection c = DatabaseConnection.getInstance().getConnection()) {
      c.setAutoCommit(false);
      c.setTransactionIsolation(Connection.TRANSACTION_REPEATABLE_READ);

      // 1) LOCK & CHECK su ogni item
      for (CartItem it : cart) {
        if (it.getSlotId() == null) {
          // MERCH
          try (PreparedStatement ps = c.prepareStatement(
              "SELECT is_active, stock_quantity FROM products WHERE product_id=? FOR UPDATE")) {
            ps.setLong(1, it.getProductId());
            try (ResultSet rs = ps.executeQuery()) {
              if (!rs.next() || rs.getInt("is_active") == 0)
                throw new IllegalStateException("Prodotto non disponibile");
              if (rs.getInt("stock_quantity") < it.getQuantity())
                throw new IllegalStateException("Stock insufficiente");
            }
          }
        } else {
          // EXPERIENCE (slot)
          try (PreparedStatement ps = c.prepareStatement(
              "SELECT is_available, slot_date, slot_time, max_capacity, booked_capacity " +
              "FROM time_slots WHERE slot_id=? FOR UPDATE")) {
            ps.setLong(1, it.getSlotId());
            try (ResultSet rs = ps.executeQuery()) {
              if (!rs.next() || rs.getInt("is_available") == 0)
                throw new IllegalStateException("Slot non disponibile");
              LocalDate d = rs.getDate("slot_date").toLocalDate();
              LocalTime t = rs.getTime("slot_time").toLocalTime();
              if (d.isBefore(LocalDate.now()) || (d.equals(LocalDate.now()) && t.isBefore(LocalTime.now())))
                throw new IllegalStateException("Slot scaduto");
              int cap = rs.getInt("max_capacity"), booked = rs.getInt("booked_capacity");
              if (booked + it.getQuantity() > cap)
                throw new IllegalStateException("Capienza slot esaurita");
            }
          }
        }
      }

      // 2) Crea ordine (snapshot totale dal prezzo corrente)
      String orderNumber = generateOrderNumber();
      long orderId;
      BigDecimal total = BigDecimal.ZERO;

      // ricalcola total basandoti sui prezzi correnti
      for (CartItem it : cart) {
        try (PreparedStatement ps = c.prepareStatement("SELECT price FROM products WHERE product_id=?")) {
          ps.setLong(1, it.getProductId());
          try (ResultSet rs = ps.executeQuery()) {
            rs.next();
            BigDecimal price = rs.getBigDecimal(1);
            total = total.add(price.multiply(BigDecimal.valueOf(it.getQuantity())));
          }
        }
      }

      try (PreparedStatement ps = c.prepareStatement(
          "INSERT INTO orders (user_id, order_number, total_amount, status, payment_status, payment_method, " +
          "shipping_address, billing_address, notes) VALUES (?,?,?,?,?,?,?,?,?)",
          Statement.RETURN_GENERATED_KEYS)) {
        ps.setLong(1, userId);
        ps.setString(2, orderNumber);
        ps.setBigDecimal(3, total);
        ps.setString(4, "CONFIRMED");
        ps.setString(5, "PAID");
        ps.setString(6, in.payment);
        ps.setString(7, in.shipping);
        ps.setString(8, in.billing);
        ps.setString(9, in.notes);
        ps.executeUpdate();
        try (ResultSet rs = ps.getGeneratedKeys()) { rs.next(); orderId = rs.getLong(1); }
      }

      // 3) Inserisci righe + aggiorna stock/slot (stessa transazione)
      for (CartItem it : cart) {
        String name; BigDecimal price;
        try (PreparedStatement ps = c.prepareStatement("SELECT name, price FROM products WHERE product_id=?")) {
          ps.setLong(1, it.getProductId());
          try (ResultSet rs = ps.executeQuery()) { rs.next(); name = rs.getString(1); price = rs.getBigDecimal(2); }
        }

        try (PreparedStatement ps = c.prepareStatement(
            "INSERT INTO order_items (order_id, product_id, slot_id, quantity, unit_price, total_price, product_name, " +
            "driver_name, driver_number, companion_name, vehicle_code, event_date) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)")) {
          ps.setLong(1, orderId);
          ps.setLong(2, it.getProductId());
          if (it.getSlotId() == null) ps.setNull(3, Types.BIGINT); else ps.setLong(3, it.getSlotId());
          ps.setInt(4, it.getQuantity());
          ps.setBigDecimal(5, price);
          ps.setBigDecimal(6, price.multiply(BigDecimal.valueOf(it.getQuantity())));
          ps.setString(7, name);
          ps.setString(8, it.getDriverName());
          ps.setString(9, it.getDriverNumber());
          ps.setString(10, it.getCompanionName());
          ps.setString(11, it.getVehicleCode());
          if (it.getEventDate() == null) ps.setNull(12, Types.DATE);
          else ps.setDate(12, java.sql.Date.valueOf(it.getEventDate()));
          ps.executeUpdate();
        }

        if (it.getSlotId() == null) {
          // MERCH: scalare stock (già validato sopra)
          try (PreparedStatement ps = c.prepareStatement(
              "UPDATE products SET stock_quantity = stock_quantity - ? WHERE product_id = ?")) {
            ps.setInt(1, it.getQuantity());
            ps.setLong(2, it.getProductId());
            ps.executeUpdate();
          }
        } else {
          // SLOT: incrementa booked e aggiorna disponibilità in base al nuovo valore
          try (PreparedStatement ps = c.prepareStatement(
              "UPDATE time_slots " +
              "SET booked_capacity = booked_capacity + ?, " +
              "    is_available = CASE WHEN (booked_capacity + ?) >= max_capacity THEN 0 ELSE 1 END " +
              "WHERE slot_id = ?")) {
            ps.setInt(1, it.getQuantity());
            ps.setInt(2, it.getQuantity());
            ps.setLong(3, it.getSlotId());
            ps.executeUpdate();
          }
        }
      }

      // 4) Svuota carrello DB tramite DAO (stessa Connection)
      CartDAO cartDao = new CartDAOImpl(c);
      cartDao.clearCart((int) userId);

      c.commit();
      return new Result(orderNumber);
    }
  }

  private static String generateOrderNumber() {
    // Semplice; puoi sostituire con un generatore più leggibile (es. RB-YYYYMMDD-xxxxx)
    return "RB-" + System.currentTimeMillis();
  }
}