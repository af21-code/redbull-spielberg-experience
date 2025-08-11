<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8" />
  <title>Register - RedBull Spielberg Experience</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/register.css?v=1" />
</head>
<body class="page-register">

  <!-- Pulsante Home -->
  <div class="home-btn">
    <a href="${pageContext.request.contextPath}/index.jsp" aria-label="Torna alla home">← Home</a>
  </div>

  <div class="register-wrap">
    <div class="register-card">
      <div class="brand">
        <img src="https://cdn-3.motorsport.com/images/mgl/Y99JQRbY/s8/red-bull-racing-logo-1.jpg" alt="Logo Red Bull" />
        <h1>Registrati</h1>
      </div>

      <p class="subtitle">Crea il tuo account</p>

      <form class="register-form" action="${pageContext.request.contextPath}/register" method="post" autocomplete="on" novalidate>
        <label for="firstName">Nome</label>
        <input class="input" id="firstName" type="text" name="firstName" placeholder="Max" required autocomplete="given-name" />

        <label for="lastName">Cognome</label>
        <input class="input" id="lastName" type="text" name="lastName" placeholder="Verstappen" required autocomplete="family-name" />

        <label for="email">Email</label>
        <input class="input" id="email" type="email" name="email" placeholder="max.verstappen@example.com" required autocomplete="email" spellcheck="false" />

        <label for="phoneNumber">Telefono (opzionale)</label>
        <input class="input" id="phoneNumber" type="tel" name="phoneNumber" placeholder="+39 333 123 4567" autocomplete="tel" />

        <label for="password">Password</label>
        <input class="input" id="password" type="password" name="password" placeholder="••••••••" required autocomplete="new-password" />

        <label for="confirmPassword">Conferma password</label>
        <input class="input" id="confirmPassword" type="password" name="confirmPassword" placeholder="••••••••" required autocomplete="new-password" />

        <button class="btn-primary" type="submit">Create account</button>
      </form>

      <% if (request.getAttribute("errorMessage") != null) { %>
        <div class="form-error"><%= request.getAttribute("errorMessage") %></div>
      <% } %>

      <div class="divider"></div>
      <div class="actions">
        <a href="login.jsp">Hai già un account? Accedi</a>
      </div>
    </div>
  </div>

  <!-- Validazione base client-side -->
  <script>
    (function(){
      const form = document.querySelector('.register-form');
      const pwd = document.getElementById('password');
      const cpw = document.getElementById('confirmPassword');

      form.addEventListener('submit', function(e){
        // min 6 char + match
        const errors = [];
        if (pwd.value.length < 6) errors.push("La password deve avere almeno 6 caratteri.");
        if (pwd.value !== cpw.value) errors.push("Le password non coincidono.");

        // mostra errori
        let box = document.querySelector('.form-error');
        if (!box) {
          box = document.createElement('div');
          box.className = 'form-error';
          form.insertAdjacentElement('afterend', box);
        }
        if (errors.length) {
          e.preventDefault();
          box.textContent = errors.join(' ');
          pwd.focus();
        } else {
          box.textContent = '';
        }
      });
    })();
  </script>

  <jsp:include page="footer.jsp" />
</body>
</html>