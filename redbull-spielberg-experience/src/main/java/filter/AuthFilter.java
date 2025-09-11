package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebFilter(filterName = "AuthFilter", urlPatterns = {"/orders", "/cart/*"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
        throws IOException, ServletException {

        HttpServletRequest req  = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session     = req.getSession(false);

        boolean logged = (session != null && session.getAttribute("authUser") != null);

        if (!logged) {
            String ctx = req.getContextPath();
            String back = URLEncoder.encode(req.getRequestURI(), StandardCharsets.UTF_8);
            res.sendRedirect(ctx + "/views/login.jsp?redirect=" + back);
            return;
        }

        chain.doFilter(request, response);
    }
}