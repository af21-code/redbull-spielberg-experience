package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.User;
import model.dao.OrderDAO;
import model.dao.impl.OrderDAOImpl;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

@WebServlet("/order/cancel")
public class OrderCancelServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO = new OrderDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        final String ctx = req.getContextPath();

        // --- Login obbligatorio ---
        HttpSession session = req.getSession(false);
        User auth = (session == null) ? null : (User) session.getAttribute("authUser");
        if (auth == null) {
            resp.sendRedirect(ctx + "/views/login.jsp");
            return;
        }

        // --- CSRF ---
        String csrfSess = (String) session.getAttribute("csrfToken");
        String csrfForm = req.getParameter("csrf");
        String csrfHead = req.getHeader("X-CSRF-Token");
        if (csrfSess == null || !(csrfSess.equals(csrfForm) || csrfSess.equals(csrfHead))) {
            String msg = URLEncoder.encode("Token di sicurezza non valido.", StandardCharsets.UTF_8);
            resp.sendRedirect(ctx + "/orders?err=" + msg);
            return;
        }

        // --- Parametri ---
        int orderId;
        try { orderId = Integer.parseInt(req.getParameter("id")); }
        catch (Exception e) {
            String msg = URLEncoder.encode("Parametro ordine mancante o non valido.", StandardCharsets.UTF_8);
            resp.sendRedirect(ctx + "/orders?err=" + msg);
            return;
        }

        try {
            // Leggi header ordine per controlli (ownership, stato, spedizione)
            Map<String,Object> h = orderDAO.findOrderHeader(orderId);
            if (h == null) {
                String msg = URLEncoder.encode("Ordine non trovato.", StandardCharsets.UTF_8);
                resp.sendRedirect(ctx + "/orders?err=" + msg);
                return;
            }

            int ownerId = (Integer) h.get("user_id");
            String status = String.valueOf(h.get("status"));
            java.sql.Timestamp shippedAt = (java.sql.Timestamp) h.get("shipped_at");

            boolean isAdmin = false;
            try { isAdmin = auth.getUserType() != null && "ADMIN".equalsIgnoreCase(String.valueOf(auth.getUserType())); } catch (Exception ignore) {}

            // Solo proprietario (o admin) può annullare
            if (!isAdmin && ownerId != auth.getUserId()) {
                String msg = URLEncoder.encode("Non sei autorizzato ad annullare questo ordine.", StandardCharsets.UTF_8);
                resp.sendRedirect(ctx + "/orders?err=" + msg);
                return;
            }

            // Vincoli annullabilità
            boolean cancellable =
                    !"CANCELLED".equalsIgnoreCase(status) &&
                    !"COMPLETED".equalsIgnoreCase(status) &&
                    shippedAt == null;

            if (!cancellable) {
                String msg = URLEncoder.encode("Ordine non più annullabile.", StandardCharsets.UTF_8);
                resp.sendRedirect(ctx + "/order?id=" + orderId + "&err=" + msg);
                return;
            }

            boolean ok = orderDAO.cancelOrder(orderId);
            if (!ok) {
                String msg = URLEncoder.encode("Impossibile annullare l'ordine.", StandardCharsets.UTF_8);
                resp.sendRedirect(ctx + "/order?id=" + orderId + "&err=" + msg);
                return;
            }

            String msg = URLEncoder.encode("Ordine annullato correttamente.", StandardCharsets.UTF_8);
            resp.sendRedirect(ctx + "/order?id=" + orderId + "&ok=" + msg);

        } catch (Exception e) {
            e.printStackTrace();
            String msg = URLEncoder.encode("Errore durante l’annullamento.", StandardCharsets.UTF_8);
            resp.sendRedirect(ctx + "/orders?err=" + msg);
        }
    }
}