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

    private Integer parseIntNullable(String s) {
        try { return (s == null || s.isBlank()) ? null : Integer.valueOf(s.trim()); }
        catch (NumberFormatException e) { return null; }
    }

    private int parsePositiveOrDefault(String s, int def, int min, int max) {
        try {
            int v = Integer.parseInt(s);
            if (v < min) v = min;
            if (v > max) v = max;
            return v;
        } catch (Exception e) {
            return def;
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

        String q = req.getParameter("q");
        Integer categoryId = parseIntNullable(req.getParameter("categoryId"));
        String onlyInactiveStr = req.getParameter("onlyInactive");
        Boolean onlyInactive = null;
        if (onlyInactiveStr != null && !onlyInactiveStr.isBlank()) {
            onlyInactive = "1".equals(onlyInactiveStr) || "true".equalsIgnoreCase(onlyInactiveStr) || "on".equalsIgnoreCase(onlyInactiveStr);
        }

        // --- paginazione & sort
        int pageSize = parsePositiveOrDefault(req.getParameter("pageSize"), 12, 5, 100);
        int page = parsePositiveOrDefault(req.getParameter("page"), 1, 1, Integer.MAX_VALUE);
        String sort = req.getParameter("sort"); // name, price, stock, active, featured, created, updated, ptype, etype
        String dir  = req.getParameter("dir");  // asc|desc

        try {
            ProductDAO dao = new ProductDAOImpl();

            int total = dao.adminCount(categoryId, q, onlyInactive);
            int totalPages = Math.max(1, (int) Math.ceil(total / (double) pageSize));
            if (page > totalPages) page = totalPages;
            int offset = (page - 1) * pageSize;

            List<Product> products = dao.adminFindAllPaged(categoryId, q, onlyInactive, sort, dir, pageSize, offset);

            req.setAttribute("products", products);
            req.setAttribute("q", q == null ? "" : q);
            req.setAttribute("categoryId", categoryId);
            req.setAttribute("onlyInactive", onlyInactive != null && onlyInactive);

            req.setAttribute("page", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("total", total);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("sort", sort == null ? "" : sort);
            req.setAttribute("dir",  dir == null ? "" : dir);

            req.getRequestDispatcher("/views/admin/products.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore caricando i prodotti");
        }
    }
}