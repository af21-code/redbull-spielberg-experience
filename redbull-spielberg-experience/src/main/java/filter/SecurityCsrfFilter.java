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

    // Metodi considerati "safe" (niente verifica CSRF)
    private static final Set<String> SAFE_METHODS = Set.of("GET", "HEAD", "OPTIONS", "TRACE");

    // Endpoint da escludere (login/registrazione ecc. — adatta ai tuoi path reali se servono)
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
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String ctx = req.getContextPath();
        String uri = req.getRequestURI();
        String path = uri.substring(ctx.length()); // es: /checkout/confirm

        HttpSession session = req.getSession(true);

        // Genera token se mancante (requisito: token in sessione)
        String token = (String) session.getAttribute("csrfToken");
        if (token == null || token.isEmpty()) {
            token = UUID.randomUUID().toString();
            session.setAttribute("csrfToken", token);
        }

        // Rendilo disponibile alle JSP (EL ${csrfToken} o request.getAttribute)
        req.setAttribute("csrfToken", token);

        // Salta verifica per metodi "safe"
        String method = req.getMethod();
        if (SAFE_METHODS.contains(method)) {
            chain.doFilter(request, response);
            return;
        }

        // Salta statici
        if (path.startsWith("/styles/") || path.startsWith("/scripts/") ||
            path.startsWith("/images/") || path.startsWith("/favicon")) {
            chain.doFilter(request, response);
            return;
        }

        // Salta whitelist (adatta se necessario)
        if (WHITELIST.contains(path)) {
            chain.doFilter(request, response);
            return;
        }

        // Verifica token nei POST/PUT/DELETE
        String formToken = req.getParameter("csrf");
        if (formToken == null || !formToken.equals(token)) {
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