<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.math.BigDecimal, java.text.SimpleDateFormat, model.Order" %>
<%!
  // Escape HTML semplice
  private static String esc(Object o) {
    if (o == null) return "";
    String s = String.valueOf(o);
    return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
            .replace("\"","&quot;").replace("'","&#39;");
  }
%>
<%
  String ctx = request.getContextPath();

  // Cast sicuro: accetta solo elementi realmente di tipo Order (no unchecked warnings)
  Object ordAttr = request.getAttribute("orders");
  List<Order> orders = new ArrayList<>();
  if (ordAttr instanceof List<?>) {
    for (Object x : (List<?>) ordAttr) {
      if (x instanceof Order) orders.add((Order) x);
    }
  }

  SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>I miei ordini</title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <style>
    .wrap{padding:30px 18px 80px;background:linear-gradient(135deg,#001e36 0%,#000b2b 100%);min-height:60vh;color:#fff}
    .container{max-width:1100px;margin:0 auto}
    .card{background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.15);border-radius:16px;padding:16px}
    .title{margin:0 0 12px}
    .table{width:100%;border-collapse:collapse;margin-top:12px}
    .table th,.table td{padding:10px;border-bottom:1px solid rgba(255,255,255,.15);vertical-align:top}
    .pill{display:inline-block;padding:2px 8px;border:1px solid rgba(255,255,255,.3);border-radius:999px}
    .muted{opacity:.85}
    .btn{background:#444;color:#fff;border:none;border-radius:10px;padding:8px 12px;font-weight:700;cursor:pointer;text-decoration:none}
    .btn.primary{background:#E30613}
  </style>
</head>
<body>
<jsp:include page="/views/header.jsp" />

<div class="wrap">
  <div class="container">

    <h2 class="title">I miei ordini</h2>

    <div class="card">
      <table class="table">
        <thead>
        <tr>
          <th># Ordine</th>
          <th>Data</th>
          <th>Totale</th>
          <th>Stato</th>
          <th>Pagamento</th>
          <th></th>
        </tr>
        </thead>
        <tbody>
        <% if (orders.isEmpty()) { %>
          <tr><td colspan="6" class="muted">Non hai ancora effettuato ordini.</td></tr>
        <% } %>
        <%
          for (Order o : orders) {
            String onum  = o.getOrderNumber();
            java.util.Date od = (o.getOrderDate() instanceof java.util.Date) ? (java.util.Date) o.getOrderDate() : null;
            String date  = (od == null) ? "—" : df.format(od);
            BigDecimal tot = o.getTotalAmount() == null ? BigDecimal.ZERO : o.getTotalAmount();
            String st   = o.getStatus();
            String pay  = o.getPaymentStatus();
        %>
          <tr>
            <td><strong><%= esc(onum) %></strong></td>
            <td class="muted"><%= date %></td>
            <td>€ <%= tot %></td>
            <td><span class="pill"><%= esc(st) %></span></td>
            <td><span class="pill"><%= esc(pay) %></span></td>
            <td><a class="btn" href="<%=ctx%>/order?id=<%= o.getOrderId() %>">Dettagli</a></td>
          </tr>
        <% } %>
        </tbody>
      </table>
    </div>

  </div>
</div>

<jsp:include page="/views/footer.jsp" />
</body>
</html>