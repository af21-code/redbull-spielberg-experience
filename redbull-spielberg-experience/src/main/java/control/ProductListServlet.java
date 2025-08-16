package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

import model.Product;
import model.dao.ProductDAO;
import model.dao.impl.ProductDAOImpl;

@WebServlet("/shop")
public class ProductListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ProductDAO productDAO = new ProductDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer categoryId = null;
        String categoryParam = req.getParameter("category");
        if (categoryParam != null && !categoryParam.isBlank()) {
            try { categoryId = Integer.parseInt(categoryParam); } catch (NumberFormatException ignored) {}
        }

        try {
            // SOLO MERCHANDISE attivi, con categoria opzionale
            List<Product> products = productDAO.findActiveMerchandise(categoryId);
            req.setAttribute("products", products);
            req.setAttribute("selectedCategory", categoryId);

            req.getRequestDispatcher("/views/shop.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore nel caricamento prodotti");
        }
    }
}