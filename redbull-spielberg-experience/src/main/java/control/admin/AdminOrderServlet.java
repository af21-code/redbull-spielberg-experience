package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import model.User;
import model.dao.OrderDAO;
import model.dao.impl.OrderDAOImpl;
import utils.SecurityUtils;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminOrderServlet", urlPatterns = "/admin/order")
public class AdminOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO = new OrderDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        // --- Solo ADMIN ---
        // --- Solo ADMIN ---
        HttpSession session = req.getSession(false);
        if (!SecurityUtils.isAdmin(session)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Area riservata agli amministratori.");
            return;
        }

        String ctx = req.getContextPath();
        Integer orderId = parseInt(req.getParameter("id"));
        if (orderId == null || orderId <= 0) {
            redirectWithMsg(resp, ctx + "/admin/orders", null, "ID ordine mancante o non valido.");
            return;
        }

        try {
            Map<String, Object> header = orderDAO.findOrderHeader(orderId);
            if (header == null) {
                redirectWithMsg(resp, ctx + "/admin/orders", null, "Ordine non trovato.");
                return;
            }
            List<Map<String, Object>> items = orderDAO.findOrderItems(orderId);

            req.setAttribute("order", header);
            req.setAttribute("items", items);
            req.setAttribute("isAdmin", true);

            // Usiamo la stessa JSP di dettaglio
            req.getRequestDispatcher("/views/order-details.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            redirectWithMsg(resp, ctx + "/admin/orders", null, "Errore nel caricamento dell'ordine.");
        }
    }

    // ---------------- helpers ----------------
    private static Integer parseInt(String s) {
        try {
            return (s == null || s.isBlank()) ? null : Integer.valueOf(s.trim());
        } catch (Exception e) {
            return null;
        }
    }

    private static void redirectWithMsg(HttpServletResponse resp, String baseUrl, String ok, String err)
            throws IOException {
        StringBuilder sb = new StringBuilder(baseUrl);
        boolean first = !baseUrl.contains("?");
        if (ok != null) {
            sb.append(first ? "?" : "&")
                    .append("ok=").append(URLEncoder.encode(ok, StandardCharsets.UTF_8));
            first = false;
        }
        if (err != null) {
            sb.append(first ? "?" : "&")
                    .append("err=").append(URLEncoder.encode(err, StandardCharsets.UTF_8));
        }
        resp.sendRedirect(sb.toString());
    }
}