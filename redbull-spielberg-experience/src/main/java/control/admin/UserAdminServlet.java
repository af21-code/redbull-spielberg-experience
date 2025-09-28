package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import model.User;
import model.dao.AdminUserDAO;
import model.dao.impl.AdminUserDAOImpl;

import java.io.IOException;

public class UserAdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final AdminUserDAO userDAO = new AdminUserDAOImpl();

    // --- helpers ---
    private static boolean isAdmin(User u) {
        if (u == null || u.getUserType() == null) return false;
        return "ADMIN".equalsIgnoreCase(String.valueOf(u.getUserType()));
    }
    private static String nz(String s) { return s == null ? "" : s.trim(); }
    private static int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
    private static boolean validCsrf(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        String form = nz(req.getParameter("csrf"));
        String sess = (session == null) ? null : (String) session.getAttribute("csrfToken");
        return (sess != null && sess.equals(form));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // --- Accesso solo ADMIN ---
        HttpSession session = req.getSession(false);
        User auth = (session == null) ? null : (User) session.getAttribute("authUser");
        if (auth == null) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }
        if (!isAdmin(auth)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            String q    = req.getParameter("q");
            String type = req.getParameter("type"); // VISITOR | REGISTERED | PREMIUM | ADMIN
            Boolean onlyInactive = "1".equals(req.getParameter("onlyInactive"));
            var users = userDAO.adminFindAll(q, type, onlyInactive);
            req.setAttribute("users", users);
            req.getRequestDispatcher("/views/admin/users.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // --- Accesso solo ADMIN ---
        HttpSession session = req.getSession(false);
        User auth = (session == null) ? null : (User) session.getAttribute("authUser");
        if (auth == null) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }
        if (!isAdmin(auth)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // --- CSRF (ulteriore rispetto al filtro) ---
        if (!validCsrf(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF non valido");
            return;
        }

        // Con mapping /admin/users e /admin/users/*, qui usiamo PATH INFO
        String pathInfo = req.getPathInfo(); // es.: "/toggle" | "/role"
        if (pathInfo == null) pathInfo = "";

        try {
            switch (pathInfo) {
                case "/toggle" -> toggleActive(req, resp);
                case "/role"   -> changeRole(req, resp);
                default        -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void toggleActive(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int id = parseInt(req.getParameter("id"), 0);
        boolean active = "1".equals(nz(req.getParameter("active")));
        if (id <= 0) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID utente non valido");
            return;
        }
        userDAO.setActive(id, active);
        resp.sendRedirect(req.getContextPath() + "/admin/users?ok=stato%20aggiornato");
    }

    private void changeRole(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int id = parseInt(req.getParameter("id"), 0);
        String role = nz(req.getParameter("role")); // VISITOR | REGISTERED | PREMIUM | ADMIN
        if (id <= 0 || role.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Parametri non validi");
            return;
        }
        userDAO.updateUserType(id, role);
        resp.sendRedirect(req.getContextPath() + "/admin/users?ok=ruolo%20aggiornato");
    }
}