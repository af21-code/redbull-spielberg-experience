package control;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L; // <-- AGGIUNTO

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/cart.jsp").forward(request, response);
    }
}