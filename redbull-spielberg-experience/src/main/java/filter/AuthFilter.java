package filter;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

public class AuthFilter implements Filter {
  @Override
  public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
      throws IOException, ServletException {
    HttpServletRequest  r = (HttpServletRequest) req;
    HttpServletResponse s = (HttpServletResponse) res;

    Object auth = r.getSession().getAttribute("authUser");
    if (auth == null) {
      String returnTo = r.getRequestURI();
      String qs = r.getQueryString();
      if (qs != null && !qs.isBlank()) returnTo += "?" + qs;
      s.sendRedirect(r.getContextPath() + "/views/login.jsp?returnTo=" +
        URLEncoder.encode(returnTo, StandardCharsets.UTF_8));
      return;
    }
    chain.doFilter(req, res);
  }
}