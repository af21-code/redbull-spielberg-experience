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

      <form class="register-form" action="${pageContext.request.contextPath}/register" method="post">
        <label>Nome</label>
        <input class="input" type="text" name="firstName" required />

        <label>Cognome</label>
        <input class="input" type="text" name="lastName" required />

        <label>Email</label>
        <input class="input" type="email" name="email" required />

        <label>Telefono</label>
        <input class="input" type="text" name="phoneNumber" />

        <label>Password</label>
        <input class="input" type="password" name="password" required />

        <label>Conferma Password</label>
        <input class="input" type="password" name="confirmPassword" required />

        <button class="btn-primary" type="submit">Create account</button>
      </form>

      <% if (request.getAttribute("errorMessage") != null) { %>
        <div class="form-error"><%= request.getAttribute("errorMessage") %></div>
      <% } %>

      <div class="divider"></div>
      <div class="actions">
        <a href="${pageContext.request.contextPath}/views/login.jsp">Hai già un account? Accedi</a>
      </div>
    </div>
  </div>
</body>
</html>