package control;

import model.User;
import model.dao.UserDAO;
import model.dao.impl.UserDAOImpl;
import utils.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(RegisterServlet.class.getName());
    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        final String firstNameRaw = req.getParameter("firstName");
        final String lastNameRaw  = req.getParameter("lastName");
        final String emailRaw     = req.getParameter("email");
        final String phoneRaw     = req.getParameter("phoneNumber");
        final String password     = req.getParameter("password");
        final String confirm      = req.getParameter("confirmPassword");

        final String firstName = (firstNameRaw == null) ? null : firstNameRaw.trim();
        final String lastName  = (lastNameRaw == null) ? null : lastNameRaw.trim();
        final String email     = (emailRaw == null) ? null : emailRaw.trim().toLowerCase();
        final String phone     = (phoneRaw == null) ? null : phoneRaw.trim();

        if (firstName == null || lastName == null || email == null || password == null || confirm == null ||
            firstName.isBlank() || lastName.isBlank() || email.isBlank() || password.isBlank() || confirm.isBlank()) {
            req.setAttribute("errorMessage", "Compila tutti i campi obbligatori.");
            req.getRequestDispatcher("/views/register.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirm)) {
            req.setAttribute("errorMessage", "Le password non coincidono.");
            req.getRequestDispatcher("/views/register.jsp").forward(req, resp);
            return;
        }

        try {
            if (userDAO.existsByEmail(email)) {
                req.setAttribute("errorMessage", "Email già registrata.");
                req.getRequestDispatcher("/views/register.jsp").forward(req, resp);
                return;
            }

            User u = new User();
            u.setEmail(email);
            u.setPassword(PasswordUtil.hash(password)); // PBKDF2
            u.setFirstName(firstName);
            u.setLastName(lastName);
            u.setPhoneNumber(phone);
            u.setUserType(User.UserType.REGISTERED);

            userDAO.save(u);

            // Autologin sicuro: ruota l'ID di sessione per prevenire session fixation
            final HttpSession session = req.getSession(true);
            req.changeSessionId();
            session.setAttribute("authUser", u);
            session.setAttribute("accessToken", "OK");

            resp.sendRedirect(req.getContextPath() + "/index.jsp");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Errore durante la registrazione", e);
            req.setAttribute("errorMessage", "Errore durante la registrazione. Riprova.");
            req.getRequestDispatcher("/views/register.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/views/register.jsp").forward(req, resp);
    }
}