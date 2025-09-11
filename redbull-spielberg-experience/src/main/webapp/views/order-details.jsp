<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.math.BigDecimal, java.text.SimpleDateFormat" %>
<%
  String ctx = request.getContextPath();
  Map<String,Object> o = (Map<String,Object>) request.getAttribute("order");
  List<Map<String,Object>> items = (List<Map<String,Object>>) request.getAttribute("items");
  Boolean isAdmin = (Boolean) request.getAttribute("isAdmin");
  if (isAdmin == null) isAdmin = false;

  if (o == null) { o = new HashMap<>(); items = Collections.emptyList(); }

  String onum   = String.valueOf(o.get("order_number"));
  BigDecimal tot = (BigDecimal) o.get("total_amount");
  String status = String.valueOf(o.get("status"));
  String pay    = String.valueOf(o.get("payment_status"));
  String payMethod = String.valueOf(o.get("payment_method"));
  String carrier = (String) o.get("carrier");
  String tracking = (String) o.get("tracking_code");
  String shipAddr = (String) o.get("shipping_address");
  String billAddr = (String) o.get("billing_address");
  String notes    = (String) o.get("notes");
  java.sql.Timestamp orderDate = (java.sql.Timestamp) o.get("order_date");
  java.sql.Date eta = (java.sql.Date) o.get("estimated_delivery");

  String buyerFirst = String.valueOf(o.get("buyer_first_name"));
  String buyerLast  = String.valueOf(o.get("buyer_last_name"));
  String buyerMail  = String.valueOf(o.get("buyer_email"));
  String buyerPhone = (String) o.get("buyer_phone");

  SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");

  // tracking link
  String trackUrl = null;
  if (carrier != null && tracking != null && !carrier.isBlank() && !tracking.isBlank()) {
    if ("DHL".equalsIgnoreCase(carrier)) {
      trackUrl = "https://www.dhl.com/it-it/home/tracking/tracking-express.html?tracking-id=" + tracking;
    } else if ("UPS".equalsIgnoreCase(carrier)) {
      trackUrl = "https://www.ups.com/track?tracknum=" + tracking;
    } else if ("FEDEX".equalsIgnoreCase(carrier) || "FEDEX EXPRESS".equalsIgnoreCase(carrier)) {
      trackUrl = "https://www.fedex.com/fedextrack/?trknbr=" + tracking;
    }
  }
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Ordine <%= onum %></title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <!-- opzionale: stile minimo locale -->
  <style>
    .wrap{padding:34px 20px 80px;background:linear-gradient(135deg,#001e36 0%,#000b2b 100%);color:#fff;min-height:60vh}
    .container{max-width:1100px;margin:0 auto}
    .grid-2{display:grid;grid-template-columns:1fr 1fr;gap:16px}
    .card{background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.15);border-radius:16px;padding:18px}
    .title{margin:0 0 10px}
    .badge{display:inline-block;padding:6px 10px;border-radius:999px;font-size:.9rem;margin:0 6px 6px 0;background:rgba(255,255,255,.12)}
    .badge.ok{background:#1e824c}
    .badge.warn{background:#d35400}
    .muted{opacity:.85}
    .table{width:100%;border-collapse:collapse}
    .table th,.table td{padding:10px;border-bottom:1px solid rgba(255,255,255,.15);vertical-align:top}
    .img{width:90px;height:68px;object-fit:cover;border-radius:10px}
    .back{display:inline-block;margin-top:14px;color:#fff;text-decoration:none;padding:10px 14px;border:1px solid rgba(255,255,255,.25);border-radius:10px}
    .kvs{display:grid;grid-template-columns:auto 1fr;gap:6px 10px}
    .kvs div:nth-child(odd){opacity:.8}
    .actions{display:flex;gap:10px;flex-wrap:wrap}
    .btn{background:#444;color:#fff;border:none;border-radius:10px;padding:10px 14px;font-weight:700;cursor:pointer;text-decoration:none}
    .btn.primary{background:#E30613}
    .form-row{display:flex;gap:10px;flex-wrap:wrap}
    input[type=text]{background:#001E36;color:#fff;border:1px solid #0a3565;border-radius:10px;padding:10px 12px;min-width:240px}
    .hint{font-size:.9rem;opacity:.8;margin-top:6px}
    .pill{display:inline-block;padding:2px 8px;border:1px solid rgba(255,255,255,.3);border-radius:999px;margin-left:8px;font-size:.8rem;opacity:.9}
    .flash{background:#0a6; padding:10px 12px; border-radius:10px; margin-bottom:12px; display:inline-block}
  </style>
</head>
<body>
<jsp:include page="/views/header.jsp" />

<div class="wrap">
  <div class="container">

    <% if ("1".equals(request.getParameter("updated"))) { %>
      <div class="flash">Ordine aggiornato con successo.</div>
    <% } %>

    <!-- TESTATA -->
    <div class="card">
      <h2 class="title">Ordine <%= onum %></h2>
      <div>
        <span class="badge">Stato: <strong><%= status %></strong></span>
        <span class="badge <%= "PAID".equalsIgnoreCase(pay) ? "ok" : "warn" %>">Pagamento: <strong><%= pay %></strong></span>
        <span class="badge">Metodo: <%= payMethod %></span>
        <span class="badge">Creato: <%= orderDate==null?"—":df.format(orderDate) %></span>
        <% if (eta != null) { %><span class="badge">Consegna stimata: <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(eta) %></span><% } %>
        <span class="pill">Totale: € <%= tot %></span>
      </div>
    </div>

    <!-- BUYER + INDIRIZZI -->
    <div class="grid-2">
      <div class="card">
        <h3 class="title">Acquirente</h3>
        <div class="kvs">
          <div>Nome</div><div><strong><%= buyerFirst %> <%= buyerLast %></strong></div>
          <div>Email</div><div><a href="mailto:<%= buyerMail %>" style="color:#fff"><%= buyerMail %></a></div>
          <div>Telefono</div><div><%= (buyerPhone==null||buyerPhone.isBlank())?"—":buyerPhone %></div>
        </div>
      </div>
      <div class="card">
        <h3 class="title">Indirizzi</h3>
        <div class="grid-2">
          <div>
            <h4 style="margin:0 0 6px">Spedizione</h4>
            <pre class="muted" style="white-space:pre-wrap;margin:0"><%= shipAddr==null?"—":shipAddr %></pre>
          </div>
          <div>
            <h4 style="margin:0 0 6px">Fatturazione</h4>
            <pre class="muted" style="white-space:pre-wrap;margin:0"><%= billAddr==null?"—":billAddr %></pre>
          </div>
        </div>
      </div>
    </div>

    <!-- TRACKING (con gestione admin) -->
    <div class="card">
      <h3 class="title">Tracking</h3>
      <% if (tracking != null && !tracking.isBlank()) { %>
        <p class="muted" style="margin:0 0 8px">
          Corriere: <strong><%= carrier %></strong> —
          Codice: <strong><%= tracking %></strong>
          <% if (trackUrl != null) { %>
            — <a class="btn" href="<%= trackUrl %>" target="_blank" rel="noopener">Apri tracking</a>
          <% } %>
        </p>
      <% } else { %>
        <p class="muted">Nessun codice di tracking disponibile.</p>
      <% } %>

      <% if (isAdmin) { %>
        <hr style="border-color:rgba(255,255,255,.15);margin:12px 0">
        <form method="post" action="<%=ctx%>/order" class="form-row">
          <input type="hidden" name="id" value="<%= o.get("order_id") %>">
          <input type="hidden" name="action" value="tracking">
          <input type="text" name="carrier" placeholder="Corriere (DHL/UPS/FEDEX...)" value="<%= carrier==null?"":carrier %>">
          <input type="text" name="tracking_code" placeholder="Codice tracking" value="<%= tracking==null?"":tracking %>">
          <button class="btn">Salva tracking</button>
        </form>
        <div class="hint">Il campo <em>shipped_at</em> verrà valorizzato se non presente.</div>

        <% if (!"COMPLETED".equalsIgnoreCase(status)) { %>
          <form method="post" action="<%=ctx%>/order" style="margin-top:10px">
            <input type="hidden" name="id" value="<%= o.get("order_id") %>">
            <input type="hidden" name="action" value="complete">
            <button class="btn primary" onclick="return confirm('Segnare l\\'ordine come CONSEGNATO/COMPLETATO?')">Segna come consegnato</button>
          </form>
        <% } %>
      <% } %>
    </div>

    <!-- ARTICOLI -->
    <div class="card">
      <h3 class="title">Articoli</h3>
      <table class="table">
        <thead>
          <tr>
            <th>Prodotto</th>
            <th>Q.tà</th>
            <th>Prezzo</th>
            <th>Totale</th>
            <th style="width:40%">Dettagli esperienza</th>
          </tr>
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

            String driver = (String) r.get("driver_name");
            String comp   = (String) r.get("companion_name");
            String veh    = (String) r.get("vehicle_code");
            java.sql.Date ev = (java.sql.Date) r.get("event_date");
        %>
          <tr>
            <td>
              <img class="img" src="<%= imgSrc %>" alt="<%= name %>">
              &nbsp;<strong><%= name %></strong>
            </td>
            <td><%= qty %></td>
            <td>€ <%= up %></td>
            <td>€ <%= tp %></td>
            <td class="muted">
              <% if (driver!=null && !driver.isBlank()) { %>Pilota: <strong><%= driver %></strong><br><% } %>
              <% if (comp!=null && !comp.isBlank()) { %>Accompagnatore: <%= comp %><br><% } %>
              <% if (veh!=null && !veh.isBlank()) { %>Veicolo: <%= veh %><br><% } %>
              <% if (ev!=null) { %>Data evento: <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(ev) %><% } %>
            </td>
          </tr>
        <% } %>
        </tbody>
        <tfoot>
          <tr>
            <td colspan="3" style="text-align:right;font-weight:800;">Totale ordine</td>
            <td style="font-weight:800;">€ <%= tot %></td>
            <td></td>
          </tr>
        </tfoot>
      </table>

      <a class="back" href="<%=ctx%>/orders">← Torna agli ordini</a>
    </div>

    <% if (notes != null && !notes.isBlank()) { %>
      <div class="card">
        <h3 class="title">Note</h3>
        <p class="muted" style="margin:0"><%= notes %></p>
      </div>
    <% } %>

  </div>
</div>

<jsp:include page="/views/footer.jsp" />
</body>
</html>