<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  String ctx = request.getContextPath();

  // Supporta sia il vecchio forward (attribute) sia il nuovo redirect PRG (parameter)
  String orderNumberAttr  = (String) request.getAttribute("orderNumber");
  String orderNumberParam = request.getParameter("orderNumber");
  String orderNumber = (orderNumberAttr != null && !orderNumberAttr.isEmpty())
                        ? orderNumberAttr : orderNumberParam;

  // Safety: se manca (refresh diretto senza param), rimanda all’elenco ordini
  if (orderNumber == null || orderNumber.isEmpty()) {
    response.sendRedirect(ctx + "/orders");
    return;
  }
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Ordine confermato</title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <link rel="icon" type="image/jpeg" href="https://cdn-3.motorsport.com/images/mgl/Y99JQRbY/s8/red-bull-racing-logo-1.jpg" />
  <style>
    .ok-wrap{padding:60px 24px 120px;background:linear-gradient(135deg,#001e36 0%,#000b2b 100%);color:#fff;min-height:60vh}
    .ok-card{max-width:760px;margin:0 auto;background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.15);border-radius:16px;padding:24px;text-align:center}
    .btn{display:inline-block;margin-top:16px;background:#E30613;color:#fff;padding:12px 18px;border-radius:10px;font-weight:800;text-decoration:none}
    .order{color:#F5A600;font-weight:900}
  </style>
</head>
<body>
<jsp:include page="header.jsp"/>

<div class="ok-wrap">
  <div class="ok-card">
    <h2>Grazie! Il tuo ordine è stato ricevuto.</h2>
    <p>Numero ordine: <span class="order"><%= orderNumber %></span></p>
    <p>Riceverai una conferma via email (demo).</p>
    <a class="btn" href="<%=ctx%>/index.jsp">Torna alla Home</a>
  </div>
</div>

<jsp:include page="footer.jsp"/>
</body>
</html>