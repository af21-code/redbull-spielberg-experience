<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%
  User auth = (User) session.getAttribute("authUser");
  if (auth == null) {
      response.sendRedirect(request.getContextPath() + "/views/login.jsp");
      return;
  }
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Carrello - RedBull Spielberg Experience</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/indexStyle.css">
</head>
<body>
  <header style="padding:16px">
    <a href="${pageContext.request.contextPath}/index.jsp" style="color:#fff;text-decoration:none;">← Torna alla Home</a>
  </header>

  <main style="max-width:900px;margin:40px auto;color:#fff">
    <h1 style="margin-bottom:8px;">Il tuo Carrello</h1>
    <p>(placeholder) Qui mostreremo gli articoli nel carrello dell’utente <b><%= auth.getFirstName() %></b>.</p>
  </main>
</body>
</html>