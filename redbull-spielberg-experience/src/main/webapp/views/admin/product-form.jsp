<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Product" %>
<%
  String ctx = request.getContextPath();
  Product p = (Product) request.getAttribute("product");
  boolean isEdit = (p != null && p.getProductId()!=null);
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Admin · Prodotti</title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/admin.css?v=1">
</head>
<body>
<jsp:include page="../header.jsp"/>
<div class="wrap">
  <div class="card">
    <div class="top">
      <h2><%= isEdit?"Modifica":"Nuovo" %> prodotto</h2>
      <a class="btn" href="<%=ctx%>/admin/products">Torna alla lista</a>
    </div>

    <form method="post" action="<%=ctx%>/admin/products/save">
      <% if (isEdit) { %>
        <input type="hidden" name="productId" value="<%=p.getProductId()%>">
      <% } %>

      <div class="row">
        <div>
          <label>Nome</label>
          <input name="name" required value="<%=isEdit?p.getName():""%>">
        </div>
        <div>
          <label>Categoria (id)</label>
          <input type="number" name="categoryId" min="1" value="<%= isEdit && p.getCategoryId()!=null ? p.getCategoryId() : "" %>">
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
            <option value="BASE"    <%= isEdit && p.getExperienceType()==Product.ExperienceType.BASE ? "selected":"" %>>BASE</option>
            <option value="PREMIUM" <%= isEdit && p.getExperienceType()==Product.ExperienceType.PREMIUM ? "selected":"" %>>PREMIUM</option>
            <option value="ELITE"   <%= isEdit && p.getExperienceType()==Product.ExperienceType.ELITE ? "selected":"" %>>ELITE</option>
          </select>
        </div>
      </div>

      <div class="row">
        <div>
          <label>Prezzo (€)</label>
          <input type="number" step="0.01" name="price" required value="<%= isEdit ? p.getPrice() : "" %>">
        </div>
        <div>
          <label>Stock (solo MERCH)</label>
          <input type="number" min="0" name="stockQuantity" value="<%= isEdit && p.getStockQuantity()!=null ? p.getStockQuantity() : "" %>">
        </div>
      </div>

      <div>
        <label>Short description</label>
        <input name="shortDescription" value="<%= isEdit? p.getShortDescription():"" %>">
      </div>

      <div>
        <label>Descrizione</label>
        <textarea name="description" rows="5"><%= isEdit? p.getDescription():"" %></textarea>
      </div>

      <div class="row">
        <div>
          <label>Immagine (URL)</label>
          <input name="imageUrl" value="<%= isEdit? p.getImageUrl():"" %>">
        </div>
        <div style="display:flex;gap:14px;align-items:center;margin-top:28px">
          <label><input type="checkbox" name="featured" <%= isEdit && Boolean.TRUE.equals(p.getFeatured())?"checked":"" %>> Featured</label>
          <label><input type="checkbox" name="active"   <%= isEdit ? (Boolean.TRUE.equals(p.getActive())?"checked":"") : "checked" %>> Attivo</label>
        </div>
      </div>

      <div style="margin-top:12px">
        <button class="btn" type="submit"><%= isEdit?"Salva modifiche":"Crea prodotto" %></button>
      </div>
    </form>
  </div>
</div>
<jsp:include page="../footer.jsp"/>
</body>
</html>