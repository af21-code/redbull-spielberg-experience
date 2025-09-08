package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

import model.Order;
import model.OrderItem;
import model.User;

import model.dao.OrderQueryDAO;
import model.dao.impl.OrderQueryDAOImpl;

@WebServlet("/orders")
public class OrdersServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final OrderQueryDAO orderQueryDAO = new OrderQueryDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User authUser = (User) req.getSession().getAttribute("authUser");
        if (authUser == null) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }

        boolean isAdmin = false;
        try {
            isAdmin = "ADMIN".equalsIgnoreCase(String.valueOf(authUser.getUserType()));
        } catch (Exception ignored) {}

        try {
            List<Order> orders = isAdmin
                    ? orderQueryDAO.findRecentAll(50)
                    : orderQueryDAO.findRecentByUser(authUser.getUserId(), 50);

            for (Order o : orders) {
                List<OrderItem> items = orderQueryDAO.findItemsByOrder(o.getOrderId());
                o.setItems(items);
            }

            req.setAttribute("orders", orders);
            req.setAttribute("isAdmin", isAdmin);
            req.getRequestDispatcher("/views/orders.jsp").forward(req, resp);
        } catch (Exception e) {
            log("Errore caricando gli ordini", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore caricando gli ordini");
        }
    }
}