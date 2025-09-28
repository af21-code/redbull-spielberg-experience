<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8" />
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

      <form class="register-form need-validate" action="${pageContext.request.contextPath}/register" method="post" novalidate>
        <!-- CSRF opzionale (register è whitelisted, ma lo includiamo per coerenza) -->
        <input type="hidden" name="csrf" value="${csrfToken}"/>

        <label for="reg_first">Nome</label>
        <input id="reg_first" class="input" type="text" name="firstName" required
               data-validate="required|minlen" data-minlen="2" />
        <small data-error-for="reg_first" class="form-error"></small>

        <label for="reg_last">Cognome</label>
        <input id="reg_last" class="input" type="text" name="lastName" required
               data-validate="required|minlen" data-minlen="2" />
        <small data-error-for="reg_last" class="form-error"></small>

        <label for="reg_email">Email</label>
        <input id="reg_email" class="input" type="email" name="email" required
               data-validate="required|email" />
        <small data-error-for="reg_email" class="form-error"></small>

        <label for="reg_phone">Telefono</label>
        <input id="reg_phone" class="input" type="text" name="phoneNumber"
               data-validate="phone" />
        <small data-error-for="reg_phone" class="form-error"></small>

        <label for="reg_pass">Password</label>
        <input id="reg_pass" class="input" type="password" name="password" required
               data-validate="required|password" />
        <small data-error-for="reg_pass" class="form-error"></small>

        <label for="reg_pass2">Conferma Password</label>
        <input id="reg_pass2" class="input" type="password" name="confirmPassword" required
               data-validate="required|match" data-match="#reg_pass" />
        <small data-error-for="reg_pass2" class="form-error"></small>

        <button class="btn-primary" type="submit">Create account</button>
      </form>

      <% if (request.getAttribute("errorMessage") != null) { %>
        <div class="form-error" style="margin-top:10px;"><%= request.getAttribute("errorMessage") %></div>
      <% } %>

      <div class="divider"></div>
      <div class="actions">
        <a href="${pageContext.request.contextPath}/views/login.jsp">Hai già un account? Accedi</a>
      </div>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/scripts/validate.js"></script>
</body>
</html>