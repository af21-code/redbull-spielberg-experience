<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.math.BigDecimal, model.CartItem" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Carrello - RedBull Spielberg Experience</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/indexStyle.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/userLogo.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/shop.css">
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

            <%-- Data evento: parse sicuro + fallback --%>
            <% if (it.getEventDate() != null && !it.getEventDate().isBlank()) { %>
              <br/><small>Data:
                <%
                  String _s = it.getEventDate();
                  try {
                    java.time.LocalDate _d = java.time.LocalDate.parse(_s); // atteso yyyy-MM-dd
                    out.print(_d.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")));
                  } catch (Exception ex) {
                    out.print(_s); // se non è nel formato atteso, mostra com'è
                  }
                %>
              </small>
            <% } %>
          </td>

          <td><%= it.getProductType() %></td>
          <td>€ <%= it.getUnitPrice() %></td>

          <td>
            <%
              if ("EXPERIENCE".equalsIgnoreCase(it.getProductType())) {
            %>
                1
            <%
              } else {
            %>
                <form action="<%= ctx %>/cart/update" method="post" class="inline-form">
                  <input type="hidden" name="productId" value="<%= it.getProductId() %>">
                  <input type="hidden" name="slotId" value="<%= it.getSlotId() == null ? "" : it.getSlotId() %>">
                  <input class="qty-input" type="number" name="quantity" min="1" value="<%= it.getQuantity() %>">
                  <button class="btn" type="submit">Aggiorna</button>
                </form>
            <%
              }
            %>
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