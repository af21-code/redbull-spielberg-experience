package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

import model.User;
import model.CartItem;
import model.dao.CartDAO;
import model.dao.impl.CartDAOImpl;

@WebServlet(urlPatterns = {"/cart", "/cart/add", "/cart/update", "/cart/remove", "/cart/clear"})
public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final CartDAO cartDAO = new CartDAOImpl();

    private User requireLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User u = (session != null) ? (User) session.getAttribute("authUser") : null;
        if (u == null) {
            // non loggato -> vai al login
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return null;
        }
        return u;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String servletPath = req.getServletPath();
        if ("/cart".equals(servletPath)) {
            User u = requireLogin(req, resp);
            if (u == null) return;
            try {
                List<CartItem> items = cartDAO.findByUser(u.getUserId());
                req.setAttribute("items", items);

                BigDecimal subtotal = items.stream()
                        .map(CartItem::getTotal)
                        .reduce(BigDecimal.ZERO, BigDecimal::add);
                req.setAttribute("subtotal", subtotal);

                req.getRequestDispatcher("/views/cart.jsp").forward(req, resp);
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore caricamento carrello");
            }
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();
        User u = requireLogin(req, resp);
        if (u == null) return;

        try {
            switch (path) {
                case "/cart/add": {
                    int productId = Integer.parseInt(req.getParameter("productId"));
                    Integer slotId = parseNullableInt(req.getParameter("slotId"));
                    int qty = parsePositiveInt(req.getParameter("quantity"), 1);
                    cartDAO.addOrIncrement(u.getUserId(), productId, slotId, qty);
                    resp.sendRedirect(req.getContextPath() + "/cart");
                    return;
                }
                case "/cart/update": {
                    int productId = Integer.parseInt(req.getParameter("productId"));
                    Integer slotId = parseNullableInt(req.getParameter("slotId"));
                    int qty = parsePositiveInt(req.getParameter("quantity"), 1);
                    cartDAO.updateQuantity(u.getUserId(), productId, slotId, qty);
                    resp.sendRedirect(req.getContextPath() + "/cart");
                    return;
                }
                case "/cart/remove": {
                    int productId = Integer.parseInt(req.getParameter("productId"));
                    Integer slotId = parseNullableInt(req.getParameter("slotId"));
                    cartDAO.removeItem(u.getUserId(), productId, slotId);
                    resp.sendRedirect(req.getContextPath() + "/cart");
                    return;
                }
                case "/cart/clear": {
                    cartDAO.clearCart(u.getUserId());
                    resp.sendRedirect(req.getContextPath() + "/cart");
                    return;
                }
                default:
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore operazione carrello");
        }
    }

    private Integer parseNullableInt(String s) {
        try {
            if (s == null || s.isBlank()) return null;
            return Integer.parseInt(s);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int parsePositiveInt(String s, int fallback) {
        try {
            int v = Integer.parseInt(s);
            return v > 0 ? v : fallback;
        } catch (NumberFormatException e) {
            return fallback;
        }
    }
}