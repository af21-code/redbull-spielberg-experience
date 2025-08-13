<%@ page isErrorPage="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8" />
  <title>404 - Pagina non trovata</title>
  <style>
    body{margin:0;font-family:Arial;background:#0a0d1a;color:#fff;display:grid;place-items:center;height:100vh}
    .box{max-width:700px;text-align:center}
    h1{font-size:56px;margin:0;color:#F5A600}
    p{opacity:.9}
    a{color:#E30613;text-decoration:none;font-weight:700}
  </style>
</head>
<body>
  <div class="box">
    <h1>404</h1>
    <p>La pagina che cerchi non esiste.</p>
    <p><a href="${pageContext.request.contextPath}/index.jsp">Torna alla Home</a></p>
  </div>
</body>
</html>