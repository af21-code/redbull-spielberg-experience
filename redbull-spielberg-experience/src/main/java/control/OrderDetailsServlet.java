package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import utils.DatabaseConnection;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/order")
public class OrderDetailsServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    // deve essere loggato
    Object u = req.getSession().getAttribute("authUser");
    if (u == null) {
      resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
      return;
    }

    // è admin?
    boolean isAdmin = false;
    Integer currentUserId = null;
    try {
      Object type = u.getClass().getMethod("getUserType").invoke(u);
      isAdmin = (type != null && "ADMIN".equalsIgnoreCase(String.valueOf(type)));
    } catch (Exception ignored) {}
    try {
      currentUserId = (Integer) u.getClass().getMethod("getUserId").invoke(u);
    } catch (Exception ignored) {}

    // order id
    String idParam = req.getParameter("id");
    if (idParam == null || idParam.isBlank()) {
      resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order id mancante");
      return;
    }
    int orderId;
    try { orderId = Integer.parseInt(idParam); }
    catch (NumberFormatException e) {
      resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order id non valido");
      return;
    }

    // header (con join utente per info acquirente)
    String headerSqlAdmin = """
      SELECT o.order_id, o.order_number, o.total_amount, o.status, o.payment_status, o.payment_method,
             o.shipping_address, o.billing_address, o.notes, o.order_date,
             o.carrier, o.tracking_code, o.shipped_at, o.estimated_delivery,
             u.user_id, u.first_name, u.last_name, u.email, u.phone_number
      FROM orders o
      JOIN users u ON u.user_id = o.user_id
      WHERE o.order_id=?
    """;

    String headerSqlUser = """
      SELECT o.order_id, o.order_number, o.total_amount, o.status, o.payment_status, o.payment_method,
             o.shipping_address, o.billing_address, o.notes, o.order_date,
             o.carrier, o.tracking_code, o.shipped_at, o.estimated_delivery,
             u.user_id, u.first_name, u.last_name, u.email, u.phone_number
      FROM orders o
      JOIN users u ON u.user_id = o.user_id
      WHERE o.order_id=? AND o.user_id=?
    """;

    // items (include eventuali campi pilota se presenti)
    String itemsSql = """
      SELECT oi.product_name, oi.quantity, oi.unit_price, oi.total_price,
             p.image_url,
             oi.driver_name, oi.companion_name, oi.vehicle_code, oi.event_date
      FROM order_items oi
      LEFT JOIN products p ON p.product_id = oi.product_id
      WHERE oi.order_id=?
    """;

    try (Connection con = DatabaseConnection.getInstance().getConnection()) {

      Map<String,Object> header = null;
      try (PreparedStatement ps = con.prepareStatement(isAdmin ? headerSqlAdmin : headerSqlUser)) {
        ps.setInt(1, orderId);
        if (!isAdmin) {
          ps.setInt(2, currentUserId == null ? -1 : currentUserId);
        }
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) {
            header = new HashMap<>();
            header.put("order_id", rs.getInt("order_id"));
            header.put("order_number", rs.getString("order_number"));
            header.put("total_amount", rs.getBigDecimal("total_amount"));
            header.put("status", rs.getString("status"));
            header.put("payment_status", rs.getString("payment_status"));
            header.put("payment_method", rs.getString("payment_method"));
            header.put("shipping_address", rs.getString("shipping_address"));
            header.put("billing_address", rs.getString("billing_address"));
            header.put("notes", rs.getString("notes"));
            header.put("order_date", rs.getTimestamp("order_date"));
            header.put("carrier", rs.getString("carrier"));
            header.put("tracking_code", rs.getString("tracking_code"));
            header.put("shipped_at", rs.getTimestamp("shipped_at"));
            header.put("estimated_delivery", rs.getDate("estimated_delivery"));

            // buyer
            header.put("buyer_user_id", rs.getInt("user_id"));
            header.put("buyer_first_name", rs.getString("first_name"));
            header.put("buyer_last_name", rs.getString("last_name"));
            header.put("buyer_email", rs.getString("email"));
            header.put("buyer_phone", rs.getString("phone_number"));
          }
        }
      }

      if (header == null) {
        resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Ordine non trovato");
        return;
      }

      List<Map<String,Object>> items = new ArrayList<>();
      try (PreparedStatement ps = con.prepareStatement(itemsSql)) {
        ps.setInt(1, orderId);
        try (ResultSet rs = ps.executeQuery()) {
          while (rs.next()) {
            Map<String,Object> row = new HashMap<>();
            row.put("product_name", rs.getString("product_name"));
            row.put("quantity", rs.getInt("quantity"));
            row.put("unit_price", rs.getBigDecimal("unit_price"));
            row.put("total_price", rs.getBigDecimal("total_price"));
            row.put("image_url", rs.getString("image_url"));
            row.put("driver_name", rs.getString("driver_name"));
            row.put("companion_name", rs.getString("companion_name"));
            row.put("vehicle_code", rs.getString("vehicle_code"));
            row.put("event_date", rs.getDate("event_date"));
            items.add(row);
          }
        }
      }

      req.setAttribute("isAdmin", isAdmin);
      req.setAttribute("order", header);
      req.setAttribute("items", items);
      req.getRequestDispatcher("/views/order-details.jsp").forward(req, resp);

    } catch (Exception e) {
      log("Errore caricando ordine " + orderId, e);
      resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore caricamento ordine");
    }
  }

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    // solo admin aggiorna
    Object u = req.getSession().getAttribute("authUser");
    boolean isAdmin = false;
    try {
      Object type = (u == null) ? null : u.getClass().getMethod("getUserType").invoke(u);
      isAdmin = (type != null && "ADMIN".equalsIgnoreCase(String.valueOf(type)));
    } catch (Exception ignored) {}
    if (!isAdmin) {
      resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Operazione non consentita");
      return;
    }

    String idParam = req.getParameter("id");
    if (idParam == null || idParam.isBlank()) {
      resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order id mancante");
      return;
    }
    int orderId;
    try { orderId = Integer.parseInt(idParam); }
    catch (NumberFormatException e) {
      resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order id non valido");
      return;
    }

    String action = req.getParameter("action");
    if (action == null) action = "";

    try (Connection con = DatabaseConnection.getInstance().getConnection()) {
      int updated = 0;

      if ("complete".equalsIgnoreCase(action)) {
        // segna come consegnato/completato
        try (PreparedStatement ps = con.prepareStatement(
            "UPDATE orders SET status='COMPLETED' WHERE order_id=?")) {
          ps.setInt(1, orderId);
          updated = ps.executeUpdate();
        }
      } else if ("tracking".equalsIgnoreCase(action)) {
        String carrier = trimOrNull(req.getParameter("carrier"));
        String code = trimOrNull(req.getParameter("tracking_code"));
        try (PreparedStatement ps = con.prepareStatement(
            "UPDATE orders SET carrier=?, tracking_code=?, shipped_at=IFNULL(shipped_at, NOW()) WHERE order_id=?")) {
          ps.setString(1, carrier);
          ps.setString(2, code);
          ps.setInt(3, orderId);
          updated = ps.executeUpdate();
        }
      }

      resp.sendRedirect(req.getContextPath() + "/order?id=" + orderId + "&updated=" + updated);
    } catch (Exception e) {
      log("Errore aggiornando ordine " + orderId, e);
      resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore aggiornamento ordine");
    }
  }

  private String trimOrNull(String s) {
    if (s == null) return null;
    s = s.trim();
    return s.isEmpty() ? null : s;
  }
}