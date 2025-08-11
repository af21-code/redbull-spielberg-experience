package control;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.User;
import model.dao.UserDAO;
import model.dao.impl.UserDAOImpl;

public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAOImpl();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = new User();
        user.setFirstName(request.getParameter("firstName"));
        user.setLastName(request.getParameter("lastName"));
        user.setEmail(request.getParameter("email"));
        user.setPhoneNumber(request.getParameter("phoneNumber"));
        user.setPassword(request.getParameter("password"));

        if (userDAO.emailExists(user.getEmail())) {
            request.setAttribute("errorMessage", "Email already registered");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        } else {
            userDAO.save(user);
            response.sendRedirect("login.jsp");
        }
    }
}