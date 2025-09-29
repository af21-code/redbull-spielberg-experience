<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.math.BigDecimal, java.text.SimpleDateFormat" %>

<%!
  private String normImg(String p, String ctx){
    if (p == null || p.isBlank()) return null;
    String s = p.trim();
    if (s.startsWith("http://") || s.startsWith("https://") || s.startsWith("//")) return s;
    if (s.startsWith("/")) return ctx + s;
    return ctx + "/" + s;
  }
  private String resolveImg(String imageUrl, String vehicleCode, String productType, String ctx){
    String db = normImg(imageUrl, ctx);
    if (db != null) return db;

    boolean isExp = productType != null && "EXPERIENCE".equalsIgnoreCase(productType);
    String v = vehicleCode == null ? "" : vehicleCode.trim().toLowerCase(java.util.Locale.ITALY);

    if (isExp) {
      if ("rb21".equals(v) || "f1".equals(v))         return ctx + "/images/vehicles/rb21.jpg";
      if ("f2".equals(v))                             return ctx + "/images/vehicles/f2.jpg";
      if ("nascar".equals(v) || "stockcar".equals(v)) return ctx + "/images/vehicles/placeholder-vehicle.jpg";
      return ctx + "/images/vehicles/placeholder-vehicle.jpg";
    } else {
      // Placeholder generico locale (se non presente, valuta quello esterno)
      return ctx + "/images/placeholder.jpg";
      // Oppure: return "https://via.placeholder.com/400x300?text=Red+Bull";
    }
  }
%>

<%
  String ctx = request.getContextPath();

  // === Dati in ingresso dal controller ===
  Map<String,Object> o = (Map<String,Object>) request.getAttribute("order");
  List<Map<String,Object>> items = (List<Map<String,Object>>) request.getAttribute("items");
  Boolean isAdmin = (Boolean) request.getAttribute("isAdmin");
  if (isAdmin == null) isAdmin = false;

  // Se manca l'ordine, torna alla lista (link dinamico)
  if (o == null) {
    response.sendRedirect(isAdmin ? (ctx + "/admin/orders") : (ctx + "/orders"));
    return;
  }
  if (items == null) items = Collections.emptyList();

  // === Estratti NPE-safe ===
  String onum       = String.valueOf(o.get("order_number"));
  BigDecimal tot    = (BigDecimal) o.get("total_amount"); if (tot == null) tot = BigDecimal.ZERO;
  String status     = String.valueOf(o.get("status"));
  String pay        = String.valueOf(o.get("payment_status"));
  String payMethod  = String.valueOf(o.get("payment_method"));
  String carrier    = (String) o.get("carrier");
  String tracking   = (String) o.get("tracking_code");
  String shipAddr   = (String) o.get("shipping_address");
  String billAddr   = (String) o.get("billing_address");
  String notes      = (String) o.get("notes");
  java.sql.Timestamp orderDate = (java.sql.Timestamp) o.get("order_date");
  java.sql.Date eta            = (java.sql.Date) o.get("estimated_delivery");
  java.sql.Timestamp shippedAt = (java.sql.Timestamp) o.get("shipped_at");

  String buyerFirst = String.valueOf(o.get("buyer_first_name"));
  String buyerLast  = String.valueOf(o.get("buyer_last_name"));
  String buyerMail  = String.valueOf(o.get("buyer_email"));
  String buyerPhone = (String) o.get("buyer_phone");

  SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");

  // CSRF (se già generato altrove)
  String csrf = (String) request.getAttribute("csrfToken");
  if (csrf == null || csrf.isEmpty()) csrf = (String) session.getAttribute("csrfToken");

  // Tracking link
  String trackUrl = null;
  if (carrier != null && tracking != null && !carrier.isBlank() && !tracking.isBlank()) {
    if ("DHL".equalsIgnoreCase(carrier))        trackUrl = "https://www.dhl.com/it-it/home/tracking/tracking-express.html?tracking-id=" + tracking;
    else if ("UPS".equalsIgnoreCase(carrier))   trackUrl = "https://www.ups.com/track?tracknum=" + tracking;
    else if ("FEDEX".equalsIgnoreCase(carrier) || "FEDEX EXPRESS".equalsIgnoreCase(carrier))
                                               trackUrl = "https://www.fedex.com/fedextrack/?trknbr=" + tracking;
  }

  // Classi pill in base allo stato
  String statusClass = "badge";
  if ("COMPLETED".equalsIgnoreCase(status)) statusClass += " ok";
  else if ("CANCELLED".equalsIgnoreCase(status)) statusClass += " warn";

  // Back link dinamico
  String backHref = isAdmin ? (ctx + "/admin/orders") : (ctx + "/orders");

  // Annullabile lato cliente?
  boolean cancellable = (!isAdmin)
          && !"COMPLETED".equalsIgnoreCase(status)
          && !"CANCELLED".equalsIgnoreCase(status)
          && shippedAt == null;
