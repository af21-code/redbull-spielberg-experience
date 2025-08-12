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

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String firstName = req.getParameter("firstName");
        String lastName  = req.getParameter("lastName");
        String email     = req.getParameter("email");
        String phone     = req.getParameter("phoneNumber");
        String password  = req.getParameter("password");
        String confirm   = req.getParameter("confirmPassword");

        if (firstName == null || lastName == null || email == null || password == null || confirm == null ||
            firstName.isBlank() || lastName.isBlank() || email.isBlank() || password.isBlank() || confirm.isBlank()) {
            req.setAttribute("errorMessage", "Compila tutti i campi obbligatori.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }
        if (!password.equals(confirm)) {
            req.setAttribute("errorMessage", "Le password non coincidono.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        try {
            if (userDAO.existsByEmail(email)) {
                req.setAttribute("errorMessage", "Email già registrata.");
                req.getRequestDispatcher("/register.jsp").forward(req, resp);
                return;
            }

            User u = new User();
            u.setEmail(email);
            u.setPassword(PasswordUtil.hash(password));
            u.setFirstName(firstName);
            u.setLastName(lastName);
            u.setPhoneNumber(phone);
            u.setUserType(User.UserType.REGISTERED);
            userDAO.save(u);

            HttpSession session = req.getSession(true);
            session.setAttribute("authUser", u);
            session.setAttribute("accessToken", "OK");

            resp.sendRedirect(req.getContextPath() + "/index.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMessage", "Errore durante la registrazione. Riprova.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/register.jsp").forward(req, resp);
    }
}