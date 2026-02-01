<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%! // Escape HTML semplice, senza dipendenze esterne
    @SuppressWarnings("unused") private static String esc(Object o)
    { if (o==null) return "" ; String s=String.valueOf(o); return s.replace("&","&amp;").replace("<","&lt;").replace("> ","&gt;")
    .replace("\"","&quot;").replace("'","&#39;");
    }
    %>
    <!DOCTYPE html>
    <html lang="it">

    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <title>Login - RedBull Spielberg Experience</title>
      <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/login.css" />
    </head>

    <body class="page-login">

      <div class="home-btn">
        <a href="${pageContext.request.contextPath}/index.jsp">← Home</a>
      </div>

      <div class="login-wrap">
        <div class="login-card">
          <div class="brand">
            <img src="https://cdn-3.motorsport.com/images/mgl/Y99JQRbY/s8/red-bull-racing-logo-1.jpg" alt="Red Bull" />
            <h1>Login</h1>
          </div>
          <p class="subtitle">Accedi al mondo RedBull</p>

          <form class="login-form" id="login-form" action="${pageContext.request.contextPath}/login" method="post"
            novalidate>
            <!-- CSRF (se impostato dal filtro/servlet) -->
            <input type="hidden" name="csrf" value="${csrfToken}" />

            <label for="login_email">Email</label>
            <input class="input" id="login_email" type="email" name="email" placeholder="MaxVerstappen@example.com"
              required autocomplete="email" />
            <div class="error-msg" aria-live="polite"></div>

            <label for="login_password">Password</label>
            <input class="input" id="login_password" type="password" name="password" placeholder="••••••••" required
              autocomplete="current-password" />
            <div class="error-msg" aria-live="polite"></div>

            <button class="btn-primary" type="submit">Sign in</button>
          </form>

          <% Object em=request.getAttribute("errorMessage"); if (em !=null) { %>
            <div class="form-error">
              <%= esc(em) %>
            </div>
            <% } %>

              <div class="divider"></div>
              <div class="actions">
                <a href="${pageContext.request.contextPath}/views/register.jsp">Registrati qui</a>
              </div>
        </div>
      </div>

      <script src="${pageContext.request.contextPath}/scripts/auth.js?v=1"></script>
    </body>

    </html>