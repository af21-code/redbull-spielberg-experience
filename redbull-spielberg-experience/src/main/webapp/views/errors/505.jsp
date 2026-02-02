<%@ page isErrorPage="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Errore del server</title>
  <link rel="icon" type="image/jpeg" href="https://cdn-3.motorsport.com/images/mgl/Y99JQRbY/s8/red-bull-racing-logo-1.jpg" />
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/indexStyle.css" />
  <style>
    body { margin: 0; background: #000b2b; color: #fff; font-family: Arial, sans-serif; }
    .wrap { min-height: 100vh; display: grid; place-items: center; padding: 24px; }
    .card { max-width: 700px; width: 100%; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); border-radius: 16px; padding: 28px; text-align: center; box-shadow: 0 12px 32px rgba(0,0,0,0.45); }
    .code { font-size: 4rem; font-weight: 800; color: #F5A600; margin: 0 0 6px; }
    h1 { margin: 0 0 10px; font-size: 1.6rem; }
    p { margin: 0 0 20px; color: rgba(255,255,255,0.8); }
    .actions { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; }
    .btn { display: inline-block; padding: 12px 16px; border-radius: 10px; font-weight: 700; text-decoration: none; }
    .btn.primary { background: #E30613; color: #fff; }
    .btn.ghost { border: 1px solid rgba(255,255,255,0.35); color: #fff; }
    details { margin-top: 16px; text-align: left; }
    summary { cursor: pointer; color: #F5A600; font-weight: 700; }
    pre { background: #011024; padding: 12px; border-radius: 8px; overflow: auto; color: #fff; }
  </style>
</head>
<body>
  <div class="wrap">
    <div class="card">
      <div class="code">500</div>
      <h1>Errore del server</h1>
      <p>Qualcosa è andato storto. Riprova più tardi.</p>
      <div class="actions">
        <a class="btn primary" href="${pageContext.request.contextPath}/index.jsp">Torna alla Home</a>
        <a class="btn ghost" href="${pageContext.request.contextPath}/shop">Vai allo Shop</a>
      </div>

      <% if (exception != null) { %>
        <details>
          <summary>Dettagli tecnici (dev)</summary>
          <pre><%= exception %></pre>
        </details>
      <% } %>
    </div>
  </div>
</body>
</html>