// src/main/java/filter/AdminOnlyFilter.java
package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebFilter(urlPatterns = {"/admin", "/admin/*"})
public class AdminOnlyFilter implements Filter {
  @Override
  public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
      throws IOException, ServletException {
    HttpServletRequest  r = (HttpServletRequest) req;
    HttpServletResponse s = (HttpServletResponse) res;

    Object u = r.getSession().getAttribute("authUser");
    if (u == null) { s.sendRedirect(r.getContextPath()+"/views/login.jsp"); return; }

    boolean isAdmin = false;
    try {
      Object t = u.getClass().getMethod("getUserType").invoke(u);
      isAdmin = t != null && "ADMIN".equalsIgnoreCase(String.valueOf(t));
    } catch (Exception ignored) {}

    if (!isAdmin) { s.sendError(HttpServletResponse.SC_FORBIDDEN); return; }

    chain.doFilter(req, res);
  }
}