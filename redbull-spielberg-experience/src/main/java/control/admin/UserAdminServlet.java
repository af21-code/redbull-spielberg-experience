package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import model.User;
import model.dao.AdminUserDAO;
import model.dao.impl.AdminUserDAOImpl;

import java.io.IOException;
import java.util.List;

public class UserAdminServlet extends HttpServlet {

    private final AdminUserDAO userDAO = new AdminUserDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String q    = req.getParameter("q");
            String type = req.getParameter("type"); // VISITOR | REGISTERED | PREMIUM | ADMIN
            Boolean onlyInactive = "1".equals(req.getParameter("onlyInactive"));
            List<User> users = userDAO.adminFindAll(q, type, onlyInactive);
            req.setAttribute("users", users);
            req.getRequestDispatcher("/views/admin/users.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        try {
            switch (path) {
                case "/admin/users/toggle" -> toggleActive(req, resp);
                case "/admin/users/role"   -> changeRole(req, resp);
                default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void toggleActive(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        boolean active = "1".equals(req.getParameter("active"));
        userDAO.setActive(id, active);
        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }

    private void changeRole(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        String role = req.getParameter("role"); // VISITOR | REGISTERED | PREMIUM | ADMIN
        userDAO.updateUserType(id, role);
        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }
}