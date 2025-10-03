<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.math.BigDecimal" %>
<%@ page import="model.Product" %>
<%@ page import="model.Product.ProductType, model.Product.ExperienceType" %>
<%!
  // Escape HTML semplice
  private static String esc(Object o){
    if (o == null) return "";
    String s = String.valueOf(o);
    return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
            .replace("\"","&quot;").replace("'","&#39;");
  }

  // Cast helper senza unchecked warning
  private static List<Product> asProducts(Object obj){
    List<Product> out = new ArrayList<>();
    if (obj instanceof List<?>){
      for (Object x : (List<?>) obj) if (x instanceof Product) out.add((Product) x);
    }
    return out;
  }
%>
<%
  String ctx = request.getContextPath();

  // Recupero lista prodotti in modo typesafe
  List<Product> products = asProducts(request.getAttribute("products"));
  if (products == null) products = Collections.emptyList();

  String q = request.getParameter("q") == null ? "" : request.getParameter("q");
  String type = request.getParameter("type") == null ? "" : request.getParameter("type");
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Admin · Prodotti</title>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/admin.css?v=1">
  <style>
    .wrap{padding:30px 18px 80px;background:linear-gradient(135deg,#001e36 0%,#000b2b 100%);min-height:60vh;color:#fff}
    .container{max-width:1200px;margin:0 auto}
    .card{background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.15);border-radius:16px;padding:16px}
    .row{display:flex;gap:12px;flex-wrap:wrap;align-items:center}
    .filters input,.filters select{background:#001E36;color:#fff;border:1px solid #0a3565;border-radius:10px;padding:8px 10px}
    .btn{background:#444;color:#fff;border:none;border-radius:10px;padding:10px 14px;font-weight:700;cursor:pointer;text-decoration:none}
    .btn.primary{background:#E30613}
    table{width:100%;border-collapse:collapse}
    th,td{padding:10px;border-bottom:1px solid rgba(255,255,255,.15);vertical-align:top}
    .pill{display:inline-block;padding:2px 8px;border:1px solid rgba(255,255,255,.3);border-radius:999px}
  </style>
</head>
<body>
<jsp:include page="/views/header.jsp" />

<div class="wrap">
  <div class="container">
    <div class="row" style="justify-content:space-between;align-items:center">
      <h2 style="margin:0">Prodotti (Admin)</h2>
      <a class="btn primary" href="<%=ctx%>/admin/products/new">+ Nuovo prodotto</a>
    </div>

    <div class="card filters" style="margin-top:14px">
      <form method="get" action="<%=ctx%>/admin/products" class="row" style="align-items:flex-end">
        <div>
          <label>Search</label>
          <input type="text" name="q" value="<%= esc(q) %>" placeholder="Nome/descrizione">
        </div>
        <div>
          <label>Tipo</label>
          <select name="type">
            <option value="" <%= type.isBlank()?"selected":"" %>>Tutti</option>
            <option value="MERCHANDISE" <%= "MERCHANDISE".equals(type)?"selected":"" %>>MERCHANDISE</option>
            <option value="EXPERIENCE"  <%= "EXPERIENCE".equals(type) ?"selected":"" %>>EXPERIENCE</option>
          </select>
        </div>
        <div><button class="btn primary">Filtra</button></div>
      </form>
    </div>

    <div class="card" style="margin-top:14px">
      <table>
        <thead>
        <tr>
          <th>ID</th>
          <th>Nome</th>
          <th>Tipo</th>
          <th>Experience</th>
          <th>Prezzo</th>
          <th>Stock</th>
          <th>Active</th>
          <th>Feat.</th>
          <th></th>
        </tr>
        </thead>
        <tbody>
        <% if (products.isEmpty()) { %>
          <tr><td colspan="9" style="opacity:.8">Nessun prodotto trovato.</td></tr>
        <% } %>
        <%
          for (Product p : products) {
            // ID come Number per compatibilità (Integer oggi, Long domani)
            Number idNum = p.getProductId();
            String idStr = idNum == null ? "" : String.valueOf(idNum);

            String name = p.getName();
            ProductType pt = p.getProductType();
            ExperienceType et = p.getExperienceType();
            BigDecimal price = p.getPrice();
            Integer stock = p.getStockQuantity();
            Boolean active = p.getActive();
            Boolean feat = p.getFeatured();
        %>
          <tr>
            <td><%= idStr.isEmpty() ? "—" : idStr %></td>
            <td><strong><%= esc(name) %></strong></td>
            <td><span class="pill"><%= (pt==null?"—":pt.name()) %></span></td>
            <td><%= (et==null?"—":et.name()) %></td>
            <td>€ <%= price == null ? "0" : price %></td>
            <td><%= stock == null ? "—" : stock %></td>
            <td><%= Boolean.TRUE.equals(active) ? "Sì" : "No" %></td>
            <td><%= Boolean.TRUE.equals(feat)   ? "Sì" : "No" %></td>
            <td>
              <a class="pill" href="<%=ctx%>/admin/products/edit?id=<%= esc(idStr) %>">Modifica</a>
            </td>
          </tr>
        <% } %>
        </tbody>
      </table>
    </div>
  </div>
</div>

<jsp:include page="/views/footer.jsp" />
</body>
</html>