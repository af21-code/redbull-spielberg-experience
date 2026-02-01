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
      <title>Register - RedBull Spielberg Experience</title>
      <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/register.css" />
    </head>

    <body class="page-register">

      <div class="home-btn">
        <a href="${pageContext.request.contextPath}/index.jsp">← Home</a>
      </div>

      <div class="register-wrap">
        <div class="register-card">
          <div class="brand">
            <img src="https://cdn-3.motorsport.com/images/mgl/Y99JQRbY/s8/red-bull-racing-logo-1.jpg" alt="Red Bull" />
            <h1>Registrati</h1>
          </div>
          <p class="subtitle">Entra nel team Red Bull</p>

          <form class="register-form" id="register-form" action="${pageContext.request.contextPath}/register"
            method="post" novalidate>
            <!-- CSRF (se impostato dal filtro/servlet) -->
            <input type="hidden" name="csrf" value="${csrfToken}" />

            <label for="reg_firstName">Nome</label>
            <input class="input" id="reg_firstName" type="text" name="firstName" required autocomplete="given-name" />
            <div class="error-msg" aria-live="polite"></div>

            <label for="reg_lastName">Cognome</label>
            <input class="input" id="reg_lastName" type="text" name="lastName" required autocomplete="family-name" />
            <div class="error-msg" aria-live="polite"></div>

            <label for="reg_email">Email</label>
            <input class="input" id="reg_email" type="email" name="email" required autocomplete="email" />
            <div class="error-msg" aria-live="polite"></div>

            <label for="reg_phone">Telefono</label>
            <input class="input" id="reg_phone" type="text" name="phoneNumber" autocomplete="tel" />
            <div class="error-msg" aria-live="polite"></div>

            <label for="reg_password">Password</label>
            <input class="input" id="reg_password" type="password" name="password" required
              autocomplete="new-password" />
            <div class="error-msg" aria-live="polite"></div>

            <label for="reg_confirm">Conferma Password</label>
            <input class="input" id="reg_confirm" type="password" name="confirmPassword" required
              autocomplete="new-password" />
            <div class="error-msg" aria-live="polite"></div>

            <button class="btn-primary" type="submit">Create account</button>
          </form>

          <% Object em=request.getAttribute("errorMessage"); if (em !=null) { %>
            <div class="form-error">
              <%= esc(em) %>
            </div>
            <% } %>

              <div class="divider"></div>
              <div class="actions">
                <a href="${pageContext.request.contextPath}/views/login.jsp">Hai già un account? Accedi</a>
              </div>
        </div>
      </div>

      <script src="${pageContext.request.contextPath}/scripts/auth.js?v=1"></script>
    </body>

    </html>