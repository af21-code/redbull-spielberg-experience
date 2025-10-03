package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.Set;
import java.util.UUID;

/**
 * CSRF filter:
 * - Genera sempre un token in sessione e lo espone anche in request (csrfToken) per le JSP.
 * - Per i metodi NON safe (POST, PUT, DELETE, PATCH) verifica il token:
 *     * param "csrf" OPPURE "csrfToken", oppure header "X-CSRF-Token"
 * - Salta statici e whitelist.
 */
@WebFilter("/*")
public class SecurityCsrfFilter implements Filter {

    private static final Set<String> SAFE_METHODS = Set.of("GET", "HEAD", "OPTIONS", "TRACE");
    private static final String[] STATIC_PREFIXES = {
            "/styles/", "/scripts/", "/images/", "/sounds/", "/favicon", "/resources/"
    };
    private static final Set<String> WHITELIST = Set.of(
            "/views/login.jsp", "/login", "/auth/login", "/auth/logout", "/register"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        if (!(request instanceof HttpServletRequest) || !(response instanceof HttpServletResponse)) {
            chain.doFilter(request, response);
            return;
        }
        HttpServletRequest req  = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String ctx  = req.getContextPath();        // es: /app
        String uri  = req.getRequestURI();         // es: /app/admin/slots
        String path = uri.substring(ctx.length()); // es: /admin/slots

        // --- token in sessione + request ---
        HttpSession session = req.getSession(true);
        String sessionToken = (String) session.getAttribute("csrfToken");
        if (sessionToken == null || sessionToken.isEmpty()) {
            sessionToken = UUID.randomUUID().toString();
            session.setAttribute("csrfToken", sessionToken);
        }
        // Esponi SEMPRE alla JSP come request attribute
        req.setAttribute("csrfToken", sessionToken);

        // Metodi "safe" → ok
        String method = req.getMethod();
        if (SAFE_METHODS.contains(method)) {
            chain.doFilter(request, response);
            return;
        }

        // Statici → ok
        for (String prefix : STATIC_PREFIXES) {
            if (path.startsWith(prefix)) {
                chain.doFilter(request, response);
                return;
            }
        }

        // Whitelist → ok
        if (WHITELIST.contains(path)) {
            chain.doFilter(request, response);
            return;
        }

        // --- verifica token per POST/PUT/DELETE/PATCH ---
        String formToken   = nz(req.getParameter("csrf"));
        if (formToken.isEmpty()) formToken = nz(req.getParameter("csrfToken")); // compatibilità
        String headerToken = nz(req.getHeader("X-CSRF-Token"));

        boolean ok = (!formToken.isEmpty()  && formToken.equals(sessionToken))
                  || (!headerToken.isEmpty() && headerToken.equals(sessionToken));

        if (!ok) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.setContentType("text/plain;charset=UTF-8");
            resp.getWriter().write("CSRF token non valido o mancante.");
            return;
        }

        chain.doFilter(request, response);
    }

    private static String nz(String s){ return s==null ? "" : s.trim(); }
}