%>

<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Ordine <%= onum %></title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <style>
    .page-wrap{padding:40px 18px 100px;background:linear-gradient(135deg,#001e36 0%,#000b2b 100%);color:#fff;min-height:60vh}
    .container{max-width:1100px;margin:0 auto}
    .grid{display:grid;grid-template-columns:2fr 1fr;gap:18px}
    @media (max-width: 980px){ .grid{grid-template-columns:1fr} }
    .card{background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.15);border-radius:16px;padding:18px}
    .title{margin:0 0 14px}
    .row{display:flex;gap:10px;flex-wrap:wrap;align-items:center}
    .pill{display:inline-flex;align-items:center;gap:8px;padding:6px 10px;border:1px solid rgba(255,255,255,.25);border-radius:999px}
    .badge{display:inline-block;padding:6px 10px;border-radius:999px;background:rgba(255,255,255,.12)}
    .badge.ok{background:#1e824c}
    .badge.warn{background:#b33939}
    .muted{opacity:.85}
    .kvs{display:grid;grid-template-columns:auto 1fr;gap:6px 10px}
    .kvs div:nth-child(odd){opacity:.8}
    .item{display:grid;grid-template-columns:90px 1fr auto;gap:12px;padding:12px 0;border-bottom:1px solid rgba(255,255,255,.12)}
    .item:last-child{border-bottom:none}
    .thumb{width:90px;height:68px;object-fit:cover;border-radius:10px}
    .price{white-space:nowrap;text-align:right}
    .small{font-size:.92rem;opacity:.9}
    .btn{background:#444;color:#fff;border:none;border-radius:10px;padding:10px 14px;font-weight:700;cursor:pointer;text-decoration:none}
    .btn.primary{background:#E30613}
    .btn.line{background:transparent;border:1px solid rgba(255,255,255,.3)}
    .btn.warn{background:#b33939}
    .block{display:block;width:100%}
    textarea,input[type=text]{background:#001E36;color:#fff;border:1px solid #0a3565;border-radius:10px;padding:10px 12px}
    .hint{font-size:.9rem;opacity:.8;margin-top:6px}
    .section-title{margin:0 0 10px}
    .total{font-weight:800;font-size:1.05rem}
  </style>
</head>
<body>
<jsp:include page="/views/header.jsp" />

<div class="page-wrap">
  <div class="container">

    <!-- Top header -->
    <div class="card" style="margin-bottom:18px">
      <div class="row" style="justify-content:space-between">
        <h2 class="title" style="margin:0">Ordine <%= onum %></h2>
        <a class="btn line" href="<%= backHref %>">← Torna agli ordini</a>
      </div>

      <!-- Flash messages da querystring (?ok=... / ?err=...) -->
      <%
        String ok = request.getParameter("ok");
        String err = request.getParameter("err");
      %>
      <% if (ok != null) { %>
        <div class="card" style="margin:12px 0;background:#1e824c">Operazione completata: <%= ok %></div>
      <% } %>
      <% if (err != null) { %>
        <div class="card" style="margin:12px 0;background:#b33939">Errore: <%= err %></div>
      <% } %>

      <div class="row">
        <span class="<%= statusClass %>">Stato: <strong><%= status %></strong></span>
        <span class="badge <%= "PAID".equalsIgnoreCase(pay) ? "ok" : "warn" %>">Pagamento: <strong><%= pay %></strong></span>
        <span class="badge">Metodo: <%= payMethod %></span>
        <span class="badge">Creato: <%= (orderDate==null ? "—" : new SimpleDateFormat("dd/MM/yyyy HH:mm").format(orderDate)) %></span>
        <% if (eta != null) { %>
          <span class="badge">Consegna stimata: <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(eta) %></span>
        <% } %>
        <span class="pill">Totale: € <strong><%= tot %></strong></span>
      </div>
    </div>

    <div class="grid">

      <!-- Colonna sinistra: Articoli + Note -->
      <div class="col-left">

        <div class="card">
          <h3 class="section-title">Articoli</h3>

          <% if (items.isEmpty()) { %>
            <p class="muted">Nessun articolo in questo ordine.</p>
          <% } %>

          <%
            for (Map<String,Object> r : items) {
              String name = String.valueOf(r.get("product_name"));
              Number qtyN = (Number) r.get("quantity"); int qty = qtyN==null?0:qtyN.intValue();
              BigDecimal up = (BigDecimal) r.get("unit_price"); if (up==null) up = BigDecimal.ZERO;
              BigDecimal tp = (BigDecimal) r.get("total_price"); if (tp==null) tp = up.multiply(BigDecimal.valueOf(qty));
              String img = (String) r.get("image_url");
              String driver = (String) r.get("driver_name");
              String driverNum = (String) r.get("driver_number");
              String comp   = (String) r.get("companion_name");
              String veh    = (String) r.get("vehicle_code");
              String ptype  = r.get("product_type")==null ? null : String.valueOf(r.get("product_type"));
              java.sql.Date ev = (java.sql.Date) r.get("event_date");

              String imgSrc = resolveImg(img, veh, ptype, ctx);
          %>
            <div class="item">
              <img class="thumb"
                   src="<%= imgSrc %>"
                   alt="<%= name %>"
                   onerror="this.onerror=null;this.src='<%=ctx%>/images/vehicles/placeholder-vehicle.jpg';">
              <div>
                <div><strong><%= name %></strong></div>
                <div class="small muted">Q.tà <%= qty %> × € <%= up %></div>
                <div class="small muted" style="margin-top:4px">
                  <% if (driver!=null && !driver.isBlank()) { %>Pilota: <strong><%= driver %></strong><% } %>
                  <% if (driverNum!=null && !driverNum.isBlank()) { %><% if (driver!=null && !driver.isBlank()) { %> • <% } %>N°: <%= driverNum %><% } %>
                  <% if (comp!=null && !comp.isBlank()) { %><% if ((driver!=null && !driver.isBlank()) || (driverNum!=null && !driverNum.isBlank())) { %> • <% } %>Accompagnatore: <%= comp %><% } %>
                  <% if (veh!=null && !veh.isBlank()) { %><% if ((driver!=null && !driver.isBlank()) || (driverNum!=null && !driverNum.isBlank()) || (comp!=null && !comp.isBlank())) { %> • <% } %>Veicolo: <%= veh %><% } %>
                  <% if (ev!=null) { %><% if ((driver!=null && !driver.isBlank()) || (driverNum!=null && !driverNum.isBlank()) || (comp!=null && !comp.isBlank()) || (veh!=null && !veh.isBlank())) { %> • <% } %>Data evento: <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(ev) %><% } %>
                </div>
              </div>
              <div class="price">€ <%= tp %></div>
            </div>
          <% } %>

          <hr style="border-color:rgba(255,255,255,.15);margin:12px 0">
          <div class="row" style="justify-content:flex-end">
            <div class="total">Totale ordine: € <%= tot %></div>
          </div>
        </div>

        <% if (notes != null && !notes.isBlank()) { %>
          <div class="card" style="margin-top:18px">
            <h3 class="section-title">Note del cliente</h3>
            <p class="muted" style="margin:0;white-space:pre-wrap"><%= notes %></p>
          </div>
        <% } %>

      </div>

      <!-- Colonna destra -->
      <div class="col-right">

        <div class="card">
          <h3 class="section-title">Stato spedizione</h3>
          <% if (tracking != null && !tracking.isBlank()) { %>
            <p class="muted" style="margin:0 0 8px">
              Corriere: <strong><%= carrier %></strong><br>
              Codice: <strong><%= tracking %></strong>
            </p>
            <% if (trackUrl != null) { %>
              <a class="btn block" href="<%= trackUrl %>" target="_blank" rel="noopener">Apri tracking</a>
            <% } %>
          <% } else { %>
            <p class="muted">Nessun codice di tracking disponibile.</p>
          <% } %>
        </div>

        <div class="card" style="margin-top:18px">
          <h3 class="section-title">Acquirente</h3>
          <div class="kvs">
            <div>Nome</div><div><strong><%= buyerFirst %> <%= buyerLast %></strong></div>
            <div>Email</div><div><a href="mailto:<%= buyerMail %>" style="color:#fff"><%= buyerMail %></a></div>
            <div>Telefono</div><div><%= (buyerPhone==null||buyerPhone.isBlank())?"—":buyerPhone %></div>
          </div>
        </div>

        <div class="card" style="margin-top:18px">
          <h3 class="section-title">Indirizzi</h3>
          <div class="kvs" style="grid-template-columns:auto 1fr">
            <div>Spedizione</div><div><pre class="muted" style="white-space:pre-wrap;margin:0"><%= shipAddr==null?"—":shipAddr %></pre></div>
            <div>Fatturazione</div><div><pre class="muted" style="white-space:pre-wrap;margin:0"><%= billAddr==null?"—":billAddr %></pre></div>
          </div>
        </div>

        <% if (!isAdmin && cancellable) { %>
          <div class="card" style="margin-top:18px">
            <h3 class="section-title">Azioni ordine</h3>
            <form method="post" action="<%=ctx%>/order/cancel"
                  onsubmit="return confirm('Annullare definitivamente questo ordine? Verranno ripristinati lo stock e le capienze slot.');">
              <input type="hidden" name="id" value="<%= o.get("order_id") %>">
              <% if (csrf != null && !csrf.isEmpty()) { %><input type="hidden" name="csrf" value="<%= csrf %>"><% } %>
              <button class="btn warn block" type="submit">Annulla ordine</button>
            </form>
            <p class="hint">L’ordine è annullabile finché non è stato spedito o completato.</p>
          </div>
        <% } %>

        <% if (isAdmin) { %>
          <div class="card" style="margin-top:18px">
            <h3 class="section-title">Azioni amministratore</h3>

            <!-- Tracking -->
            <form method="post" action="<%=ctx%>/admin/order-action" style="margin-bottom:10px">
              <input type="hidden" name="id" value="<%= o.get("order_id") %>">
              <input type="hidden" name="action" value="tracking">
              <% if (csrf != null && !csrf.isEmpty()) { %><input type="hidden" name="csrf" value="<%= csrf %>"><% } %>
              <input type="text" name="carrier" class="block" placeholder="Corriere (DHL/UPS/FEDEX...)" value="<%= carrier==null? "": carrier %>" style="margin-bottom:8px">
              <input type="text" name="tracking_code" class="block" placeholder="Codice tracking" value="<%= tracking==null? "": tracking %>" style="margin-bottom:8px">
              <button class="btn block">Salva tracking</button>
              <div class="hint">Alla prima impostazione del tracking verrà valorizzato anche <em>shipped_at</em>.</div>
            </form>

            <!-- Completa -->
            <% if (!"COMPLETED".equalsIgnoreCase(status)) { %>
              <form method="post" action="<%=ctx%>/admin/order-action" onsubmit="return confirm('Segnare l\\'ordine come CONSEGNATO/COMPLETATO?')">
                <input type="hidden" name="id" value="<%= o.get("order_id") %>">
                <input type="hidden" name="action" value="complete">
                <% if (csrf != null && !csrf.isEmpty()) { %><input type="hidden" name="csrf" value="<%= csrf %>"><% } %>
                <button class="btn primary block">Segna come consegnato</button>
              </form>
            <% } %>

            <!-- Spazio extra + Annulla -->
            <% if (!"COMPLETED".equalsIgnoreCase(status) && !"CANCELLED".equalsIgnoreCase(status)) { %>
              <hr style="border-color:rgba(255,255,255,.15);margin:22px 0 12px">
              <form method="post" action="<%=ctx%>/admin/order-action"
                    onsubmit="return confirm('Annullare definitivamente questo ordine? Verranno liberati eventuali slot e ripristinato lo stock.')"
                    style="margin-top:8px">
                <input type="hidden" name="id" value="<%= o.get("order_id") %>">
                <input type="hidden" name="action" value="cancel">
                <% if (csrf != null && !csrf.isEmpty()) { %><input type="hidden" name="csrf" value="<%= csrf %>"><% } %>
                <button class="btn warn block">Annulla ordine</button>
              </form>
            <% } %>
          </div>
        <% } %>

      </div>
    </div>

  </div>
</div>

<jsp:include page="/views/footer.jsp" />
</body>
</html>