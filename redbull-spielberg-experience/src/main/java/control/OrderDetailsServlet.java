package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import utils.DatabaseConnection;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
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

        // prova a capire se è admin in modo "tollerante" (enum o stringa)
        boolean isAdmin = false;
        try {
            Object type = u.getClass().getMethod("getUserType").invoke(u);
            isAdmin = type != null && "ADMIN".equalsIgnoreCase(String.valueOf(type));
        } catch (Exception ignored) {}

        // userId corrente (se serve per filtro)
        Integer userId = null;
        try {
            userId = (Integer) u.getClass().getMethod("getUserId").invoke(u);
        } catch (Exception ignored) {}

        // orderId richiesto
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

        // query header
        String headerSqlUser = """
            SELECT order_id, order_number, total_amount, status, payment_status, payment_method,
                   shipping_address, billing_address, notes, order_date,
                   carrier, tracking_code, shipped_at, estimated_delivery
            FROM orders
            WHERE order_id=? AND user_id=?
        """;
        String headerSqlAdmin = """
            SELECT order_id, order_number, total_amount, status, payment_status, payment_method,
                   shipping_address, billing_address, notes, order_date,
                   carrier, tracking_code, shipped_at, estimated_delivery
            FROM orders
            WHERE order_id=?
        """;

        // query items (join per prendere anche l'immagine prodotto)
        String itemsSql = """
            SELECT oi.product_name, oi.quantity, oi.unit_price, oi.total_price,
                   p.image_url
            FROM order_items oi
            LEFT JOIN products p ON p.product_id = oi.product_id
            WHERE oi.order_id=?
        """;

        try (Connection con = DatabaseConnection.getInstance().getConnection()) {
            // header
            Map<String,Object> header = null;
            try (PreparedStatement ps = con.prepareStatement(isAdmin ? headerSqlAdmin : headerSqlUser)) {
                ps.setInt(1, orderId);
                if (!isAdmin) ps.setInt(2, userId == null ? -1 : userId);
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
                    }
                }
            }

            if (header == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Ordine non trovato");
                return;
            }

            // items
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
                        items.add(row);
                    }
                }
            }

            req.setAttribute("order", header);
            req.setAttribute("items", items);
            req.getRequestDispatcher("/views/order-details.jsp").forward(req, resp);

        } catch (Exception e) {
            log("Errore caricando ordine " + orderId, e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore caricamento ordine");
        }
    }
}