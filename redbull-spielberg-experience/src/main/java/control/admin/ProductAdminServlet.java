package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Product;
import model.dao.ProductDAO;
import model.dao.impl.ProductDAOImpl;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(urlPatterns = {
        "/admin/products",
        "/admin/products/edit",
        "/admin/products/save",
        "/admin/products/toggle",
        "/admin/products/feature",
        "/admin/products/delete"
})
public class ProductAdminServlet extends HttpServlet {
    private final ProductDAO productDAO = new ProductDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        try {
            switch (path) {
                case "/admin/products" -> list(req, resp);
                case "/admin/products/edit" -> editForm(req, resp);
                default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void list(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Integer categoryId = parseInt(req.getParameter("categoryId"));
        String q = req.getParameter("q");
        Boolean onlyInactive = "1".equals(req.getParameter("onlyInactive"));
        List<Product> products = productDAO.adminFindAll(categoryId, q, onlyInactive);
        req.setAttribute("products", products);
        req.getRequestDispatcher("/views/admin/products.jsp").forward(req, resp);
    }

    private void editForm(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Integer id = parseInt(req.getParameter("id"));
        Product p = (id != null) ? productDAO.adminFindById(id) : null;
        req.setAttribute("product", p);
        req.getRequestDispatcher("/views/admin/product-form.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        try {
            switch (path) {
                case "/admin/products/save" -> save(req, resp);
                case "/admin/products/toggle" -> toggleActive(req, resp);
                case "/admin/products/feature" -> toggleFeatured(req, resp);
                case "/admin/products/delete" -> delete(req, resp);
                default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void save(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Integer id = parseInt(req.getParameter("productId"));
        Integer categoryId = parseInt(req.getParameter("categoryId"));
        String name = req.getParameter("name");
        String description = req.getParameter("description");
        String shortDescription = req.getParameter("shortDescription");
        BigDecimal price = new BigDecimal(req.getParameter("price"));
        String productType = req.getParameter("productType");     // EXPERIENCE | MERCHANDISE
        String experienceType = req.getParameter("experienceType"); // nullable
        Integer stockQuantity = parseInt(req.getParameter("stockQuantity"));
        String imageUrl = req.getParameter("imageUrl");
        boolean featured = "on".equalsIgnoreCase(req.getParameter("featured"));
        boolean active = "on".equalsIgnoreCase(req.getParameter("active"));

        Product p = new Product();
        p.setProductId(id);
        p.setCategoryId(categoryId);
        p.setName(name);
        p.setDescription(description);
        p.setShortDescription(shortDescription);
        p.setPrice(price);
        p.setProductType(productType == null ? null : Product.ProductType.valueOf(productType));
        p.setExperienceType((experienceType == null || experienceType.isBlank()) ? null : Product.ExperienceType.valueOf(experienceType));
        p.setStockQuantity(stockQuantity);
        p.setImageUrl(imageUrl);
        p.setFeatured(featured);
        p.setActive(active);

        if (id == null) productDAO.insert(p);
        else productDAO.update(p);

        resp.sendRedirect(req.getContextPath() + "/admin/products");
    }

    private void toggleActive(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        boolean active = "1".equals(req.getParameter("active"));
        productDAO.setActive(id, active);
        resp.sendRedirect(req.getContextPath() + "/admin/products");
    }

    private void toggleFeatured(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        boolean featured = "1".equals(req.getParameter("featured"));
        productDAO.setFeatured(id, featured);
        resp.sendRedirect(req.getContextPath() + "/admin/products");
    }

    private void delete(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        productDAO.softDelete(id);
        resp.sendRedirect(req.getContextPath() + "/admin/products");
    }

    private Integer parseInt(String s) {
        try { return (s == null || s.isBlank()) ? null : Integer.valueOf(s); } catch (Exception e) { return null; }
    }
}