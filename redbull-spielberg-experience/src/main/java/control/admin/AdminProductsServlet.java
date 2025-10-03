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
        catch (Exception e) { return null; }
    }

    private int clamp(int v, int min, int max) {
        return Math.max(min, Math.min(max, v));
    }

    private String safeSortBy(String s) {
        if (s == null) return "updated_at";
        switch (s) {
            case "product_id":
            case "name":
            case "price":
            case "created_at":
            case "updated_at":
            case "is_active":
            case "is_featured":
            case "stock_quantity":
                return s;
            default:
                return "updated_at";
        }
    }

    private String safeSortDir(String s) {
        return (s != null && s.equalsIgnoreCase("asc")) ? "asc" : "desc";
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (!isAdmin(s)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // --- Filtri ---
        String q = req.getParameter("q");
        Integer categoryId = parseIntNullable(req.getParameter("categoryId"));

        Boolean onlyInactive = null;
        String onlyInactiveStr = req.getParameter("onlyInactive");
        if (onlyInactiveStr != null && !onlyInactiveStr.isBlank()) {
            onlyInactive = "1".equals(onlyInactiveStr)
                        || "true".equalsIgnoreCase(onlyInactiveStr)
                        || "on".equalsIgnoreCase(onlyInactiveStr);
        }

        // --- Paging + sorting ---
        int pageSize = 12;
        Integer psParam = parseIntNullable(req.getParameter("pageSize"));
        if (psParam != null) pageSize = clamp(psParam, 5, 200);

        int page = 1;
        Integer pParam = parseIntNullable(req.getParameter("page"));
        if (pParam != null) page = Math.max(1, pParam);

        String sortBy  = safeSortBy(req.getParameter("sortBy"));
        String sortDir = safeSortDir(req.getParameter("sortDir"));

        int offset = (page - 1) * pageSize;

        try {
            ProductDAO dao = new ProductDAOImpl();

            int total = dao.adminCountAll(categoryId, q, onlyInactive);
            int totalPages = Math.max(1, (int) Math.ceil(total / (double) pageSize));
            if (page > totalPages) {
                page = totalPages;
                offset = (page - 1) * pageSize;
            }

            List<Product> products = dao.adminFindAllPaged(
                    categoryId, q, onlyInactive,
                    sortBy, sortDir,
                    offset, pageSize
            );

            // Attributi per la JSP
            req.setAttribute("products", products);
            req.setAttribute("q", q == null ? "" : q);
            req.setAttribute("categoryId", categoryId);
            req.setAttribute("onlyInactive", onlyInactive != null && onlyInactive);

            req.setAttribute("page", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("total", total);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("sortBy", sortBy);
            req.setAttribute("sortDir", sortDir);

            req.getRequestDispatcher("/views/admin/products.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore caricando i prodotti");
        }
    }
}