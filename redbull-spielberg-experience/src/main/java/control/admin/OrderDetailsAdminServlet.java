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

/**
 * Dettaglio ordine per ADMIN (solo GET).
 * Le azioni (tracking / complete) sono gestite da AdminOrderServlet su /admin/order-action (POST).
 */
@WebServlet(name = "OrderDetailsAdminServlet", urlPatterns = {"/admin/order"})
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

        // --- Parametro id ---
        int orderId;
        try {
            orderId = Integer.parseInt(req.getParameter("id"));
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order id mancante o non valido.");
            return;
        }

        try {
            // Header
            Map<String,Object> order = orderDAO.findOrderHeader(orderId);
            if (order == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Ordine non trovato.");
                return;
            }

            // Righe
            List<Map<String,Object>> items = orderDAO.findOrderItems(orderId);

            // Attributi per la JSP unica
            req.setAttribute("order", order);
            req.setAttribute("items", items);
            req.setAttribute("isAdmin", Boolean.TRUE);

            // Usiamo la JSP unica che mostra azioni solo se isAdmin = true
            req.getRequestDispatcher("/views/order-details.jsp").forward(req, resp);

        } catch (Exception ex) {
            ex.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore caricando il dettaglio ordine.");
        }
    }
}