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

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (!isAdmin(session)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (!checkCsrf(req)) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "CSRF non valido");
            return;
        }

        String action = req.getParameter("do");
        String idStr  = req.getParameter("id");

        int id;
        try { id = Integer.parseInt(idStr); }
        catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID non valido");
            return;
        }

        ProductDAO dao = new ProductDAOImpl();
        try {
            switch (action == null ? "" : action) {
                case "toggleActive": {
                    boolean active = "1".equals(req.getParameter("val")) || "true".equalsIgnoreCase(req.getParameter("val"));
                    dao.setActive(id, active);
                    break;
                }
                case "toggleFeatured": {
                    boolean featured = "1".equals(req.getParameter("val")) || "true".equalsIgnoreCase(req.getParameter("val"));
                    dao.setFeatured(id, featured);
                    break;
                }
                case "delete": {
                    dao.softDelete(id);
                    break;
                }
                default:
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Azione non valida");
                    return;
            }
            resp.sendRedirect(req.getContextPath() + "/admin/products?ok=Azione%20eseguita");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/products?err=" + e.getMessage());
        }
    }
}