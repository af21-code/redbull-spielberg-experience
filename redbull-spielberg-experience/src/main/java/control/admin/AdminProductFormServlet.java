package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Product;
import model.Category;
import model.dao.ProductDAO;
import model.dao.CategoryDAO;
import model.dao.impl.ProductDAOImpl;
import model.dao.impl.CategoryDAOImpl;

import utils.SecurityUtils;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = "/admin/products/edit")
public class AdminProductFormServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (!SecurityUtils.isAdmin(s)) {
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

        // Carica categorie per la tendina (ordiniamo per nome asc)
        try {
            CategoryDAO cdao = new CategoryDAOImpl();
            // riuso del metodo paginato: q=null, onlyInactive=false, sort=name, dir=asc,
            // limit=1000, offset=0
            List<Category> categories = cdao.adminFindAllPaged(null, false, "name",
                    "asc", 1000, 0);
            req.setAttribute("categories", categories);
        } catch (Exception e) {
            // non blocchiamo il form: in casi estremi la tendina sarà vuota
            e.printStackTrace();
            req.setAttribute("categories", java.util.Collections.emptyList());
        }

        req.setAttribute("product", p);
        req.getRequestDispatcher("/views/admin/product-form.jsp").forward(req, resp);
    }
}