<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8" />
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

      <form class="login-form need-validate" action="${pageContext.request.contextPath}/login" method="post" novalidate>
        <!-- CSRF opzionale (login è whitelisted, ma lo includiamo per coerenza) -->
        <input type="hidden" name="csrf" value="${csrfToken}"/>

        <label for="login_email">Email</label>
        <input id="login_email" class="input"
               type="email" name="email"
               placeholder="MaxVerstappen@example.com"
               required
               data-validate="required|email" />
        <small data-error-for="login_email" class="form-error"></small>

        <label for="login_password">Password</label>
        <input id="login_password" class="input"
               type="password" name="password"
               placeholder="••••••••"
               required
               data-validate="required|password" />
        <small data-error-for="login_password" class="form-error"></small>

        <button class="btn-primary" type="submit">Sign in</button>
      </form>

      <% if (request.getAttribute("errorMessage") != null) { %>
        <div class="form-error" style="margin-top:10px;"><%= request.getAttribute("errorMessage") %></div>
      <% } %>

      <div class="divider"></div>
      <div class="actions">
        <a href="${pageContext.request.contextPath}/views/register.jsp">Registrati qui</a>
        <a href="#">Password Dimenticata?</a>
      </div>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/scripts/validate.js"></script>
</body>
</html>