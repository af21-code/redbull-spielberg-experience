package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;

import model.CartItem;
import model.dao.CartDAO;
import model.dao.impl.CartDAOImpl;

import java.io.IOException;
import java.util.List;

/**
 * Calcola il numero articoli nel carrello e lo espone come request attribute "cartCount".
 * Ora ignora esplicitamente le API pubbliche di booking (availability/slots) per evitare
 * qualsiasi side-effect su sessione/DB che può interferire con le chiamate AJAX anonime.
 */
@WebFilter("/*")
public class CartBadgeFilter implements Filter {

  private static boolean isStatic(HttpServletRequest r) {
    String uri = r.getRequestURI();
    String ctx = r.getContextPath();
    if (uri == null) return true;
    if (uri.endsWith(".css") || uri.endsWith(".js") || uri.endsWith(".png") ||
        uri.endsWith(".jpg") || uri.endsWith(".jpeg") || uri.endsWith(".gif") ||
        uri.endsWith(".svg") || uri.endsWith(".ico") || uri.endsWith(".webp")) return true;
    return uri.startsWith(ctx + "/images")
        || uri.startsWith(ctx + "/styles")
        || uri.startsWith(ctx + "/scripts")
        || uri.startsWith(ctx + "/sounds");
  }

  private static boolean isPublicBookingApi(HttpServletRequest r) {
    String path = r.getRequestURI().substring(r.getContextPath().length());
    return "/booking/availability".equals(path) || "/booking/slots".equals(path);
  }

  @Override
  public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
      throws IOException, ServletException {

    HttpServletRequest r = (HttpServletRequest) req;

    // Salta statici e API booking pubbliche (più snelle e sicure)
    if (isStatic(r) || isPublicBookingApi(r)) {
      chain.doFilter(req, res);
      return;
    }

    int cartCount = 0;

    HttpSession session = r.getSession(false);
    if (session != null) {
      // 1) Se in sessione c'è già la lista, usa quella
      @SuppressWarnings("unchecked")
      List<CartItem> sessionCart = (List<CartItem>) session.getAttribute("cartItems");
      if (sessionCart != null && !sessionCart.isEmpty()) {
        for (CartItem it : sessionCart) {
          cartCount += Math.max(1, it.getQuantity());
        }
      } else {
        // 2) Se utente loggato ma cartItems non presente, prendi dal DB
        Object authUser = session.getAttribute("authUser");
        if (authUser != null) {
          Integer userId = null;
          try {
            userId = (Integer) authUser.getClass().getMethod("getUserId").invoke(authUser);
          } catch (Exception ignored) { /* niente */ }

          if (userId != null) {
            try {
              CartDAO dao = new CartDAOImpl(); // usa connection interna
              List<CartItem> dbItems = dao.findByUser(userId);
              for (CartItem it : dbItems) {
                cartCount += Math.max(1, it.getQuantity());
              }
            } catch (Exception e) {
              // Non rompere la pagina per errori badge
              e.printStackTrace();
            }
          }
        }
      }
    }

    // Esponi il conteggio per l'header
    r.setAttribute("cartCount", cartCount);

    chain.doFilter(req, res);
  }
}