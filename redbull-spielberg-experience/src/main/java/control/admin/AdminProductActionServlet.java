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

    private boolean parseBool(String s) {
        if (s == null) return false;
        String v = s.trim();
        return "1".equals(v) || "true".equalsIgnoreCase(v) || "on".equalsIgnoreCase(v)
            || "yes".equalsIgnoreCase(v) || "si".equalsIgnoreCase(v);
    }

    private static String safe(String s) { return s == null ? "" : s; }

    private static String url(String s) {
        try { return java.net.URLEncoder.encode(s, java.nio.charset.StandardCharsets.UTF_8); }
        catch (Exception e) { return ""; }
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
                    boolean active = parseBool(req.getParameter("active"));
                    dao.setActive(id, active);
                    okMsg = active ? "Prodotto attivato" : "Prodotto disattivato";
                }
                case "setFeatured" -> {
                    boolean featured = parseBool(req.getParameter("featured"));
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

            // Torna alla lista mantenendo filtri, paginazione e ordinamento
            String ctx = req.getContextPath();
            StringBuilder redir = new StringBuilder(ctx)
                    .append("/admin/products?ok=").append(url(okMsg));

            // filtri
            String q = safe(req.getParameter("q"));
            String categoryId = safe(req.getParameter("categoryId"));
            String onlyInactive = safe(req.getParameter("onlyInactive"));
            if (!q.isEmpty()) redir.append("&q=").append(url(q));
            if (!categoryId.isEmpty()) redir.append("&categoryId=").append(url(categoryId));
            if (!onlyInactive.isEmpty()) redir.append("&onlyInactive=").append(url(onlyInactive));

            // paginazione & sort (già presenti come hidden nella JSP)
            String page     = safe(req.getParameter("page"));
            String pageSize = safe(req.getParameter("pageSize"));
            String sort     = safe(req.getParameter("sort"));
            String dir      = safe(req.getParameter("dir"));

            if (!page.isEmpty())     redir.append("&page=").append(url(page));
            if (!pageSize.isEmpty()) redir.append("&pageSize=").append(url(pageSize));
            if (!sort.isEmpty())     redir.append("&sort=").append(url(sort));
            if (!dir.isEmpty())      redir.append("&dir=").append(url(dir));

            resp.sendRedirect(redir.toString());
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/products?err=" + url("Errore: " + e.getMessage()));
        }
    }
}