package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.dao.ProductDAO;
import model.dao.impl.ProductDAOImpl;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

@WebServlet(urlPatterns = "/admin/products/toggle")
public class AdminProductToggleServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private boolean isAdmin(HttpSession session) {
        if (session == null) return false;
        Object u = session.getAttribute("authUser");
        if (u == null) return false;
        try {
            Object t = u.getClass().getMethod("getUserType").invoke(u);
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

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req.getSession(false))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (!checkCsrf(req)) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "CSRF token mancante/non valido");
            return;
        }

        String idStr = req.getParameter("id");
        String what  = req.getParameter("what");      // "active" | "featured"
        String value = req.getParameter("value");     // "true"/"false" oppure "1"/"0"

        String back = req.getHeader("Referer");
        if (back == null || back.isBlank()) back = req.getContextPath() + "/admin/products";

        try {
            int id = Integer.parseInt(idStr);
            boolean val = "1".equals(value) || "true".equalsIgnoreCase(value);

            ProductDAO dao = new ProductDAOImpl();
            if ("active".equalsIgnoreCase(what)) {
                dao.setActive(id, val);
                resp.sendRedirect(backWith(back, "ok", "Stato attivo aggiornato"));
            } else if ("featured".equalsIgnoreCase(what)) {
                dao.setFeatured(id, val);
                resp.sendRedirect(backWith(back, "ok", "Featured aggiornato"));
            } else {
                resp.sendRedirect(backWith(back, "err", "Parametro what non valido"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(backWith(back, "err", "Errore: " + e.getMessage()));
        }
    }

    private String backWith(String url, String k, String v) {
        String sep = url.contains("?") ? "&" : "?";
        String enc = java.net.URLEncoder.encode(v, StandardCharsets.UTF_8);
        return url + sep + k + "=" + enc;
    }
}