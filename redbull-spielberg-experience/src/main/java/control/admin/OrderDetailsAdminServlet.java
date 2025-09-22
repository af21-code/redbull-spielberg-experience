package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import model.User;
import model.dao.OrderDAO;
import model.dao.impl.OrderDAOImpl;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/order")
public class OrderDetailsAdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO = new OrderDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // --- Accesso solo ADMIN ---
        HttpSession session = req.getSession(false);
        User auth = (session == null) ? null : (User) session.getAttribute("authUser");
        if (auth == null || auth.getUserType() == null || !"ADMIN".equalsIgnoreCase(String.valueOf(auth.getUserType()))) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(req.getParameter("id"));
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order id mancante o non valido.");
            return;
        }

        try {
            Map<String,Object> order = orderDAO.findOrderHeader(id);
            if (order == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Ordine non trovato.");
                return;
            }
            List<Map<String,Object>> items = orderDAO.findOrderItems(id);

            req.setAttribute("order", order);
            req.setAttribute("items", items);
            req.setAttribute("isAdmin", Boolean.TRUE);

            // 🔧 Forward alla JSP corretta (unica)
            req.getRequestDispatcher("/views/order-details.jsp").forward(req, resp);

        } catch (Exception ex) {
            ex.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore caricando il dettaglio ordine.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // --- Accesso solo ADMIN ---
        HttpSession session = req.getSession(false);
        User auth = (session == null) ? null : (User) session.getAttribute("authUser");
        if (auth == null || auth.getUserType() == null || !"ADMIN".equalsIgnoreCase(String.valueOf(auth.getUserType()))) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(req.getParameter("id"));
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order id non valido.");
            return;
        }

        String action = safe(req.getParameter("action"));
        try {
            if ("tracking".equalsIgnoreCase(action)) {
                String carrier = safe(req.getParameter("carrier"));
                String code    = safe(req.getParameter("tracking_code"));
                orderDAO.updateTracking(id, carrier, code);
                resp.sendRedirect(req.getContextPath() + "/admin/order?id=" + id + "&ok=tracking");
                return;
            } else if ("complete".equalsIgnoreCase(action)) {
                orderDAO.markCompleted(id);
                resp.sendRedirect(req.getContextPath() + "/admin/order?id=" + id + "&ok=completed");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/admin/order?id=" + id);
        } catch (Exception ex) {
            ex.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore eseguendo l'azione admin.");
        }
    }

    private static String safe(String s) {
        return s == null ? "" : s.trim();
    }
}