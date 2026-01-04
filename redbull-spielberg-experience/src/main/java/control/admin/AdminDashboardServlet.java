package control.admin;

import dto.DashboardStats;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.AdminDashboardService;
import utils.SecurityUtils;

import java.io.IOException;
import java.math.BigDecimal;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = { "/admin" })
public class AdminDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final AdminDashboardService service = new AdminDashboardService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        // Solo ADMIN
        HttpSession session = req.getSession(false);
        if (!SecurityUtils.isAdmin(session)) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }

        try {
            DashboardStats s = service.getTodayStats();

            req.setAttribute("ordersToday", s.getOrdersToday());
            req.setAttribute("revenueToday", s.getRevenueToday());
            req.setAttribute("pendingCount", s.getPendingCount());
            req.setAttribute("lowStockCount", s.getLowStockCount());

        } catch (Exception e) {
            // In caso di errore, mostriamo 0 invece dei trattini
            e.printStackTrace();
            req.setAttribute("ordersToday", 0);
            req.setAttribute("revenueToday", BigDecimal.ZERO);
            req.setAttribute("pendingCount", 0);
            req.setAttribute("lowStockCount", 0);
        }

        req.getRequestDispatcher("/views/admin/dashboard.jsp").forward(req, resp);
    }
}