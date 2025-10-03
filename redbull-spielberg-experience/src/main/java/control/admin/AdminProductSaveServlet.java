package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Product;
import model.dao.ProductDAO;
import model.dao.impl.ProductDAOImpl;

import java.io.IOException;
import java.math.BigDecimal;

@WebServlet(urlPatterns = "/admin/products/save")
public class AdminProductSaveServlet extends HttpServlet {

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

    private Integer parseIntNullable(String s) {
        try {
            if (s == null || s.isBlank()) return null;
            return Integer.valueOf(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private BigDecimal parseMoney(String s) {
        try {
            if (s == null || s.isBlank()) return null;
            return new BigDecimal(s.trim());
        } catch (Exception e) {
            return null;
        }
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

        // ----- leggi parametri -----
        String productIdStr      = req.getParameter("productId"); // presente solo in edit
        String name              = req.getParameter("name");
        String categoryIdStr     = req.getParameter("categoryId");
        String productTypeStr    = req.getParameter("productType");
        String experienceTypeStr = req.getParameter("experienceType");
        String priceStr          = req.getParameter("price");
        String stockStr          = req.getParameter("stockQuantity");
        String shortDesc         = req.getParameter("shortDescription");
        String desc              = req.getParameter("description");
        String imageUrl          = req.getParameter("imageUrl");
        boolean featured         = (req.getParameter("featured") != null);
        boolean active           = (req.getParameter("active") != null);

        // ----- validazioni base -----
        String err = null;
        if (name == null || name.isBlank()) {
            err = "Il nome è obbligatorio.";
        }

        BigDecimal price = parseMoney(priceStr);
        if (price == null) {
            err = (err == null ? "" : err + " ") + "Prezzo non valido.";
        }

        Integer categoryId = parseIntNullable(categoryIdStr);
        Integer stockQty   = parseIntNullable(stockStr);

        Product.ProductType pType = null;
        if (productTypeStr != null && !productTypeStr.isBlank()) {
            try { pType = Product.ProductType.valueOf(productTypeStr.trim()); }
            catch (IllegalArgumentException e) { err = (err == null ? "" : err + " ") + "Tipo prodotto non valido."; }
        } else {
            err = (err == null ? "" : err + " ") + "Tipo prodotto obbligatorio.";
        }

        Product.ExperienceType eType = null;
        if (experienceTypeStr != null && !experienceTypeStr.isBlank()) {
            try { eType = Product.ExperienceType.valueOf(experienceTypeStr.trim()); }
            catch (IllegalArgumentException ignored) { /* opzionale */ }
        }

        // In MERCHANDISE lo stock può esserci; in EXPERIENCE lo ignoriamo
        if (pType == Product.ProductType.EXPERIENCE) {
            stockQty = null;
        }

        // Se errori, ritorna al form
        if (err != null) {
            Product p = new Product();
            p.setProductId(productIdStr == null || productIdStr.isBlank() ? null : Integer.valueOf(productIdStr));
            p.setName(name);
            p.setCategoryId(categoryId);
            p.setProductType(pType);
            p.setExperienceType(eType);
            p.setPrice(price == null ? BigDecimal.ZERO : price);
            p.setStockQuantity(stockQty);
            p.setShortDescription(shortDesc);
            p.setDescription(desc);
            p.setImageUrl(imageUrl);
            p.setFeatured(featured);
            p.setActive(active);

            req.setAttribute("product", p);
            req.setAttribute("err", err);
            req.getRequestDispatcher("/views/admin/product-form.jsp").forward(req, resp);
            return;
        }

        // ----- persistenza -----
        ProductDAO dao = new ProductDAOImpl();
        Product p = new Product();
        p.setName(name);
        p.setCategoryId(categoryId);
        p.setProductType(pType);
        p.setExperienceType(eType);
        p.setPrice(price);
        p.setStockQuantity(stockQty);
        p.setShortDescription(shortDesc);
        p.setDescription(desc);
        p.setImageUrl(imageUrl);
        p.setFeatured(featured);
        p.setActive(active);

        boolean isEdit = (productIdStr != null && !productIdStr.isBlank());
        try {
            if (isEdit) {
                p.setProductId(Integer.parseInt(productIdStr));
                dao.update(p);
                resp.sendRedirect(req.getContextPath() + "/admin/products?ok=Prodotto%20aggiornato");
            } else {
                int newId = dao.insert(p);
                resp.sendRedirect(req.getContextPath() + "/admin/products?ok=Prodotto%20creato&id=" + newId);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("product", p);
            req.setAttribute("err", "Errore durante il salvataggio: " + e.getMessage());
            req.getRequestDispatcher("/views/admin/product-form.jsp").forward(req, resp);
        }
    }
}