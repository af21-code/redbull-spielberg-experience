<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.math.BigDecimal" %>
<%@ page import="model.Product, model.Product.ProductType" %>
<%@ page import="java.text.DecimalFormat, java.text.DecimalFormatSymbols, java.util.Locale" %>
<%!
  private static String esc(Object o){
    if (o == null) return "";
    String s = String.valueOf(o);
    return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
            .replace("\"","&quot;").replace("'","&#39;");
  }
  private String normImg(String p, String ctx){
    if (p == null || p.isBlank()) return null;
    String s = p.trim();
    if (s.startsWith("http://") || s.startsWith("https://") || s.startsWith("//")) return s;
    if (s.startsWith("/")) return ctx + s;
    return ctx + "/" + s;
  }
%>
<%
  String ctx = request.getContextPath();
  String csrf = (String) session.getAttribute("csrfToken");

  // Recupera lista prodotti in modo safe (niente unchecked cast)
  List<Product> products = new ArrayList<>();
  Object prodAttr = request.getAttribute("products");
  if (prodAttr instanceof List<?>) {
    for (Object x : (List<?>) prodAttr) if (x instanceof Product) products.add((Product) x);
  }

  // Formatter prezzo IT
  DecimalFormatSymbols sy = new DecimalFormatSymbols(Locale.ITALY);
  sy.setDecimalSeparator(',');
  sy.setGroupingSeparator('.');
  DecimalFormat money = new DecimalFormat("#,##0.00", sy);
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Shop - RedBull Spielberg Experience</title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/userLogo.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/shop.css?v=6">
  <link href="https://fonts.googleapis.com/css2?family=Teko:wght@500;700&family=Barlow+Condensed:wght@500;700&display=swap" rel="stylesheet">
</head>
<body class="page-shop">
<jsp:include page="header.jsp" />

<!-- HERO con immagine passata via CSS variable -->
<section class="shop-hero" style="--hero:url('<%=ctx%>/images/shop-hero.jpg')">
  <div class="shop-hero__overlay">
    <h1>RB OFFICIAL SHOP</h1>
    <p>Caps, polo, collezionabili e molto altro.</p>
  </div>
</section>

<section class="shop-container">
  <div class="shop-toolbar">
    <form class="filter" method="get" action="<%=ctx%>/shop">
      <select name="category" onchange="this.form.submit()">
        <option value="">Tutte le categorie</option>
        <option value="2" <%= "2".equals(request.getParameter("category")) ? "selected" : "" %>>Abbigliamento</option>
        <option value="3" <%= "3".equals(request.getParameter("category")) ? "selected" : "" %>>Collezionabili</option>
        <option value="4" <%= "4".equals(request.getParameter("category")) ? "selected" : "" %>>Accessori</option>
      </select>
    </form>
  </div>

  <div class="product-grid">
    <%
      if (products.isEmpty()) {
    %>
      <p class="empty">Nessun prodotto disponibile.</p>
    <%
      } else {
        for (Product p : products) {
          String img = normImg(p.getImageUrl(), ctx);
          if (img == null) img = "https://via.placeholder.com/400x300?text=Red+Bull";
          boolean isMerch = (p.getProductType() == ProductType.MERCHANDISE);
          boolean hasStock = (p.getStockQuantity() != null);
          boolean outOfStock = hasStock && p.getStockQuantity() == 0;
          BigDecimal price = p.getPrice() == null ? BigDecimal.ZERO : p.getPrice();
    %>
      <div class="product-card">
        <div class="product-image">
          <img src="<%= img %>" alt="<%= esc(p.getName()) %>"
               onerror="this.onerror=null;this.src='https://via.placeholder.com/400x300?text=Red+Bull';">
        </div>
        <div class="product-info">
          <h3><%= esc(p.getName()) %></h3>
          <p class="desc"><%= esc(p.getShortDescription()) %></p>
          <div class="meta">
            <span class="price">€ <%= money.format(price) %></span>
            <% if (isMerch && hasStock) { %>
              <span class="stock <%= (p.getStockQuantity() > 0 ? "in" : "out") %>">
                <%= p.getStockQuantity() > 0 ? "Disponibile" : "Esaurito" %>
              </span>
            <% } %>
          </div>

          <form class="add-to-cart" action="<%=ctx%>/cart/add" method="post">
            <% if (csrf != null) { %><input type="hidden" name="csrf" value="<%= csrf %>"><% } %>
            <input type="hidden" name="productId" value="<%= p.getProductId() %>">
            <input type="hidden" name="quantity" value="1">

            <!-- Hidden per carrello guest (sessione) -->
            <input type="hidden" name="name" value="<%= esc(p.getName()) %>">
            <input type="hidden" name="imageUrl" value="<%= p.getImageUrl() == null ? "" : esc(p.getImageUrl()) %>">
            <input type="hidden" name="price" value="<%= price %>">
            <input type="hidden" name="productType" value="<%= p.getProductType().name() %>">

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