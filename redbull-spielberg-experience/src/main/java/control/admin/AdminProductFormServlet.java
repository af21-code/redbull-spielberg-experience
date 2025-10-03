package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Product;
import model.dao.ProductDAO;
import model.dao.impl.ProductDAOImpl;

import java.io.IOException;

@WebServlet(urlPatterns = "/admin/products/edit")
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

        HttpSession s = req.getSession(false);
        if (!isAdmin(s)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String idStr = req.getParameter("id");
        Product p;

        if (idStr != null && !idStr.isBlank()) {
            // ===== EDIT =====
            try {
                int id = Integer.parseInt(idStr.trim());
                ProductDAO dao = new ProductDAOImpl();
                p = dao.adminFindById(id);
                if (p == null) {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Prodotto non trovato");
                    return;
                }
            } catch (NumberFormatException e) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID non valido");
                return;
            } catch (Exception e) {
                throw new ServletException("Errore nel caricamento del prodotto", e);
            }
        } else {
            // ===== NEW =====
            p = new Product();
            p.setActive(true);
            p.setFeatured(false);
            p.setStockQuantity(null); // per EXPERIENCE verrà ignorato
        }

        req.setAttribute("product", p);
        req.getRequestDispatcher("/views/admin/product-form.jsp").forward(req, resp);
    }
}