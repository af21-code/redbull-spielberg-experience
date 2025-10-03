<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Product" %>
<%!
  private static String esc(Object o) {
    if (o == null) return "";
    String s = String.valueOf(o);
    return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
            .replace("\"","&quot;").replace("'","&#39;");
  }
%>
<%
  String ctx = request.getContextPath();
  Product p = (Product) request.getAttribute("product");
  boolean isEdit = (p != null && p.getProductId() != null);

  String nameVal   = isEdit ? esc(p.getName()) : "";
  String catVal    = isEdit && p.getCategoryId() != null ? esc(String.valueOf(p.getCategoryId())) : "";
  String priceVal  = isEdit && p.getPrice() != null ? esc(String.valueOf(p.getPrice())) : "";
  String stockVal  = isEdit && p.getStockQuantity() != null ? esc(String.valueOf(p.getStockQuantity())) : "";
  String shortDesc = isEdit ? esc(p.getShortDescription()) : "";
  String descVal   = isEdit ? esc(p.getDescription()) : "";
  String imgVal    = isEdit ? esc(p.getImageUrl()) : "";

  boolean isFeatured = isEdit && Boolean.TRUE.equals(p.getFeatured());
  boolean isActive   = !isEdit || Boolean.TRUE.equals(p.getActive());
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Admin · Prodotti</title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/admin.css?v=1">
</head>
<body>
<jsp:include page="../header.jsp"/>
<div class="wrap">
  <div class="card">
    <div class="top">
      <h2><%= isEdit ? "Modifica" : "Nuovo" %> prodotto</h2>
      <a class="btn" href="<%=ctx%>/admin/products">Torna alla lista</a>
    </div>

    <form method="post" action="<%=ctx%>/admin/products/save">
      <input type="hidden" name="csrf" value="${csrfToken}">
      <% if (isEdit) { %>
        <input type="hidden" name="productId" value="<%= p.getProductId() %>">
      <% } %>

      <div class="row">
        <div>
          <label>Nome</label>
          <input name="name" required value="<%= nameVal %>">
        </div>
        <div>
          <label>Categoria (id)</label>
          <input type="number" name="categoryId" min="1" value="<%= catVal %>">
        </div>
      </div>

      <div class="row">
        <div>
          <label>Tipo</label>
          <select name="productType" required>
            <option value="MERCHANDISE" <%= isEdit && p.getProductType()==Product.ProductType.MERCHANDISE ? "selected":"" %>>MERCHANDISE</option>
            <option value="EXPERIENCE"  <%= isEdit && p.getProductType()==Product.ProductType.EXPERIENCE  ? "selected":"" %>>EXPERIENCE</option>
          </select>
        </div>
        <div>
          <label>Experience type (se EXPERIENCE)</label>
          <select name="experienceType">
            <option value="">—</option>
            <option value="BASE"    <%= isEdit && p.getExperienceType()==Product.ExperienceType.BASE    ? "selected":"" %>>BASE</option>
            <option value="PREMIUM" <%= isEdit && p.getExperienceType()==Product.ExperienceType.PREMIUM ? "selected":"" %>>PREMIUM</option>
            <option value="ELITE"   <%= isEdit && p.getExperienceType()==Product.ExperienceType.ELITE   ? "selected":"" %>>ELITE</option>
          </select>
        </div>
      </div>

      <div class="row">
        <div>
          <label>Prezzo (€)</label>
          <input type="number" step="0.01" name="price" required value="<%= priceVal %>">
        </div>
        <div>
          <label>Stock (solo MERCH)</label>
          <input type="number" min="0" name="stockQuantity" value="<%= stockVal %>">
        </div>
      </div>

      <div>
        <label>Short description</label>
        <input name="shortDescription" value="<%= shortDesc %>">
      </div>

      <div>
        <label>Descrizione</label>
        <textarea name="description" rows="5"><%= descVal %></textarea>
      </div>

      <div class="row">
        <div>
          <label>Immagine (URL)</label>
          <input name="imageUrl" value="<%= imgVal %>">
        </div>
        <div style="display:flex;gap:14px;align-items:center;margin-top:28px">
          <label><input type="checkbox" name="featured" <%= isFeatured ? "checked" : "" %>> Featured</label>
          <label><input type="checkbox" name="active"   <%= isActive   ? "checked" : "" %>> Attivo</label>
        </div>
      </div>

      <div style="margin-top:12px">
        <button class="btn" type="submit"><%= isEdit ? "Salva modifiche" : "Crea prodotto" %></button>
      </div>
    </form>
  </div>
</div>
<jsp:include page="../footer.jsp"/>
</body>
</html>