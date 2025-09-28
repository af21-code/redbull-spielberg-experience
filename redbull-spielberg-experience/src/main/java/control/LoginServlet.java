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

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String emailRaw = req.getParameter("email");
        String password = req.getParameter("password");

        String email = (emailRaw == null) ? null : emailRaw.trim().toLowerCase();

        if (email == null || password == null || email.isBlank() || password.isBlank()) {
            req.setAttribute("errorMessage", "Inserisci email e password.");
            req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
            return;
        }

        try {
            User u = userDAO.findByEmail(email);

            // Primo controllo: credenziali (per non rivelare se l'utente esiste)
            if (u == null || !PasswordUtil.matches(password, u.getPassword())) {
                req.setAttribute("errorMessage", "Credenziali non valide.");
                req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
                return;
            }

            // Secondo controllo: stato dell'account
            if (!u.isActive()) {
                req.setAttribute("errorMessage", "Account disattivato. Contatta l’amministratore.");
                req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
                return;
            }

            // Login OK -> session fixation protection
            HttpSession old = req.getSession(false);
            if (old != null) old.invalidate();

            HttpSession session = req.getSession(true);
            session.setAttribute("authUser", u);
            session.setAttribute("accessToken", "OK");

            // Redirect alla home (o a 'next' se un giorno vorrai gestire un ritorno)
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
        } catch (Exception e) {
            e.printStackTrace();
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