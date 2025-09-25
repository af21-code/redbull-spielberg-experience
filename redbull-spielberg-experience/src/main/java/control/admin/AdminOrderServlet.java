package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.dao.OrderDAO;
import model.dao.impl.OrderDAOImpl;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Azioni admin su singolo ordine (POST):
 *  - /admin/order-action?action=tracking -> aggiorna corriere/tracking (imposta shipped_at se null)
 *  - /admin/order-action?action=complete -> segna come COMPLETED (e prova a valorizzare delivered_at se la colonna esiste)
 *
 * La pagina di dettaglio (GET) resta su /admin/order, gestita da OrderDetailsAdminServlet.
 */
@WebServlet(name = "AdminOrderServlet", urlPatterns = {"/admin/order-action"})
public class AdminOrderServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO = new OrderDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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
                    boolean ok = ((OrderDAOImpl)orderDAO).markCompleted(orderId);
                    redirectBack(resp, req, orderId, ok ? "ok" : "err",
                            ok ? "Ordine segnato come COMPLETATO" : "Nessuna riga aggiornata");
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