package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import model.CartItem;
import model.dao.CartDAO;
import model.dao.impl.CartDAOImpl;

import java.io.IOException;
import java.util.List;

@WebFilter("/*")
public class CartSyncFilter implements Filter {

    private static final String[] STATIC_PREFIXES = {
            "/styles/", "/scripts/", "/images/", "/sounds/", "/favicon", "/resources/"
    };

    private boolean isStatic(String path) {
        if (path == null) return true;
        for (String p : STATIC_PREFIXES) if (path.startsWith(p)) return true;
        return path.endsWith(".css") || path.endsWith(".js") || path.endsWith(".png")
                || path.endsWith(".jpg") || path.endsWith(".jpeg") || path.endsWith(".gif")
                || path.endsWith(".svg") || path.endsWith(".ico") || path.endsWith(".webp");
    }

    private boolean isPublicBookingApi(HttpServletRequest r) {
        String path = r.getRequestURI().substring(r.getContextPath().length());
        return "/booking/availability".equals(path) || "/booking/slots".equals(path);
    }

    @SuppressWarnings("unchecked")
    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest r = (HttpServletRequest) req;
        String servletPath = r.getServletPath();

        // Salta statici e API booking pubbliche per non toccare la sessione durante le chiamate AJAX anonime
        if (isStatic(servletPath) || isPublicBookingApi(r)) {
            chain.doFilter(req, res);
            return;
        }

        HttpSession session = r.getSession(false);
        if (session != null) {
            Object auth = session.getAttribute("authUser");
            List<CartItem> sessionCart = (List<CartItem>) session.getAttribute("cartItems");

            boolean merged = Boolean.TRUE.equals(session.getAttribute("cartMerged"));
            if (auth != null && !merged) {
                Integer userId = null;
                try { userId = (Integer) auth.getClass().getMethod("getUserId").invoke(auth); } catch (Exception ignored) {}
                if (userId != null) {
                    try {
                        CartDAO dao = new CartDAOImpl();
                        if (sessionCart != null && !sessionCart.isEmpty()) {
                            for (CartItem it : sessionCart) {
                                dao.upsertItem(userId, it.getProductId(), it.getSlotId(), it.getQuantity());
                            }
                        }
                        // ricarica il carrello dal DB
                        List<CartItem> dbCart = dao.findByUser(userId);

                        // SOLO se il DB ha qualcosa, sostituisco la sessione
                        if (dbCart != null && !dbCart.isEmpty()) {
                            session.setAttribute("cartItems", dbCart);
                            sessionCart = dbCart;
                        }

                        session.setAttribute("cartMerged", Boolean.TRUE);
                    } catch (Exception ignored) { /* non bloccare la richiesta per il badge */ }
                }
            }

            // Conteggio per il badge
            int count = 0;
            if (sessionCart != null) {
                for (CartItem it : sessionCart) count += Math.max(1, it.getQuantity());
            }
            req.setAttribute("cartCount", count);
        }

        chain.doFilter(req, res);
    }
}