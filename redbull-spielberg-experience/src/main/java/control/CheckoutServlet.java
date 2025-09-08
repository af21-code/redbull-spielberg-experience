package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

import model.CartItem;
import model.User;
import model.dao.OrderDAO;
import model.dao.impl.OrderDAOImpl;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final OrderDAO orderDAO = new OrderDAOImpl();

    @SuppressWarnings("unchecked")
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // deve essere loggato
        User auth = (User) req.getSession().getAttribute("authUser");
        if (auth == null) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }

        // deve avere articoli nel carrello
        List<CartItem> cart = (List<CartItem>) req.getSession().getAttribute("cartItems");
        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/shop");
            return;
        }

        req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
    }

    @SuppressWarnings("unchecked")
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User auth = (User) req.getSession().getAttribute("authUser");
        if (auth == null) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }

        List<CartItem> cart = (List<CartItem>) req.getSession().getAttribute("cartItems");
        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/shop");
            return;
        }

        String shipping = req.getParameter("shippingAddress");
        String billing  = req.getParameter("billingAddress");
        String notes    = req.getParameter("notes");
        String payment  = req.getParameter("paymentMethod");

        try {
            String orderNumber = orderDAO.createOrder(
                    auth.getUserId(), cart, shipping, billing, notes, payment
            );

            // svuota carrello di sessione
            req.getSession().removeAttribute("cartItems");

            // mostra pagina di successo
            req.setAttribute("orderNumber", orderNumber);
            req.getRequestDispatcher("/views/order_success.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("checkoutError", e.getMessage() == null ? "Errore durante il checkout." : e.getMessage());
            req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
        }
    }
}