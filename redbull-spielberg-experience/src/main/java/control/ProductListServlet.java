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

        String categoryParam = req.getParameter("category");
        Integer categoryId = null;
        if (categoryParam != null && !categoryParam.isBlank()) {
            try {
                categoryId = Integer.parseInt(categoryParam);
            } catch (NumberFormatException ignored) {}
        }

        try {
            List<Product> products = productDAO.findAll(categoryId);
            req.setAttribute("products", products);

            // forward alla JSP
            req.getRequestDispatcher("/views/shop.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            // in caso di errore, puoi reindirizzare a 500
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore nel caricamento prodotti");
        }
    }
}