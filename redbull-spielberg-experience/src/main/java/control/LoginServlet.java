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

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(LoginServlet.class.getName());
    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        final String emailRaw = req.getParameter("email");
        final String password = req.getParameter("password");
        final String email = (emailRaw == null) ? null : emailRaw.trim().toLowerCase();

        if (email == null || password == null || email.isBlank() || password.isBlank()) {
            req.setAttribute("errorMessage", "Inserisci email e password.");
            req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
            return;
        }

        try {
            final User u = userDAO.findByEmail(email);

            // Controllo credenziali (messaggio generico per non esporre info)
            if (u == null || !PasswordUtil.matches(password, u.getPassword())) {
                req.setAttribute("errorMessage", "Credenziali non valide.");
                req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
                return;
            }

            if (!u.isActive()) {
                req.setAttribute("errorMessage", "Account disattivato. Contatta l’amministratore.");
                req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
                return;
            }

            // Protezione session fixation:
            // - Manteniamo l'eventuale sessione esistente (per non perdere il carrello ospite)
            // - Cambiamo solo l'ID della sessione dopo l'autenticazione
            final HttpSession session = req.getSession(true);
            req.changeSessionId();
            session.setAttribute("authUser", u);
            session.setAttribute("accessToken", "OK");

            // Redirect alla home
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Errore durante il login", e);
            req.setAttribute("errorMessage", "Errore durante il login. Riprova.");
            req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
    }
}