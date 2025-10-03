<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.time.*, java.time.format.DateTimeFormatter" %>
<%@ page import="model.Product" %>

<%!
  private static String esc(Object o){
    if (o == null) return "";
    String s = String.valueOf(o);
    return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
            .replace("\"","&quot;").replace("'","&#39;");
  }
  private static String boolIcon(boolean b){
    return b ? "✅" : "—";
  }
%>

<%
  String ctx = request.getContextPath();

  @SuppressWarnings("unchecked")
  List<Product> products = (List<Product>) request.getAttribute("products");

  String q = (String) request.getAttribute("q");
  Integer categoryId = (Integer) request.getAttribute("categoryId");
  boolean onlyInactive = Boolean.TRUE.equals(request.getAttribute("onlyInactive"));

  // NON usare "page" come nome variabile: collide con l'oggetto implicito JSP "page"
  int pageNum   = (request.getAttribute("page")      instanceof Integer) ? (Integer) request.getAttribute("page") : 1;
  int pageSize  = (request.getAttribute("pageSize")  instanceof Integer) ? (Integer) request.getAttribute("pageSize") : 12;
  int total     = (request.getAttribute("total")     instanceof Integer) ? (Integer) request.getAttribute("total") : (products==null?0:products.size());
  int totalPages= (request.getAttribute("totalPages")instanceof Integer) ? (Integer) request.getAttribute("totalPages") : 1;
  String sortBy = (String) request.getAttribute("sortBy");
  String sortDir= (String) request.getAttribute("sortDir");
  if (sortBy == null) sortBy = "updated_at";
  if (sortDir == null) sortDir = "desc";

  DateTimeFormatter df = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>

