package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.dao.UserDAO;
import model.dao.impl.UserDAOImpl;
import utils.PasswordUtil;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(ProfileServlet.class.getName());
    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        HttpSession session = req.getSession(false);
        User auth = (session == null) ? null : (User) session.getAttribute("authUser");
        if (auth == null) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }

        try {
            if ("updateProfile".equals(action)) {
                handleUpdateProfile(req, resp, auth, session);
                return;
            }
            if ("changePassword".equals(action)) {
                handleChangePassword(req, resp, auth, session);
                return;
            }
            if ("deactivate".equals(action)) {
                handleDeactivate(req, resp, auth, session);
                return;
            }

            resp.sendRedirect(req.getContextPath() + "/profile");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Errore profilo", e);
            req.setAttribute("profileError", "Operazione non riuscita. Riprova.");
            req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
        }
    }

    private void handleUpdateProfile(HttpServletRequest req, HttpServletResponse resp, User auth, HttpSession session)
            throws Exception {
        String firstName = req.getParameter("firstName");
        String lastName = req.getParameter("lastName");
        String phone = req.getParameter("phoneNumber");

        if (firstName == null || lastName == null || firstName.isBlank() || lastName.isBlank()) {
            req.setAttribute("profileError", "Nome e cognome sono obbligatori.");
            req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
            return;
        }

        String cleanFirst = firstName.trim();
        String cleanLast = lastName.trim();
        String cleanPhone = (phone == null) ? null : phone.trim();
        if (cleanPhone != null && cleanPhone.isBlank()) cleanPhone = null;

        if (userDAO.updateProfile(auth.getUserId(), cleanFirst, cleanLast, cleanPhone)) {
            auth.setFirstName(cleanFirst);
            auth.setLastName(cleanLast);
            auth.setPhoneNumber(cleanPhone);
            session.setAttribute("authUser", auth);
            req.setAttribute("profileSuccess", "Dati profilo aggiornati.");
            req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("profileError", "Impossibile aggiornare i dati profilo.");
        req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
    }

    private void handleChangePassword(HttpServletRequest req, HttpServletResponse resp, User auth, HttpSession session)
            throws Exception {
        String current = req.getParameter("currentPassword");
        String newPass = req.getParameter("newPassword");
        String confirm = req.getParameter("confirmPassword");

        if (current == null || newPass == null || confirm == null ||
            current.isBlank() || newPass.isBlank() || confirm.isBlank()) {
            req.setAttribute("profileError", "Compila tutti i campi password.");
            req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
            return;
        }

        if (!PasswordUtil.matches(current, auth.getPassword())) {
            req.setAttribute("profileError", "Password attuale non corretta.");
            req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
            return;
        }

        if (!newPass.equals(confirm)) {
            req.setAttribute("profileError", "Le nuove password non coincidono.");
            req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
            return;
        }

        if (!isStrongPassword(newPass)) {
            req.setAttribute("profileError", "La nuova password deve avere almeno 8 caratteri, 1 lettera e 1 numero.");
            req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
            return;
        }

        String hashed = PasswordUtil.hash(newPass);
        if (userDAO.updatePassword(auth.getUserId(), hashed)) {
            auth.setPassword(hashed);
            session.setAttribute("authUser", auth);
            req.setAttribute("profileSuccess", "Password aggiornata correttamente.");
            req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("profileError", "Impossibile aggiornare la password.");
        req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
    }

    private void handleDeactivate(HttpServletRequest req, HttpServletResponse resp, User auth, HttpSession session)
            throws Exception {
        if (!userDAO.deactivateById(auth.getUserId())) {
            req.setAttribute("profileError", "Impossibile disattivare l'account.");
            req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
            return;
        }

        session.invalidate();
        resp.sendRedirect(req.getContextPath() + "/views/login.jsp?deactivated=1");
    }

    private boolean isStrongPassword(String p) {
        return p != null && p.matches("^(?=.*[A-Za-z])(?=.*\\d).{8,}$");
    }
}
