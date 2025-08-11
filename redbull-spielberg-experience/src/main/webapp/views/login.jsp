<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8" />
  <title>Login - RedBull Spielberg Experience</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/login.css?v=5" />
</head>
<body class="page-login">

  <!-- Pulsante Home -->
  <div class="home-btn">
    <a href="${pageContext.request.contextPath}/index.jsp" aria-label="Torna alla home">← Home</a>
  </div>

  <div class="login-wrap">
    <div class="login-card">
      <div class="brand">
        <img src="https://cdn-3.motorsport.com/images/mgl/Y99JQRbY/s8/red-bull-racing-logo-1.jpg" alt="Logo Red Bull" />
        <h1>Login</h1>
      </div>

      <p class="subtitle">Accedi al mondo Red Bull</p>

      <form class="login-form" action="${pageContext.request.contextPath}/login" method="post" autocomplete="on" novalidate>
        <label for="email">Email</label>
        <input class="input" id="email" type="email" name="email"
               placeholder="max.verstappen@example.com" required
               autocomplete="email" spellcheck="false" />

        <label for="password">Password</label>
        <input class="input" id="password" type="password" name="password"
               placeholder="••••••••" required autocomplete="current-password" />

        <button class="btn-primary" type="submit">Accedi</button>
      </form>

      <% if (request.getAttribute("errorMessage") != null) { %>
        <div class="form-error"><%= request.getAttribute("errorMessage") %></div>
      <% } %>

      <div class="divider"></div>
      <div class="actions">
        <a href="register.jsp">Registrati qui</a>
        <a href="#">Password dimenticata?</a>
      </div>
    </div>
  </div>

  <!-- Footer compatto -->
  <jsp:include page="footer.jsp" />

</body>
</html>