<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Admin • Prodotti</title>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <style>
    .page-wrap{padding:28px 16px 80px;background:linear-gradient(135deg,#001e36 0%,#000b2b 100%);color:#fff;min-height:60vh}
    .container{max-width:1150px;margin:0 auto}
    .card{background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.15);border-radius:14px;padding:14px}
    .toolbar{display:flex;gap:10px;flex-wrap:wrap;align-items:center;justify-content:space-between;margin-bottom:12px}
    .filters{display:flex;gap:10px;flex-wrap:wrap;align-items:center}
    .filters input,.filters select{background:#001E36;color:#fff;border:1px solid #0a3565;border-radius:10px;padding:8px 10px}
    .btn{background:#444;color:#fff;border:none;border-radius:10px;padding:9px 12px;font-weight:700;cursor:pointer;text-decoration:none;display:inline-block}
    .btn.primary{background:#E30613}
    .table{width:100%;border-collapse:collapse}
    .table th,.table td{padding:10px;border-bottom:1px solid rgba(255,255,255,.15);text-align:left}
    .table th a{color:#fff;text-decoration:none}
    .pager{display:flex;gap:8px;align-items:center;justify-content:flex-end;margin-top:10px;flex-wrap:wrap}
    .badge{display:inline-block;padding:4px 8px;border-radius:999px;background:rgba(255,255,255,.12)}
    .muted{opacity:.85}
  </style>
</head>
<body>
<jsp:include page="/views/header.jsp" />

<div class="page-wrap">
  <div class="container">
    <div class="toolbar">
      <h2 style="margin:0">Prodotti</h2>
      <a href="<%=ctx%>/admin/products/edit" class="btn primary">+ Nuovo prodotto</a>
    </div>

    <div class="card">
      <form class="filters" method="get" action="<%=ctx%>/admin/products">
        <input type="text" name="q" placeholder="Cerca per nome..." value="<%=esc(q)%>">
        <input type="number" name="categoryId" placeholder="Categoria ID" value="<%=categoryId==null? "": String.valueOf(categoryId)%>" min="0">
        <label class="muted" style="display:inline-flex;gap:6px;align-items:center">
          <input type="checkbox" name="onlyInactive" value="1" <%= onlyInactive ? "checked": "" %> > solo non attivi
        </label>
        <select name="pageSize">
          <%
            int[] sizes = {12,20,50,100};
            for (int s : sizes) {
          %>
            <option value="<%=s%>" <%= (s==pageSize)?"selected":"" %>><%=s%> per pagina</option>
          <% } %>
        </select>
        <input type="hidden" name="sortBy" value="<%=esc(sortBy)%>">
        <input type="hidden" name="sortDir" value="<%=esc(sortDir)%>">
        <button class="btn">Applica</button>
      </form>
    </div>

    <div class="card" style="margin-top:12px">
      <%
        String base = ctx + "/admin/products";
        String keepQ = "q=" + java.net.URLEncoder.encode(q==null?"":q, "UTF-8")
                     + (categoryId!=null ? "&categoryId="+categoryId : "")
                     + (onlyInactive ? "&onlyInactive=1" : "")
                     + "&pageSize=" + pageSize;

        String sortArrow = sortDir.equalsIgnoreCase("asc") ? "↑" : "↓";
        String toggleDir = sortDir.equalsIgnoreCase("asc") ? "desc" : "asc";

        String[] cols = {"product_id","name","price","stock_quantity","is_active","is_featured","created_at","updated_at"};
        Map<String,String> labels = new LinkedHashMap<>();
        labels.put("product_id","ID");
        labels.put("name","Nome");
        labels.put("price","Prezzo");
        labels.put("stock_quantity","Stock");
        labels.put("is_active","Attivo");
        labels.put("is_featured","Featured");
        labels.put("created_at","Creato");
        labels.put("updated_at","Aggiornato");
      %>
      <table class="table">
        <thead>
        <tr>
          <% for (String c : cols) {
               String dir = c.equals(sortBy) ? toggleDir : "asc";
               String url = base + "?" + keepQ + "&sortBy=" + c + "&sortDir=" + dir + "&page=1";
          %>
            <th>
              <a href="<%=url%>"><%= labels.get(c) %>
                <% if (c.equals(sortBy)) { %> <span class="muted"><%=sortArrow%></span> <% } %>
              </a>
            </th>
          <% } %>
          <th>Azioni</th>
        </tr>
        </thead>
        <tbody>
        <% if (products == null || products.isEmpty()) { %>
          <tr><td colspan="9" class="muted">Nessun prodotto trovato.</td></tr>
        <% } else {
             for (Product p : products) {
               String created = p.getCreatedAt()==null ? "—" : df.format(p.getCreatedAt());
               String updated = p.getUpdatedAt()==null ? "—" : df.format(p.getUpdatedAt());
        %>
          <tr>
            <td><%= p.getProductId() %></td>
            <td>
              <div><strong><%= esc(p.getName()) %></strong></div>
              <div class="muted">
                <% if (p.getProductType()!=null) { %>Tipo: <%= p.getProductType().name() %><% } %>
                <% if (p.getExperienceType()!=null) { %> • Exp: <%= p.getExperienceType().name() %><% } %>
              </div>
            </td>
            <td>€ <%= p.getPrice() %></td>
            <td><%= p.getStockQuantity()==null ? "—" : String.valueOf(p.getStockQuantity()) %></td>
            <td><%= boolIcon(Boolean.TRUE.equals(p.getActive())) %></td>
            <td><%= boolIcon(Boolean.TRUE.equals(p.getFeatured())) %></td>
            <td><%= created %></td>
            <td><%= updated %></td>
            <td>
              <a class="btn" href="<%=ctx%>/admin/products/edit?productId=<%=p.getProductId()%>">Modifica</a>
            </td>
          </tr>
        <%   }
           } %>
        </tbody>
      </table>

      <div class="pager">
        <span class="badge">Totale: <strong><%= total %></strong></span>
        <%
          String keepNoPage = keepQ + "&sortBy=" + sortBy + "&sortDir=" + sortDir;
          int prev = Math.max(1, pageNum-1), next = Math.min(totalPages, pageNum+1);
        %>
        <a class="btn <%= pageNum==1 ? "muted":"" %>" href="<%=base%>?<%=keepNoPage%>&page=<%=prev%>">« Prev</a>
        <span class="badge">Pagina <%=pageNum%> / <%=totalPages%></span>
        <a class="btn <%= pageNum==totalPages ? "muted":"" %>" href="<%=base%>?<%=keepNoPage%>&page=<%=next%>">Next »</a>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/views/footer.jsp" />
</body>
</html>