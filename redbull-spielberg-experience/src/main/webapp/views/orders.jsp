<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat, model.Order, model.OrderItem" %>
<%
  String ctx = request.getContextPath();
  List<Order> orders = (List<Order>) request.getAttribute("orders");
  Boolean isAdmin = (Boolean) request.getAttribute("isAdmin");
  if (isAdmin == null) isAdmin = false;

  SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title><%= isAdmin ? "Ordini (Admin)" : "I miei ordini" %></title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <style>
    .orders-wrap { padding: 40px 24px 80px; background: linear-gradient(135deg,#001e36 0%,#000b2b 100%); color:#fff; min-height:60vh; }
    .orders-title { max-width:1100px; margin:0 auto 18px; display:flex; justify-content:space-between; align-items:center; }
    .order-card { max-width:1100px; margin:12px auto; background:rgba(255,255,255,0.08); border:1px solid rgba(255,255,255,0.15); border-radius:16px; overflow:hidden; }
    .order-head { padding:16px 18px; display:flex; gap:18px; flex-wrap:wrap; align-items:center; border-bottom:1px solid rgba(255,255,255,0.15); }
    .order-head .badge { background:#F5A600; color:#001e36; font-weight:800; border-radius:10px; padding:6px 10px; }
    .order-head .muted { opacity:.8; }
    .order-body { padding:14px 18px; }
    .items-table { width:100%; border-collapse:collapse; }
    .items-table th, .items-table td { padding:10px 8px; border-bottom:1px solid rgba(255,255,255,0.12); }
    .items-table th { text-align:left; color:#F5A600; }
    .order-foot { padding:12px 18px 18px; display:flex; justify-content:space-between; align-items:center; gap:10px; flex-wrap:wrap; }
    .total { font-weight:900; color:#F5A600; }
    .track-btn { background:#E30613; color:#fff; border:none; border-radius:10px; padding:8px 12px; font-weight:700; cursor:pointer; text-decoration:none; }
    .details-btn { background:#0a84ff; color:#fff; border:none; border-radius:10px; padding:8px 12px; font-weight:700; cursor:pointer; text-decoration:none; }
    .empty { max-width:1100px; margin:40px auto; text-align:center; opacity:.85; }
    .order-actions { display:flex; gap:8px; align-items:center; }
  </style>
</head>
<body>
<jsp:include page="header.jsp" />

<div class="orders-wrap">
  <div class="orders-title">
    <h2><%= isAdmin ? "Ordini (Admin)" : "I miei ordini" %></h2>
  </div>

  <%
    if (orders == null || orders.isEmpty()) {
  %>
    <p class="empty">Nessun ordine trovato.</p>
  <%
    } else {
      for (Order o : orders) {
        String shipped = (o.getShippedAt() != null) ? df.format(o.getShippedAt()) : "—";
        String eta = (o.getEstimatedDelivery() != null) ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(o.getEstimatedDelivery()) : "—";

        String carrier = (o.getCarrier() == null ? "" : o.getCarrier());
        String code = (o.getTrackingCode() == null ? "" : o.getTrackingCode());
        String trackUrl = null;
        if (!carrier.isBlank() && !code.isBlank()) {
          if ("DHL".equalsIgnoreCase(carrier)) {
            trackUrl = "https://www.dhl.com/it-it/home/tracking/tracking-express.html?tracking-id=" + code;
          } else if ("UPS".equalsIgnoreCase(carrier)) {
            trackUrl = "https://www.ups.com/track?tracknum=" + code;
          } else if ("FEDEX".equalsIgnoreCase(carrier) || "FEDEX EXPRESS".equalsIgnoreCase(carrier)) {
            trackUrl = "https://www.fedex.com/fedextrack/?trknbr=" + code;
          } else {
            trackUrl = null;
          }
        }

        // Provo a recuperare l'orderId via reflection per evitare errori di compilazione se il getter ha nome diverso
        Integer orderId = null;
        try { orderId = (Integer) o.getClass().getMethod("getOrderId").invoke(o); } catch (Exception ignored) {}
  %>
    <div class="order-card">
      <div class="order-head">
        <span class="badge">
          <% if (orderId != null) { %>
            <a href="<%=ctx%>/order?id=<%=orderId%>" style="text-decoration:none; color:#001e36;"># <%= o.getOrderNumber() %></a>
          <% } else { %>
            # <%= o.getOrderNumber() %>
          <% } %>
        </span>
        <span>Stato: <strong><%= o.getStatus() %></strong></span>
        <span>Pagamento: <strong><%= o.getPaymentStatus() %></strong></span>
        <span class="muted">Creato: <%= df.format(o.getOrderDate()) %></span>
        <span class="muted">Spedito: <%= shipped %></span>
        <span class="muted">Consegna stimata: <%= eta %></span>
      </div>

      <div class="order-body">
        <table class="items-table">
          <thead>
            <tr>
              <th>Articolo</th>
              <th>Qty</th>
              <th>Prezzo</th>
              <th>Totale</th>
            </tr>
          </thead>
          <tbody>
          <%
            List<OrderItem> items = o.getItems();
            if (items != null) {
              for (OrderItem it : items) {
          %>
            <tr>
              <td><%= it.getProductName() %></td>
              <td><%= it.getQuantity() %></td>
              <td>€ <%= it.getUnitPrice() %></td>
              <td>€ <%= it.getTotalPrice() %></td>
            </tr>
          <%
              }
            }
          %>
          </tbody>
        </table>
      </div>

      <div class="order-foot">
        <div class="total">Totale: € <%= o.getTotalAmount() %></div>
        <div class="order-actions">
          <% if (orderId != null) { %>
            <a class="details-btn" href="<%=ctx%>/order?id=<%=orderId%>">Dettagli</a>
          <% } %>
          <% if (trackUrl != null) { %>
            <a class="track-btn" href="<%= trackUrl %>" target="_blank" rel="noopener">Track</a>
          <% } else if (code != null && !code.isBlank()) { %>
            <span class="muted">Tracking: <strong><%= code %></strong> (<%= carrier %>)</span>
          <% } %>
        </div>
      </div>
    </div>
  <%
      } // end for
    } // end else
  %>
</div>

<jsp:include page="footer.jsp" />
</body>
</html>