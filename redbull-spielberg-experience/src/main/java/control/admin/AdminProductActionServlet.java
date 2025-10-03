package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Product;
import model.dao.ProductDAO;
import model.dao.impl.ProductDAOImpl;

import java.io.IOException;

@WebServlet(urlPatterns = "/admin/products/action")
public class AdminProductActionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private boolean isAdmin(HttpSession session) {
        if (session == null) return false;
        Object authUser = session.getAttribute("authUser");
        if (authUser == null) return false;
        try {
            Object t = authUser.getClass().getMethod("getUserType").invoke(authUser);
            return t != null && "ADMIN".equalsIgnoreCase(String.valueOf(t));
        } catch (Exception ignored) {
            return false;
        }
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
        String idStr  = req.getParameter("id");
        if (action == null || action.isBlank() || idStr == null || idStr.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Parametri mancanti");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException nfe) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID non valido");
            return;
        }

        ProductDAO dao = new ProductDAOImpl();
        String redirectBase = req.getContextPath() + "/admin/products";

        try {
            switch (action) {
                case "toggleActive": {
                    Product p = dao.adminFindById(id);
                    if (p == null) throw new IllegalStateException("Prodotto non trovato");
                    dao.setActive(id, !Boolean.TRUE.equals(p.getActive()));
                    resp.sendRedirect(redirectBase + "?ok=Stato%20aggiornato");
                    return;
                }
                case "toggleFeatured": {
                    Product p = dao.adminFindById(id);
                    if (p == null) throw new IllegalStateException("Prodotto non trovato");
                    dao.setFeatured(id, !Boolean.TRUE.equals(p.getFeatured()));
                    resp.sendRedirect(redirectBase + "?ok=Featured%20aggiornato");
                    return;
                }
                case "delete": {
                    dao.softDelete(id);
                    resp.sendRedirect(redirectBase + "?ok=Prodotto%20disattivato");
                    return;
                }
                case "activate": {
                    dao.setActive(id, true);
                    resp.sendRedirect(redirectBase + "?ok=Prodotto%20attivato");
                    return;
                }
                case "deactivate": {
                    dao.setActive(id, false);
                    resp.sendRedirect(redirectBase + "?ok=Prodotto%20disattivato");
                    return;
                }
                default:
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Azione non supportata");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(redirectBase + "?err=" + urlEncode("Errore: " + e.getMessage()));
        }
    }

    private String urlEncode(String s) {
        try {
            return java.net.URLEncoder.encode(s, java.nio.charset.StandardCharsets.UTF_8.name());
        } catch (Exception e) {
            return s;
        }
    }
}