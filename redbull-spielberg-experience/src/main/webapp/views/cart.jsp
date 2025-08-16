<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.math.BigDecimal, model.CartItem" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Carrello - RedBull Spielberg Experience</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/indexStyle.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/userLogo.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/cart.css">
</head>
<body class="page-cart">

<jsp:include page="header.jsp" />

<section class="cart-wrap">
  <h1>Il tuo carrello</h1>

  <%
    List<CartItem> items = (List<CartItem>) request.getAttribute("items");
    BigDecimal subtotal = (BigDecimal) request.getAttribute("subtotal");
    if (items == null || items.isEmpty()) {
  %>
    <p class="empty">Il carrello è vuoto.</p>
  <%
    } else {
  %>

  <div class="cart-table">
    <div class="cart-head">
      <div>Prodotto</div>
      <div>Prezzo</div>
      <div>Quantità</div>
      <div>Totale</div>
      <div></div>
    </div>

    <%
      for (CartItem it : items) {
        String img = (it.getImageUrl() != null && !it.getImageUrl().isBlank())
                   ? (request.getContextPath() + "/" + it.getImageUrl())
                   : "https://via.placeholder.com/100x80?text=RB";
    %>
      <div class="cart-row">
        <div class="prod">
          <img src="<%= img %>" alt="<%= it.getProductName() %>">
          <span><%= it.getProductName() %></span>
        </div>
        <div class="price">€ <%= it.getUnitPrice() %></div>
        <div class="qty">
          <form action="${pageContext.request.contextPath}/cart/update" method="post">
            <input type="hidden" name="productId" value="<%= it.getProductId() %>">
            <input type="hidden" name="slotId" value="<%= it.getSlotId() == null ? "" : it.getSlotId() %>">
            <input type="number" name="quantity" value="<%= it.getQuantity() %>" min="0">
            <button type="submit">Aggiorna</button>
          </form>
        </div>
        <div class="total">€ <%= it.getTotal() %></div>
        <div class="remove">
          <form action="${pageContext.request.contextPath}/cart/remove" method="post">
            <input type="hidden" name="productId" value="<%= it.getProductId() %>">
            <input type="hidden" name="slotId" value="<%= it.getSlotId() == null ? "" : it.getSlotId() %>">
            <button type="submit" class="danger">Rimuovi</button>
          </form>
        </div>
      </div>
    <%
      }
    %>
  </div>

  <div class="cart-summary">
    <div class="line"><span>Subtotale</span><strong>€ <%= subtotal %></strong></div>
    <form action="${pageContext.request.contextPath}/cart/clear" method="post">
      <button type="submit" class="danger">Svuota carrello</button>
    </form>
    <a class="btn-primary" href="#">Procedi al checkout</a>
  </div>

  <%
    }
  %>
</section>

<jsp:include page="footer.jsp" />
</body>
</html>