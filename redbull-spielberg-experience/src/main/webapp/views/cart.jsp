<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.math.BigDecimal, model.CartItem" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Carrello - RedBull Spielberg Experience</title>
  <!-- Stili globali -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/indexStyle.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/userLogo.css">
  <!-- Stili condivisi dello shop (palette, bottoni) -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/shop.css">
  <!-- Stili specifici del carrello -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/cart.css">
</head>
<body>
<jsp:include page="header.jsp" />

<div class="cart-wrap">
  <%
    List<CartItem> items = (List<CartItem>) request.getAttribute("cartItems");
    if (items == null || items.isEmpty()) {
  %>
    <p class="empty">Il tuo carrello è vuoto.</p>
  <%
    } else {
      BigDecimal total = BigDecimal.ZERO;
      String ctx = request.getContextPath();
  %>
    <table class="cart-table">
      <thead>
        <tr>
          <th>Prodotto</th>
          <th>Tipo</th>
          <th>Prezzo</th>
          <th>Qty</th>
          <th>Subtotale</th>
          <th>Azioni</th>
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
            <% if (it.getSlotId() != null) { %><br/><small>Slot: <%= it.getSlotId() %></small><% } %>
          </td>
          <td><%= it.getProductType() %></td>
          <td>€ <%= it.getUnitPrice() %></td>
          <td>
            <form action="<%= ctx %>/cart/update" method="post" class="inline-form">
              <input type="hidden" name="productId" value="<%= it.getProductId() %>">
              <input type="hidden" name="slotId" value="<%= it.getSlotId() == null ? "" : it.getSlotId() %>">
              <input class="qty-input" type="number" name="quantity" min="1" value="<%= it.getQuantity() %>">
              <button class="btn" type="submit">Aggiorna</button>
            </form>
          </td>
          <td>€ <%= it.getTotal() %></td>
          <td>
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
      <span class="total">Totale: € <%= total %></span>
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
</body>
</html>