<%@ page isErrorPage="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8" />
  <title>Errore del server</title>
  <style>
    body{margin:0;font-family:Arial;background:#0a0d1a;color:#fff;display:grid;place-items:center;min-height:100vh}
    .box{max-width:900px;padding:24px}
    h1{font-size:42px;margin:0 0 8px;color:#E30613}
    pre{background:#011024;padding:16px;border-radius:8px;overflow:auto}
    a{color:#F5A600;text-decoration:none;font-weight:700}
  </style>
</head>
<body>
  <div class="box">
    <h1>Qualcosa è andato storto</h1>
    <p>Riprova più tardi. Intanto puoi tornare alla <a href="${pageContext.request.contextPath}/index.jsp">Home</a>.</p>
    <%
      if (exception != null) {
    %>
      <h3>Dettagli (dev):</h3>
      <pre><%= exception %></pre>
    <%
      }
    %>
  </div>
</body>
</html>