<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.Product" %>
<%
  String ctx = request.getContextPath();
  List<Product> list = (List<Product>) request.getAttribute("products");
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
  <div class="top">
    <form method="get" action="<%=ctx%>/admin/products" style="display:flex;gap:8px;flex-wrap:wrap">
      <input type="text" name="q" placeholder="Cerca nome…" value="<%= request.getParameter("q")==null?"":request.getParameter("q") %>">
      <input type="number" name="categoryId" placeholder="Categoria (id)" value="<%= request.getParameter("categoryId")==null?"":request.getParameter("categoryId") %>" min="1">
      <label style="display:flex;gap:6px;align-items:center" class="muted">
        <input type="checkbox" name="onlyInactive" value="1" <%= "1".equals(request.getParameter("onlyInactive"))?"checked":"" %>> Solo non attivi
      </label>
      <button class="btn" type="submit">Filtra</button>
    </form>
    <a class="btn red" href="<%=ctx%>/admin/products/edit">+ Nuovo prodotto</a>
  </div>

  <div class="card">
    <table>
      <thead>
        <tr>
          <th>ID</th><th>Nome</th><th>Tipo</th><th>Stock</th><th>Attivo</th><th>Featured</th><th>Prezzo</th><th></th>
        </tr>
      </thead>
      <tbody>
      <% if (list!=null) for (Product p : list) { %>
        <tr>
          <td><%= p.getProductId() %></td>
          <td><%= p.getName() %></td>
          <td><%= p.getProductType() %> <%= p.getExperienceType()==null?"":"("+p.getExperienceType()+")" %></td>
          <td><%= p.getStockQuantity()==null?"—":p.getStockQuantity() %></td>
          <td><%= Boolean.TRUE.equals(p.getActive())?"✅":"❌" %></td>
          <td><%= Boolean.TRUE.equals(p.getFeatured())?"⭐":"—" %></td>
          <td>€ <%= p.getPrice() %></td>
          <td style="display:flex;gap:6px;justify-content:flex-end">
            <a class="btn gray" href="<%=ctx%>/admin/products/edit?id=<%=p.getProductId()%>">Modifica</a>
            <form method="post" action="<%=ctx%>/admin/products/toggle">
              <input type="hidden" name="id" value="<%=p.getProductId()%>">
              <input type="hidden" name="active" value="<%= Boolean.TRUE.equals(p.getActive())? "0":"1" %>">
              <button class="btn" type="submit"><%= Boolean.TRUE.equals(p.getActive())? "Disattiva":"Attiva" %></button>
            </form>
            <form method="post" action="<%=ctx%>/admin/products/feature">
              <input type="hidden" name="id" value="<%=p.getProductId()%>">
              <input type="hidden" name="featured" value="<%= Boolean.TRUE.equals(p.getFeatured())? "0":"1" %>">
              <button class="btn" type="submit"><%= Boolean.TRUE.equals(p.getFeatured())? "Unstar":"Star" %></button>
            </form>
            <form method="post" action="<%=ctx%>/admin/products/delete" onsubmit="return confirm('Confermi la disattivazione?');">
              <input type="hidden" name="id" value="<%=p.getProductId()%>">
              <button class="btn red" type="submit">Elimina</button>
            </form>
          </td>
        </tr>
      <% } %>
      </tbody>
    </table>
  </div>
</div>
<jsp:include page="../footer.jsp"/>
</body>
</html>