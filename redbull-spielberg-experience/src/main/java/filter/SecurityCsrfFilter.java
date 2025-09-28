package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Set;
import java.util.UUID;

@WebFilter("/*")
public class SecurityCsrfFilter implements Filter {

    // Metodi "safe": niente verifica CSRF
    private static final Set<String> SAFE_METHODS = Set.of("GET", "HEAD", "OPTIONS", "TRACE");

    // Statici da saltare
    private static final String[] STATIC_PREFIXES = {
            "/styles/", "/scripts/", "/images/", "/sounds/", "/favicon"
    };

    // Endpoint liberi (login ecc.) — adatta se necessario
    private static final Set<String> WHITELIST = Set.of(
            "/views/login.jsp", "/login", "/auth/login", "/auth/logout", "/register"
    );

    @Override
    public void init(FilterConfig filterConfig) { /* no-op */ }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        if (!(request instanceof HttpServletRequest) || !(response instanceof HttpServletResponse)) {
            chain.doFilter(request, response);
            return;
        }
        HttpServletRequest req  = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String ctx  = req.getContextPath();            // es: /redbull-spielberg-experience
        String uri  = req.getRequestURI();             // es: /redbull-spielberg-experience/cart/add
        String path = uri.substring(ctx.length());     // es: /cart/add

        HttpSession session = req.getSession(true);

        // Genera token se mancante (requisito: token in sessione)
        String sessionToken = (String) session.getAttribute("csrfToken");
        if (sessionToken == null || sessionToken.isEmpty()) {
            sessionToken = UUID.randomUUID().toString();
            session.setAttribute("csrfToken", sessionToken);
        }

        // Disponibile alle JSP (request scope)
        req.setAttribute("csrfToken", sessionToken);

        // Metodi safe -> passa
        String method = req.getMethod();
        if (SAFE_METHODS.contains(method)) {
            chain.doFilter(request, response);
            return;
        }

        // Statici -> passa
        for (String prefix : STATIC_PREFIXES) {
            if (path.startsWith(prefix)) {
                chain.doFilter(request, response);
                return;
            }
        }

        // Whitelist -> passa
        if (WHITELIST.contains(path)) {
            chain.doFilter(request, response);
            return;
        }

        // Verifica: accetta sia parametro form "csrf" che header "X-CSRF-Token"
        String formToken   = req.getParameter("csrf");
        String headerToken = req.getHeader("X-CSRF-Token");

        boolean ok =
                (formToken != null && formToken.equals(sessionToken)) ||
                (headerToken != null && headerToken.equals(sessionToken));

        if (!ok) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.setContentType("text/plain;charset=UTF-8");
            resp.getWriter().write("CSRF token non valido o mancante.");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() { /* no-op */ }
}