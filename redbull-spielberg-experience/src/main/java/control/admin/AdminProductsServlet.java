package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Product;
import model.dao.ProductDAO;
import model.dao.impl.ProductDAOImpl;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = "/admin/products")
public class AdminProductsServlet extends HttpServlet {
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

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (!isAdmin(s)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String q = req.getParameter("q");
        String categoryIdStr = req.getParameter("categoryId");
        String onlyInactiveStr = req.getParameter("onlyInactive");

        Integer categoryId = null;
        if (categoryIdStr != null && !categoryIdStr.isBlank()) {
            try { categoryId = Integer.valueOf(categoryIdStr.trim()); } catch (NumberFormatException ignored) {}
        }
        Boolean onlyInactive = null;
        if (onlyInactiveStr != null && !onlyInactiveStr.isBlank()) {
            // accetta "true"/"1"/"on"
            onlyInactive = "1".equals(onlyInactiveStr) || "true".equalsIgnoreCase(onlyInactiveStr) || "on".equalsIgnoreCase(onlyInactiveStr);
        }

        try {
            ProductDAO dao = new ProductDAOImpl();
            List<Product> products = dao.adminFindAll(categoryId, q, onlyInactive);

            req.setAttribute("products", products);
            req.setAttribute("q", q == null ? "" : q);
            req.setAttribute("categoryId", categoryId);
            req.setAttribute("onlyInactive", onlyInactive != null && onlyInactive);

            req.getRequestDispatcher("/views/admin/products.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore caricando i prodotti");
        }
    }
}