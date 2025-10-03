package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.dao.ProductDAO;
import model.dao.impl.ProductDAOImpl;

import java.io.IOException;

@WebServlet(urlPatterns = "/admin/products/action")
public class AdminProductActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // --- helpers ---
    private boolean isAdmin(HttpSession session) {
        if (session == null) return false;
        Object authUser = session.getAttribute("authUser");
        if (authUser == null) return false;
        try {
            Object t = authUser.getClass().getMethod("getUserType").invoke(authUser);
            return t != null && "ADMIN".equalsIgnoreCase(String.valueOf(t));
        } catch (Exception ignored) { return false; }
    }

    private boolean checkCsrf(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null) return false;
        String token = (String) s.getAttribute("csrfToken");
        String provided = req.getParameter("csrf");
        return token != null && token.equals(provided);
    }

    private Integer parseInt(String s) {
        try { return (s == null || s.isBlank()) ? null : Integer.valueOf(s.trim()); }
        catch (NumberFormatException e) { return null; }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (!isAdmin(session)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (!checkCsrf(req)) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "CSRF token mancante/non valido");
            return;
        }

        String action = req.getParameter("action");
        Integer id = parseInt(req.getParameter("id"));
        if (id == null || action == null || action.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Parametri non validi");
            return;
        }

        String okMsg;
        try {
            ProductDAO dao = new ProductDAOImpl();

            switch (action) {
                case "setActive" -> {
                    boolean active = "1".equals(req.getParameter("active")) ||
                                     "true".equalsIgnoreCase(req.getParameter("active")) ||
                                     "on".equalsIgnoreCase(req.getParameter("active"));
                    dao.setActive(id, active);
                    okMsg = active ? "Prodotto attivato" : "Prodotto disattivato";
                }
                case "setFeatured" -> {
                    boolean featured = "1".equals(req.getParameter("featured")) ||
                                       "true".equalsIgnoreCase(req.getParameter("featured")) ||
                                       "on".equalsIgnoreCase(req.getParameter("featured"));
                    dao.setFeatured(id, featured);
                    okMsg = featured ? "Prodotto evidenziato" : "Prodotto non più evidenziato";
                }
                case "delete" -> {
                    dao.softDelete(id);
                    okMsg = "Prodotto disattivato (soft delete)";
                }
                default -> {
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Azione non supportata");
                    return;
                }
            }

            // Torna alla lista mantenendo eventuale filtro q/category/onlyInactive
            String ctx = req.getContextPath();
            String q = safe(req.getParameter("q"));
            String categoryId = safe(req.getParameter("categoryId"));
            String onlyInactive = safe(req.getParameter("onlyInactive"));

            StringBuilder redir = new StringBuilder(ctx)
                    .append("/admin/products?ok=").append(url(okMsg));
            if (!q.isEmpty()) redir.append("&q=").append(url(q));
            if (!categoryId.isEmpty()) redir.append("&categoryId=").append(url(categoryId));
            if (!onlyInactive.isEmpty()) redir.append("&onlyInactive=").append(url(onlyInactive));

            resp.sendRedirect(redir.toString());
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/products?err=" + url("Errore: " + e.getMessage()));
        }
    }

    private static String safe(String s) { return s == null ? "" : s; }
    private static String url(String s) {
        try { return java.net.URLEncoder.encode(s, java.nio.charset.StandardCharsets.UTF_8); }
        catch (Exception e) { return ""; }
    }
}