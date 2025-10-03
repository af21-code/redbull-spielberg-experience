package filter;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

public class AuthFilter implements Filter {

  private static boolean isPublicBookingApi(HttpServletRequest r) {
    String path = r.getRequestURI().substring(r.getContextPath().length());
    // mai forzare il login sulle API pubbliche in GET
    if (!"GET".equalsIgnoreCase(r.getMethod())) return false;
    return "/booking/availability".equals(path) || "/booking/slots".equals(path);
  }

  @Override
  public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
      throws IOException, ServletException {
    HttpServletRequest  r = (HttpServletRequest) req;
    HttpServletResponse s = (HttpServletResponse) res;

    // Bypass totale per le API booking pubbliche
    if (isPublicBookingApi(r)) {
      chain.doFilter(req, res);
      return;
    }

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