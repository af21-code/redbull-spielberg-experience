<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.math.BigDecimal, java.time.format.DateTimeFormatter" %>
<%@ page import="model.CartItem" %>
<%@ page import="java.text.DecimalFormat, java.text.DecimalFormatSymbols, java.util.Locale" %>
<%
  // Context & helpers
  String ctx = request.getContextPath();
  DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");

  // Formattazione prezzi con separatore italiano
  DecimalFormatSymbols sy = new DecimalFormatSymbols(Locale.ITALY);
  sy.setDecimalSeparator(',');
  sy.setGroupingSeparator('.');
  DecimalFormat money = new DecimalFormat("#,##0.00", sy);

  @SuppressWarnings("unchecked")
  List<CartItem> items = (List<CartItem>) request.getAttribute("cartItems");
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
    if (items == null || items.isEmpty()) {
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
          String img = (it.getImageUrl() != null && !it.getImageUrl().isBlank())
              ? (ctx + "/" + it.getImageUrl())
              : "https://via.placeholder.com/400x300?text=Red+Bull";
      %>
        <tr>
          <td>
            <img class="cart-img" src="<%= img %>" alt="<%= it.getProductName() %>">
            &nbsp; <strong><%= it.getProductName() %></strong>

            <% if (it.getSlotId() != null) { %>
              <br/><small>Slot: <%= it.getSlotId() %></small>
            <% } %>
            <% if (it.getDriverName() != null && !it.getDriverName().isBlank()) { %>
              <br/><small>Pilota: <%= it.getDriverName() %></small>
            <% } %>
            <% if (it.getCompanionName() != null && !it.getCompanionName().isBlank()) { %>
              <br/><small>Accompagnatore: <%= it.getCompanionName() %></small>
            <% } %>
            <% if (it.getVehicleCode() != null && !it.getVehicleCode().isBlank()) { %>
              <br/><small>Veicolo: <%= it.getVehicleCode() %></small>
            <% } %>
            <% if (it.getEventDate() != null) { %>
              <br/><small>Data: <%= it.getEventDate().format(dateFmt) %></small>
            <% } %>
          </td>

          <td><%= it.getProductType() %></td>
          <td>€ <%= money.format(it.getUnitPrice()) %></td>

          <td>
            <%
              if ("EXPERIENCE".equalsIgnoreCase(it.getProductType())) {
            %>
                1
            <%
              } else {
            %>
                <!-- SOLO questo form è gestito via JS (AJAX soft) -->
                <form action="<%= ctx %>/cart/update" method="post" class="inline-form js-update-qty" novalidate>
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
            <!-- Submit normale: raggiunge /cart/remove -->
            <form action="<%= ctx %>/cart/remove" method="post" class="inline-form">
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

      <!-- Submit normale: raggiunge /cart/clear -->
      <form action="<%= ctx %>/cart/clear" method="post">
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