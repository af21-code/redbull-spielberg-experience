<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.math.BigDecimal, java.text.SimpleDateFormat" %>
<%
  String ctx = request.getContextPath();
  Map<String,Object> o = (Map<String,Object>) request.getAttribute("order");
  List<Map<String,Object>> items = (List<Map<String,Object>>) request.getAttribute("items");
  if (o == null) { o = new HashMap<>(); items = Collections.emptyList(); }
  String onum = String.valueOf(o.get("order_number"));
  BigDecimal tot = (BigDecimal) o.get("total_amount");
  String status = String.valueOf(o.get("status"));
  String pay = String.valueOf(o.get("payment_status"));
  String payMethod = String.valueOf(o.get("payment_method"));
  String carrier = (String) o.get("carrier");
  String tracking = (String) o.get("tracking_code");
  String shipAddr = (String) o.get("shipping_address");
  String billAddr = (String) o.get("billing_address");
  java.sql.Timestamp orderDate = (java.sql.Timestamp) o.get("order_date");
  java.sql.Date eta = (java.sql.Date) o.get("estimated_delivery");
  SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Ordine <%= onum %></title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <style>
    .wrap { padding: 32px 20px 64px; background: linear-gradient(135deg,#001e36 0%, #000b2b 100%); color:#fff; min-height:60vh; }
    .card { max-width:1100px; margin:0 auto 16px; background: rgba(255,255,255,0.06); border:1px solid rgba(255,255,255,0.15); border-radius:16px; padding:18px; }
    .title { font-size:1.4rem; margin:0 0 8px; }
    .badge { display:inline-block; padding:4px 8px; border-radius:999px; font-size:.85rem; margin-right:6px; }
    .b-ok { background:#1e824c; }
    .b-warn { background:#d35400; }
    .b-info { background:#2c3e50; }
    .grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
    .tracking { display:flex; align-items:center; gap:10px; }
    .table { width:100%; border-collapse:collapse; }
    .table th,.table td { padding:10px; border-bottom:1px solid rgba(255,255,255,0.15); }
    .img { width:80px; height:60px; object-fit:cover; border-radius:8px; }
    .back { display:inline-block; margin-top:12px; color:#fff; text-decoration:none; padding:8px 12px; border:1px solid rgba(255,255,255,.25); border-radius:10px; }
  </style>
</head>
<body>
<jsp:include page="header.jsp" />

<div class="wrap">
  <div class="card">
    <h2 class="title">Ordine <%= onum %></h2>
    <div>
      <span class="badge b-info">Status: <%= status %></span>
      <span class="badge <%= "PAID".equalsIgnoreCase(pay)?"b-ok":"b-warn" %>">Pagamento: <%= pay %></span>
      <span class="badge b-info">Metodo: <%= payMethod %></span>
      <span class="badge b-info">Data: <%= orderDate==null?"":df.format(orderDate) %></span>
      <% if (eta != null) { %>
      <span class="badge b-info">Consegna stimata: <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(eta) %></span>
      <% } %>
    </div>
  </div>

  <div class="card grid">
    <div>
      <h3 class="title">Spedizione</h3>
      <pre style="white-space:pre-wrap;"><%= shipAddr==null?"—":shipAddr %></pre>
    </div>
    <div>
      <h3 class="title">Fatturazione</h3>
      <pre style="white-space:pre-wrap;"><%= billAddr==null?"—":billAddr %></pre>
    </div>
  </div>

  <div class="card">
    <h3 class="title">Tracking</h3>
    <% if (tracking != null && !tracking.isBlank()) { %>
      <div class="tracking">
        <div class="badge b-info">Corriere: <%= carrier==null?"—":carrier %></div>
        <div class="badge b-ok">Codice: <%= tracking %></div>
      </div>
      <p style="opacity:.85;margin:8px 0 0;">Usa il codice sul sito del corriere per seguire la spedizione.</p>
    <% } else { %>
      <p style="opacity:.85;">Nessun codice di tracking disponibile.</p>
    <% } %>
  </div>

  <div class="card">
    <h3 class="title">Articoli</h3>
    <table class="table">
      <thead>
        <tr><th>Prodotto</th><th>Q.tà</th><th>Prezzo</th><th>Totale</th></tr>
      </thead>
      <tbody>
      <%
        for (Map<String,Object> r : items) {
          String name = String.valueOf(r.get("product_name"));
          Integer qty = (Integer) r.get("quantity");
          BigDecimal up = (BigDecimal) r.get("unit_price");
          BigDecimal tp = (BigDecimal) r.get("total_price");
          String img = (String) r.get("image_url");
          String imgSrc = (img!=null && !img.isBlank()) ? (request.getContextPath()+"/"+img) : "https://via.placeholder.com/400x300?text=Red+Bull";
      %>
        <tr>
          <td>
            <img class="img" src="<%= imgSrc %>" alt="<%= name %>">
            &nbsp;<strong><%= name %></strong>
          </td>
          <td><%= qty %></td>
          <td>€ <%= up %></td>
          <td>€ <%= tp %></td>
        </tr>
      <% } %>
      </tbody>
      <tfoot>
        <tr>
          <td colspan="3" style="text-align:right;font-weight:800;">Totale ordine</td>
          <td style="font-weight:800;">€ <%= tot %></td>
        </tr>
      </tfoot>
    </table>

    <a class="back" href="<%=ctx%>/orders">← Torna agli ordini</a>
  </div>
</div>

<jsp:include page="footer.jsp" />
</body>
</html>