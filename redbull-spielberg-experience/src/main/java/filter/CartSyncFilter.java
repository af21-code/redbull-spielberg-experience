package filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import model.CartItem;
import model.dao.CartDAO;
import model.dao.impl.CartDAOImpl;

import java.io.IOException;
import java.util.List;

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
                        List<CartItem> dbCart = dao.findByUser(userId);
                        if (dbCart != null && !dbCart.isEmpty()) {
                            session.setAttribute("cartItems", dbCart);
                        }
                        session.setAttribute("cartMerged", Boolean.TRUE);
                    } catch (Exception ignored) {}
                }
            }
        }

        chain.doFilter(req, res);
    }
}