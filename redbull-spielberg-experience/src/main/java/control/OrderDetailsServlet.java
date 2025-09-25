package control;

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
 * Dettaglio ordine lato UTENTE (GET /order).
 * - Richiede utente loggato.
 * - Se NON admin, può vedere solo i propri ordini.
 * - Dati presi tramite OrderDAO (niente query raw).
 * La JSP condivisa è /views/order-details.jsp.
 */
@WebServlet(name = "OrderDetailsServlet", urlPatterns = {"/order"})
public class OrderDetailsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO = new OrderDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Deve essere loggato
        HttpSession session = req.getSession(false);
        User auth = (session == null) ? null : (User) session.getAttribute("authUser");
        if (auth == null) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }

        boolean isAdmin = "ADMIN".equalsIgnoreCase(String.valueOf(auth.getUserType()));

        // id ordine
        int orderId;
        try {
            orderId = Integer.parseInt(nz(req.getParameter("id")));
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order id mancante o non valido");
            return;
        }

        try {
            // Header
            Map<String,Object> order = orderDAO.findOrderHeader(orderId);
            if (order == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Ordine non trovato");
                return;
            }

            // Se NON admin, l'ordine deve appartenere all'utente loggato
            Object ownerObj = order.get("user_id"); // valorizzato dal DAO
            int ownerId = (ownerObj instanceof Number) ? ((Number) ownerObj).intValue() : -1;
            if (!isAdmin && ownerId != auth.getUserId()) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non hai i permessi per questo ordine");
                return;
            }

            // Righe
            List<Map<String,Object>> items = orderDAO.findOrderItems(orderId);

            // Attributi per JSP
            req.setAttribute("order", order);
            req.setAttribute("items", items);
            req.setAttribute("isAdmin", Boolean.FALSE); // lato utente: nasconde azioni admin

            req.getRequestDispatcher("/views/order-details.jsp").forward(req, resp);

        } catch (Exception e) {
            log("Errore caricando ordine " + orderId, e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore caricamento ordine");
        }
    }

    // -------- helpers --------
    private static String nz(String s) { return s == null ? "" : s.trim(); }
}