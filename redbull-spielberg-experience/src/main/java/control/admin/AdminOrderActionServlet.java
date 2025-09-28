package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import model.User;
import model.dao.OrderDAO;
import model.dao.impl.OrderDAOImpl;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Azioni admin su singolo ordine (POST):
 *  - /admin/order-action?action=tracking -> aggiorna corriere/tracking (imposta shipped_at se null)
 *  - /admin/order-action?action=complete -> segna come COMPLETED (e prova a valorizzare delivered_at se la colonna esiste)
 *  - /admin/order-action?action=cancel   -> annulla ordine (ripristina stock/slot, status=CANCELLED)
 *
 * La pagina di dettaglio (GET) è su /admin/order (gestita da AdminOrderServlet).
 */
@WebServlet(name = "AdminOrderActionServlet", urlPatterns = {"/admin/order-action"})
public class AdminOrderActionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO = new OrderDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // --- Accesso solo ADMIN ---
        HttpSession session = req.getSession(false);
        User auth = (session == null) ? null : (User) session.getAttribute("authUser");
        if (auth == null || auth.getUserType() == null || !"ADMIN".equalsIgnoreCase(String.valueOf(auth.getUserType()))) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }

        // --- Verifica CSRF (soft) ---
        String csrfSess = (session == null) ? null : (String) session.getAttribute("csrfToken");
        String csrfForm = req.getParameter("csrf");
        if (csrfSess != null && (csrfForm == null || !csrfSess.equals(csrfForm))) {
            redirectWith(resp, req.getContextPath() + "/admin/orders", "err", "CSRF token non valido");
            return;
        }

        String action  = nz(req.getParameter("action"));
        int orderId    = parseInt(req.getParameter("id"), 0);

        if (orderId <= 0) {
            redirectWith(resp, req.getContextPath() + "/admin/orders", "err", "ID ordine non valido");
            return;
        }

        try {
            switch (action.toLowerCase()) {
                case "tracking" -> {
                    String carrier = nz(req.getParameter("carrier"));
                    String code    = nz(req.getParameter("tracking_code"));
                    if (carrier.isBlank() || code.isBlank()) {
                        redirectBack(resp, req, orderId, "err", "Corriere e codice tracking sono obbligatori");
                        return;
                    }
                    boolean ok = orderDAO.updateTracking(orderId, carrier, code);
                    redirectBack(resp, req, orderId, ok ? "ok" : "err",
                            ok ? "Tracking aggiornato" : "Nessuna riga aggiornata");
                }
                case "complete" -> {
                    boolean ok = orderDAO.markCompleted(orderId);
                    redirectBack(resp, req, orderId, ok ? "ok" : "err",
                            ok ? "Ordine segnato come COMPLETATO" : "Nessuna riga aggiornata");
                }
                case "cancel" -> {
                    boolean ok = orderDAO.cancelOrder(orderId);
                    redirectBack(resp, req, orderId, ok ? "ok" : "err",
                            ok ? "Ordine annullato" : "Impossibile annullare l'ordine");
                }
                default -> redirectBack(resp, req, orderId, "err", "Azione non riconosciuta");
            }
        } catch (Exception e) {
            e.printStackTrace();
            redirectBack(resp, req, orderId, "err", "Errore: " + e.getMessage());
        }
    }

    // -------- Helpers --------

    private static String nz(String s) { return (s == null) ? "" : s.trim(); }

    private static int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception ignored) { return def; }
    }

    private void redirectBack(HttpServletResponse resp, HttpServletRequest req, int orderId,
                              String key, String msg) throws IOException {
        String base = req.getContextPath() + "/admin/order?id=" + orderId; // pagina dettaglio (GET)
        redirectWith(resp, base, key, msg);
    }

    private void redirectWith(HttpServletResponse resp, String baseUrl, String key, String msg) throws IOException {
        String val = URLEncoder.encode(msg, StandardCharsets.UTF_8);
        String sep = baseUrl.contains("?") ? "&" : "?";
        resp.sendRedirect(baseUrl + sep + key + "=" + val);
    }
}