package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Product;
import model.dao.ProductDAO;
import model.dao.impl.ProductDAOImpl;

import java.io.IOException;

@WebServlet(urlPatterns = {"/admin/products/new", "/admin/products/edit"})
public class AdminProductFormServlet extends HttpServlet {

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

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (!isAdmin(session)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // Espongo il token CSRF al JSP (in aggiunta al meta di header.jsp)
        String csrf = (String) (session != null ? session.getAttribute("csrfToken") : null);
        if (csrf == null || csrf.isBlank()) {
            csrf = java.util.UUID.randomUUID().toString();
            if (session != null) session.setAttribute("csrfToken", csrf);
        }
        req.setAttribute("csrfToken", csrf);

        String servletPath = req.getServletPath(); // /admin/products/new oppure /admin/products/edit
        ProductDAO dao = new ProductDAOImpl();

        try {
            if (servletPath.endsWith("/new")) {
                // Nuovo prodotto: preparo un bean vuoto con alcuni default
                Product p = new Product();
                p.setActive(true);
                p.setFeatured(false);
                p.setPrice(java.math.BigDecimal.ZERO);
                req.setAttribute("product", p);
            } else {
                // Edit: carico da DB tramite ?id=...
                String idStr = req.getParameter("id");
                if (idStr == null || idStr.isBlank()) {
                    resp.sendRedirect(req.getContextPath() + "/admin/products?err=ID%20mancante");
                    return;
                }
                int id;
                try {
                    id = Integer.parseInt(idStr.trim());
                } catch (NumberFormatException e) {
                    resp.sendRedirect(req.getContextPath() + "/admin/products?err=ID%20non%20valido");
                    return;
                }
                Product p = dao.adminFindById(id);
                if (p == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/products?err=Prodotto%20inesistente");
                    return;
                }
                req.setAttribute("product", p);
            }

            // Forward al form JSP
            req.getRequestDispatcher("/views/admin/product-form.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/products?err=" +
                    urlEncode("Errore nel caricamento del form: " + e.getMessage()));
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