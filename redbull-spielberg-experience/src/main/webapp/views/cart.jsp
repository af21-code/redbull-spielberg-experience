<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.math.BigDecimal, java.time.format.DateTimeFormatter" %>
<%@ page import="model.CartItem" %>
<%@ page import="java.text.DecimalFormat, java.text.DecimalFormatSymbols, java.util.Locale" %>
<%!
  // Escape semplice
  private static String esc(Object o){
    if (o == null) return "";
    String s = String.valueOf(o);
    return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
            .replace("\"","&quot;").replace("'","&#39;");
  }
  // Normalizza path immagine
  private String normImg(String p, String ctx){
    if (p == null || p.isBlank()) return null;
    String s = p.trim();
    if (s.startsWith("http://") || s.startsWith("https://") || s.startsWith("//")) return s;
    if (s.startsWith("/")) return ctx + s;
    return ctx + "/" + s;
  }
  // Resolve immagine con fallback
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
      return ctx + "/images/placeholder.jpg";
    }
  }
%>

<%
  // Context & helpers
  String ctx = request.getContextPath();
  DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");

  // Formattazione € IT
  DecimalFormatSymbols sy = new DecimalFormatSymbols(Locale.ITALY);
  sy.setDecimalSeparator(',');
  sy.setGroupingSeparator('.');
  DecimalFormat money = new DecimalFormat("#,##0.00", sy);

  // Recupera cartItems da request o fallback session, filtrando i tipi (niente unchecked)
  List<CartItem> items = new ArrayList<>();
  Object reqAttr = request.getAttribute("cartItems");
  Object sesAttr = (reqAttr == null) ? session.getAttribute("cartItems") : null;
  if (reqAttr instanceof List<?>) {
    for (Object x : (List<?>) reqAttr) if (x instanceof CartItem) items.add((CartItem) x);
  } else if (sesAttr instanceof List<?>) {
    for (Object x : (List<?>) sesAttr) if (x instanceof CartItem) items.add((CartItem) x);
  }

  String csrf = (String) session.getAttribute("csrfToken"); // header.jsp lo crea se assente
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Carrello - RedBull Spielberg Experience</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/userLogo.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/shop.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/cart.css">
</head>
<body>
<jsp:include page="header.jsp" />

<div class="cart-wrap" aria-live="polite">
  <%
    if (items.isEmpty()) {
  %>
    <p class="empty">Il tuo carrello è vuoto.
      <a class="btn" href="<%=ctx%>/shop" style="margin-left:8px;">Vai allo shop</a>
    </p>
  <%
    } else {
      BigDecimal total = BigDecimal.ZERO;
  %>
    <table class="cart-table">
      <thead>
        <tr>
          <th scope="col">Prodotto</th>
          <th scope="col">Tipo</th>
          <th scope="col">Prezzo</th>
          <th scope="col">Qty</th>
          <th scope="col">Subtotale</th>
          <th scope="col">Azioni</th>
        </tr>
      </thead>
      <tbody>
      <%
        for (CartItem it : items) {
          total = total.add(it.getTotal());

          String img = resolveImg(it.getImageUrl(), it.getVehicleCode(), it.getProductType(), ctx);
      %>
        <tr>
          <td>
            <img class="cart-img"
                 src="<%= img %>"
                 alt="<%= esc(it.getProductName()) %>"
                 onerror="this.onerror=null;this.src='<%=ctx%>/images/vehicles/placeholder-vehicle.jpg';">
            &nbsp; <strong><%= esc(it.getProductName()) %></strong>

            <% if (it.getSlotId() != null) { %>
              <br/><small>Slot: <%= it.getSlotId() %></small>
            <% } %>
            <% if (it.getDriverName() != null && !it.getDriverName().isBlank()) { %>
              <br/><small>Pilota: <%= esc(it.getDriverName()) %></small>
            <% } %>
            <% if (it.getCompanionName() != null && !it.getCompanionName().isBlank()) { %>
              <br/><small>Accompagnatore: <%= esc(it.getCompanionName()) %></small>
            <% } %>
            <% if (it.getVehicleCode() != null && !it.getVehicleCode().isBlank()) { %>
              <br/><small>Veicolo: <%= esc(it.getVehicleCode()) %></small>
            <% } %>
            <% if (it.getEventDate() != null) { %>
              <br/><small>Data: <%= it.getEventDate().format(dateFmt) %></small>
            <% } %>
          </td>

          <td><%= esc(it.getProductType()) %></td>
          <td>€ <%= money.format(it.getUnitPrice()) %></td>

          <td>
            <%
              if ("EXPERIENCE".equalsIgnoreCase(it.getProductType())) {
            %>
                1
            <%
              } else {
            %>
                <!-- POST aggiornamento quantità (CSRF incluso) -->
                <form action="<%= ctx %>/cart/update" method="post" class="inline-form js-update-qty" novalidate>
                  <% if (csrf != null) { %><input type="hidden" name="csrf" value="<%= csrf %>"><% } %>
                  <input type="hidden" name="productId" value="<%= it.getProductId() %>">
                  <input type="hidden" name="slotId" value="<%= it.getSlotId() == null ? "" : it.getSlotId() %>">
                  <input class="qty-input" type="number" name="quantity" min="1" value="<%= it.getQuantity() %>">
                  <button class="btn" type="submit">Aggiorna</button>
                </form>
            <%
              }
            %>
          </td>

          <td>€ <%= money.format(it.getTotal()) %></td>

          <td>
            <!-- Rimuovi -->
            <form action="<%= ctx %>/cart/remove" method="post" class="inline-form">
              <% if (csrf != null) { %><input type="hidden" name="csrf" value="<%= csrf %>"><% } %>
              <input type="hidden" name="productId" value="<%= it.getProductId() %>">
              <input type="hidden" name="slotId" value="<%= it.getSlotId() == null ? "" : it.getSlotId() %>">
              <button class="btn secondary" type="submit">Rimuovi</button>
            </form>
          </td>
        </tr>
      <%
        } // end for
      %>
      </tbody>
    </table>

    <div class="summary">
      <span class="total">Totale: € <%= money.format(total) %></span>

      <!-- Svuota -->
      <form action="<%= ctx %>/cart/clear" method="post">
        <% if (csrf != null) { %><input type="hidden" name="csrf" value="<%= csrf %>"><% } %>
        <button class="btn secondary" type="submit">Svuota</button>
      </form>

      <form action="<%= ctx %>/checkout" method="get">
        <button class="btn" type="submit">Checkout</button>
      </form>
    </div>
  <%
    } // end else
  %>
</div>

<jsp:include page="footer.jsp" />
<script src="<%=ctx%>/scripts/cart.js"></script>
</body>
</html>