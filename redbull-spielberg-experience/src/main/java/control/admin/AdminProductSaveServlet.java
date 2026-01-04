package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Product;
import model.dao.ProductDAO;
import model.dao.impl.ProductDAOImpl;
// import utils.FileStorage;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Set;

@WebServlet(urlPatterns = "/admin/products/save")
@MultipartConfig(fileSizeThreshold = 1_000_000, // 1MB
        maxFileSize = 5_000_000, // 5MB
        maxRequestSize = 10_000_000 // 10MB
)
public class AdminProductSaveServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Set<String> ALLOWED_CT = Set.of("image/jpeg", "image/jpg", "image/png", "image/webp");

    // ===== helpers =====
    private boolean isAdmin(HttpSession session) {
        if (session == null)
            return false;
        Object authUser = session.getAttribute("authUser");
        if (authUser == null)
            return false;
        try {
            Object t = authUser.getClass().getMethod("getUserType").invoke(authUser);
            return t != null && "ADMIN".equalsIgnoreCase(String.valueOf(t));
        } catch (Exception ignored) {
            return false;
        }
    }

    /** Se usi SecurityCsrfFilter è ridondante ma innocuo. */
    private boolean checkCsrf(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null)
            return false;
        String token = (String) s.getAttribute("csrfToken");
        String provided = nz(req.getParameter("csrf"));
        if (provided.isEmpty())
            provided = nz(req.getParameter("csrfToken"));
        if (provided.isEmpty())
            provided = nz(req.getHeader("X-CSRF-Token"));
        return token != null && token.equals(provided);
    }

    private Integer parseIntNullable(String s) {
        try {
            return (s == null || s.isBlank()) ? null : Integer.valueOf(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private BigDecimal parseMoney(String s) throws ServletException {
        try {
            if (s == null || s.isBlank())
                throw new IllegalArgumentException("missing price");
            BigDecimal v = new BigDecimal(s.replace(',', '.'));
            if (v.signum() < 0)
                throw new IllegalArgumentException("negative");
            return v;
        } catch (Exception e) {
            throw new ServletException("Prezzo non valido");
        }
    }

    private static String nz(String s) {
        return s == null ? "" : s.trim();
    }

    /** Estrae il filename dal Part (compat con diversi UA). */
    private static String getSubmittedFileName(Part part) {
        if (part == null)
            return null;
        String cd = part.getHeader("content-disposition");
        if (cd == null)
            return null;
        for (String seg : cd.split(";")) {
            String s = seg.trim();
            if (s.startsWith("filename=")) {
                String f = s.substring(s.indexOf('=') + 1).trim().replace("\"", "");
                f = f.replace("\\", "/");
                return f.substring(f.lastIndexOf('/') + 1);
            }
        }
        return null;
    }

    private void backWithError(HttpServletRequest req, HttpServletResponse resp, String msg)
            throws IOException, ServletException {

        // ricostruisci Product per ripopolare il form
        Product p = new Product();
        String productIdStr = nz(req.getParameter("productId"));
        p.setProductId(productIdStr.isEmpty() ? null : Integer.valueOf(productIdStr));
        p.setName(nz(req.getParameter("name")));
        p.setCategoryId(parseIntNullable(req.getParameter("categoryId")));
        p.setShortDescription(nz(req.getParameter("shortDescription")));
        p.setDescription(nz(req.getParameter("description")));
        try {
            p.setPrice(new BigDecimal(nz(req.getParameter("price")).replace(',', '.')));
        } catch (Exception ignored) {
        }
        try {
            p.setProductType(Product.ProductType.valueOf(nz(req.getParameter("productType")).toUpperCase()));
        } catch (Exception ignored) {
        }
        try {
            String et = nz(req.getParameter("experienceType"));
            p.setExperienceType(et.isBlank() ? null : Product.ExperienceType.valueOf(et.toUpperCase()));
        } catch (Exception ignored) {
        }
        p.setStockQuantity(parseIntNullable(req.getParameter("stockQuantity")));
        p.setImageUrl(nz(req.getParameter("imageUrl")));
        p.setFeatured("on".equalsIgnoreCase(nz(req.getParameter("featured"))));
        p.setActive("on".equalsIgnoreCase(nz(req.getParameter("active"))));

        req.setAttribute("product", p);
        req.setAttribute("err", msg);
        req.getRequestDispatcher("/views/admin/product-form.jsp").forward(req, resp);
    }

    // ===== POST =====
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

        // ---- parametri ----
        String productIdStr = nz(req.getParameter("productId"));
        String name = nz(req.getParameter("name"));
        Integer categoryId = parseIntNullable(req.getParameter("categoryId"));
        String productTypeStr = nz(req.getParameter("productType"));
        String experienceTypeStr = nz(req.getParameter("experienceType"));
        String priceStr = nz(req.getParameter("price"));
        Integer stockQty = parseIntNullable(req.getParameter("stockQuantity"));
        String shortDesc = nz(req.getParameter("shortDescription"));
        String desc = nz(req.getParameter("description"));
        String imageUrl = nz(req.getParameter("imageUrl"));
        boolean featured = req.getParameter("featured") != null;
        boolean active = req.getParameter("active") != null;

        // ---- validazioni minime ----
        if (name.isBlank()) {
            backWithError(req, resp, "Il nome è obbligatorio.");
            return;
        }

        BigDecimal price;
        try {
            price = parseMoney(priceStr);
        } catch (ServletException ex) {
            backWithError(req, resp, ex.getMessage());
            return;
        }

        Product.ProductType pType = null;
        if (!productTypeStr.isBlank()) {
            try {
                pType = Product.ProductType.valueOf(productTypeStr.trim().toUpperCase());
            } catch (IllegalArgumentException e) {
                backWithError(req, resp, "Tipo prodotto non valido.");
                return;
            }
        } else {
            backWithError(req, resp, "Tipo prodotto obbligatorio.");
            return;
        }

        Product.ExperienceType eType = null;
        if (!experienceTypeStr.isBlank()) {
            try {
                eType = Product.ExperienceType.valueOf(experienceTypeStr.trim().toUpperCase());
            } catch (IllegalArgumentException ignored) {
                /* opzionale */ }
        }

        if (pType == Product.ProductType.EXPERIENCE) {
            stockQty = null; // ignorato per experience
        } else if (stockQty != null && stockQty < 0) {
            backWithError(req, resp, "Stock non può essere negativo.");
            return;
        }

        // ---- upload immagine (opzionale) ----
        try {
            Part file = null;
            try {
                file = req.getPart("imageFile");
            } catch (IllegalStateException ignored) {
            }
            if (file != null && file.getSize() > 0) {
                String ct = nz(file.getContentType()).toLowerCase();
                if (!ALLOWED_CT.contains(ct)) {
                    backWithError(req, resp, "Formato immagine non supportato (usa JPG/PNG/WEBP).");
                    return;
                }
                // String publicUrl = FileStorage.saveProductImage(
                // getServletContext(), file.getInputStream(),
                // getSubmittedFileName(file), file.getContentType()
                // );
                // imageUrl = publicUrl; // priorità al file caricato
            }
        } catch (Exception e) {
            e.printStackTrace();
            backWithError(req, resp, "Errore durante l’upload immagine.");
            return;
        }

        // ---- costruzione entity ----
        Product p = new Product();
        if (!productIdStr.isBlank()) {
            try {
                p.setProductId(Integer.parseInt(productIdStr));
            } catch (NumberFormatException ex) {
                backWithError(req, resp, "ID non valido.");
                return;
            }
        }
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

        // ---- persistenza ----
        try {
            ProductDAO dao = new ProductDAOImpl();
            String ok;
            if (p.getProductId() == null) {
                int newId = dao.insert(p);
                ok = "Prodotto creato (ID " + newId + ")";
            } else {
                dao.update(p);
                ok = "Prodotto aggiornato";
            }
            resp.sendRedirect(req.getContextPath() + "/admin/products?ok=" +
                    java.net.URLEncoder.encode(ok, java.nio.charset.StandardCharsets.UTF_8));
        } catch (Exception e) {
            e.printStackTrace();
            backWithError(req, resp, "Errore durante il salvataggio: " + e.getMessage());
        }
    }
}