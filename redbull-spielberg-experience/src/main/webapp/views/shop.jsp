<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.Product, model.Product.ProductType" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Shop - RedBull Spielberg Experience</title>
  <!-- CSS globali + icona logout -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/indexStyle.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/userLogo.css">
  <!-- CSS della pagina shop -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/shop.css">
</head>
<body class="page-shop">
<jsp:include page="header.jsp" flush="true">
  <jsp:param name="active" value="shop" />
</jsp:include>

<section class="shop-hero">
  <div class="shop-hero__overlay">
    <h1>Official Shop</h1>
    <p>Caps, hoodies, collectibles and more.</p>
  </div>
</section>

<section class="shop-container">
  <div class="shop-toolbar">
    <form class="filter" method="get" action="${pageContext.request.contextPath}/shop">
      <select name="category" onchange="this.form.submit()">
        <option value="">All categories</option>
        <option value="2" <%= "2".equals(request.getParameter("category")) ? "selected" : "" %>>Apparel</option>
        <option value="3" <%= "3".equals(request.getParameter("category")) ? "selected" : "" %>>Models And Collectibles</option>
        <option value="4" <%= "4".equals(request.getParameter("category")) ? "selected" : "" %>>Accessories</option>
      </select>
    </form>
  </div>

  <div class="product-grid">
    <%
      List<Product> products = (List<Product>) request.getAttribute("products");
      if (products == null || products.isEmpty()) {
    %>
      <p class="empty">Nessun prodotto disponibile.</p>
    <%
      } else {
        for (Product p : products) {
          String img = (p.getImageUrl() != null && !p.getImageUrl().isBlank())
                     ? (request.getContextPath() + "/" + p.getImageUrl())
                     : "https://via.placeholder.com/400x300?text=Red+Bull";
          boolean isMerch = (p.getProductType() == ProductType.MERCHANDISE);
          boolean hasStock = (p.getStockQuantity() != null);
          boolean outOfStock = hasStock && p.getStockQuantity() == 0;
    %>
      <div class="product-card">
        <div class="product-image">
          <img src="<%= img %>" alt="<%= p.getName() %>">
        </div>
        <div class="product-info">
          <h3><%= p.getName() %></h3>
          <p class="desc"><%= (p.getShortDescription() != null ? p.getShortDescription() : "") %></p>
          <div class="meta">
            <span class="price">€ <%= p.getPrice() %></span>
            <% if (isMerch && hasStock) { %>
              <span class="stock <%= (p.getStockQuantity() > 0 ? "in" : "out") %>">
                <%= p.getStockQuantity() > 0 ? "Disponibile" : "Esaurito" %>
              </span>
            <% } %>
          </div>

          <form class="add-to-cart" action="${pageContext.request.contextPath}/cart/add" method="post">
            <input type="hidden" name="productId" value="<%= p.getProductId() %>">
            <input type="hidden" name="quantity" value="1">

            <!-- Hidden per carrello guest (sessione) -->
            <input type="hidden" name="name" value="<%= p.getName() %>">
            <input type="hidden" name="imageUrl" value="<%= (p.getImageUrl() == null ? "" : p.getImageUrl()) %>">
            <input type="hidden" name="price" value="<%= p.getPrice() %>">
            <input type="hidden" name="productType" value="<%= p.getProductType().name() %>">

            <%-- In futuro, per le esperienze con slot: <input type="hidden" name="slotId" value="..."> --%>

            <button type="submit" <%= (isMerch && outOfStock) ? "disabled" : "" %>>
              Aggiungi al carrello
            </button>
          </form>
        </div>
      </div>
    <%
        }
      }
    %>
  </div>
</section>

<jsp:include page="footer.jsp" />
</body>
</html>