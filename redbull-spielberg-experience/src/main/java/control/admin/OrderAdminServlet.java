package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.dao.OrderDAO;
import model.dao.impl.OrderDAOImpl;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/orders")
public class OrderAdminServlet extends HttpServlet {
    private final OrderDAO orderDAO = new OrderDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        LocalDate from = parseDate(req.getParameter("from"));
        LocalDate to   = parseDate(req.getParameter("to"));
        Integer userId = parseInt(req.getParameter("userId"));

        try {
            List<Map<String,Object>> rows = orderDAO.adminList(from, to, userId);
            req.setAttribute("orders", rows);
            req.getRequestDispatcher("/views/admin/orders.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private LocalDate parseDate(String s) {
        try { return (s==null || s.isBlank()) ? null : LocalDate.parse(s); } catch (Exception e) { return null; }
    }
    private Integer parseInt(String s) {
        try { return (s==null || s.isBlank()) ? null : Integer.valueOf(s); } catch (Exception e) { return null; }
    }
}