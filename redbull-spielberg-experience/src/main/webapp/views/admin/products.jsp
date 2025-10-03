<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.Product" %>
<%!
  private static String esc(Object o){
    if (o == null) return "";
    String s = String.valueOf(o);
    return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
            .replace("\"","&quot;").replace("'","&#39;");
  }
  private static String toggledir(String curDir){
    return ("asc".equalsIgnoreCase(curDir)) ? "desc" : "asc";
  }
  private static String sel(Object a, Object b){ return Objects.equals(a,b) ? "selected" : ""; }
%>
<%
  String ctx = request.getContextPath();

  // CSRF
  String csrf = (String) request.getAttribute("csrfToken");
  if (csrf == null || csrf.isBlank()) csrf = (String) session.getAttribute("csrfToken");

  // Filtri GET
  String q = Optional.ofNullable((String)request.getAttribute("q")).orElse("");
  String categoryIdStr = String.valueOf(request.getAttribute("categoryId"));
  if ("null".equalsIgnoreCase(categoryIdStr)) categoryIdStr = "";
  boolean onlyInactive = Boolean.TRUE.equals(request.getAttribute("onlyInactive"));

  // ⚠️ NON usare "page" come nome variabile: è un oggetto implicito JSP
  int pageNum   = Optional.ofNullable((Integer)request.getAttribute("page")).orElse(1);
  int pageSize  = Optional.ofNullable((Integer)request.getAttribute("pageSize")).orElse(12);
  int total     = Optional.ofNullable((Integer)request.getAttribute("total")).orElse(0);
  int totalPages= Optional.ofNullable((Integer)request.getAttribute("totalPages")).orElse(1);
  String sort   = Optional.ofNullable((String)request.getAttribute("sort")).orElse("");
  String dir    = Optional.ofNullable((String)request.getAttribute("dir")).orElse("");

  // Flash
  String ok = request.getParameter("ok");
  String err = request.getParameter("err");

  // Lista
  Object obj = request.getAttribute("products");
  List<Product> products = new ArrayList<>();
  if (obj instanceof List<?>) {
    for (Object x : (List<?>) obj) if (x instanceof Product) products.add((Product) x);
  }

  // Builder query preserved
  String baseQuery = "q="+java.net.URLEncoder.encode(q, java.nio.charset.StandardCharsets.UTF_8)
                   + (categoryIdStr.isEmpty() ? "" : "&categoryId="+esc(categoryIdStr))
                   + (onlyInactive ? "&onlyInactive=1" : "")
                   + "&pageSize="+pageSize;
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Admin • Prodotti</title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <style>
    .page{padding:28px 18px 80px;background:linear-gradient(135deg,#001e36 0%,#000b2b 100%);color:#fff;min-height:60vh}
    .container{max-width:1100px;margin:0 auto}
    .toolbar{display:flex;gap:12px;flex-wrap:wrap;align-items:center;justify-content:space-between;margin-bottom:14px}
    .filters{display:flex;gap:10px;flex-wrap:wrap;align-items:center}
    input[type=text], select{
      background:#001E36;color:#fff;border:1px solid #0a3565;border-radius:10px;padding:8px 10px
    }
    .btn{background:#444;color:#fff;border:none;border-radius:10px;padding:9px 12px;font-weight:700;cursor:pointer;text-decoration:none}
    .btn.primary{background:#E30613}
    .btn.line{background:transparent;border:1px solid rgba(255,255,255,.35)}
    .table{width:100%;border-collapse:separate;border-spacing:0}
    .table th,.table td{padding:10px 10px;border-bottom:1px solid rgba(255,255,255,.12);vertical-align:middle}
    .pill{display:inline-block;padding:4px 8px;border-radius:999px;background:rgba(255,255,255,.12);font-size:.9rem}
    .pill.ok{background:#1e824c}
    .pill.warn{background:#b33939}
    .row-actions{display:flex;gap:6px;flex-wrap:wrap}
    .msg{padding:10px 12px;border-radius:10px;margin:10px 0}
    .msg.ok{background:#1e824c}
    .msg.err{background:#b33939}
    .pager{display:flex;gap:6px;align-items:center;flex-wrap:wrap;margin-top:12px}
    .pager a,.pager span{padding:6px 10px;border:1px solid rgba(255,255,255,.35);border-radius:8px;text-decoration:none}
    .pager .cur{background:#E30613;border-color:#E30613}
    .th a{color:#fff;text-decoration:none}
    .th .arrow{opacity:.7;font-size:.9em}
  </style>
</head>
<body>
<jsp:include page="/views/header.jsp" />

<div class="page">
  <div class="container">

    <div class="toolbar">
      <h2 style="margin:0">Prodotti</h2>
      <a class="btn primary" href="<%=ctx%>/admin/products/edit">+ Aggiungi prodotto</a>
    </div>

    <% if (ok != null) { %><div class="msg ok"><%= esc(ok) %></div><% } %>
    <% if (err != null) { %><div class="msg err"><%= esc(err) %></div><% } %>

    <!-- Filtri -->
    <form class="filters" method="get" action="<%=ctx%>/admin/products" style="margin-bottom:12px">
      <input type="text" name="q" placeholder="Cerca per nome…" value="<%=esc(q)%>">
      <select name="categoryId">
        <option value="">Tutte le categorie</option>
        <option value="1" <%= sel("1", categoryIdStr) %>>Merch</option>
        <option value="2" <%= sel("2", categoryIdStr) %>>Experience</option>
        <!-- adatta ai tuoi ID reali -->
      </select>
      <label style="display:inline-flex;gap:6px;align-items:center">
        <input type="checkbox" name="onlyInactive" value="1" <%= onlyInactive ? "checked" : "" %>>
        Solo non attivi
      </label>

      <select name="pageSize">
        <option value="12" <%= sel(12, pageSize) %>>12</option>
        <option value="24" <%= sel(24, pageSize) %>>24</option>
        <option value="50" <%= sel(50, pageSize) %>>50</option>
      </select>

      <input type="hidden" name="sort" value="<%= esc(sort) %>">
      <input type="hidden" name="dir" value="<%= esc(dir) %>">

      <button class="btn line" type="submit">Filtra</button>
      <a class="btn line" href="<%=ctx%>/admin/products">Reset</a>
    </form>

    <!-- Tabella -->
    <div class="card" style="background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.15);border-radius:16px;padding:10px">
      <table class="table">
        <thead>
          <tr>
            <th class="th" style="width:42%">
              <a href="<%=ctx%>/admin/products?<%=baseQuery%>&sort=name&dir=<%= esc("name".equals(sort)?toggledir(dir):"asc") %>">
                Nome <span class="arrow"><%= "name".equals(sort) ? ("asc".equalsIgnoreCase(dir)?"▲":"▼") : "" %></span>
              </a>
            </th>
            <th class="th" style="width:10%">
              <a href="<%=ctx%>/admin/products?<%=baseQuery%>&sort=ptype&dir=<%= esc("ptype".equals(sort)?toggledir(dir):"asc") %>">
                Tipo <span class="arrow"><%= "ptype".equals(sort) ? ("asc".equalsIgnoreCase(dir)?"▲":"▼") : "" %></span>
              </a>
            </th>
            <th class="th" style="width:10%">
              <a href="<%=ctx%>/admin/products?<%=baseQuery%>&sort=etype&dir=<%= esc("etype".equals(sort)?toggledir(dir):"asc") %>">
                Exp <span class="arrow"><%= "etype".equals(sort) ? ("asc".equalsIgnoreCase(dir)?"▲":"▼") : "" %></span>
              </a>
            </th>
            <th class="th" style="width:10%">
              <a href="<%=ctx%>/admin/products?<%=baseQuery%>&sort=price&dir=<%= esc("price".equals(sort)?toggledir(dir):"asc") %>">
                Prezzo <span class="arrow"><%= "price".equals(sort) ? ("asc".equalsIgnoreCase(dir)?"▲":"▼") : "" %></span>
              </a>
            </th>
            <th class="th" style="width:8%">
              <a href="<%=ctx%>/admin/products?<%=baseQuery%>&sort=stock&dir=<%= esc("stock".equals(sort)?toggledir(dir):"asc") %>">
                Stock <span class="arrow"><%= "stock".equals(sort) ? ("asc".equalsIgnoreCase(dir)?"▲":"▼") : "" %></span>
              </a>
            </th>
            <th class="th" style="width:8%">
              <a href="<%=ctx%>/admin/products?<%=baseQuery%>&sort=active&dir=<%= esc("active".equals(sort)?toggledir(dir):"asc") %>">
                Attivo <span class="arrow"><%= "active".equals(sort) ? ("asc".equalsIgnoreCase(dir)?"▲":"▼") : "" %></span>
              </a>
            </th>
            <th class="th" style="width:8%">
              <a href="<%=ctx%>/admin/products?<%=baseQuery%>&sort=featured&dir=<%= esc("featured".equals(sort)?toggledir(dir):"asc") %>">
                Feat <span class="arrow"><%= "featured".equals(sort) ? ("asc".equalsIgnoreCase(dir)?"▲":"▼") : "" %></span>
              </a>
            </th>
            <th style="width:28%">Azioni</th>
          </tr>
        </thead>
        <tbody>
        <% if (products.isEmpty()) { %>
          <tr><td colspan="8" style="opacity:.85">Nessun prodotto trovato.</td></tr>
        <% } %>
        <%
          for (Product p : products) {
            String pType = p.getProductType()==null ? "—" : p.getProductType().name();
            String eType = p.getExperienceType()==null ? "—" : p.getExperienceType().name();
        %>
          <tr>
            <td>
              <div style="font-weight:800"><a href="<%=ctx%>/admin/products/edit?id=<%=p.getProductId()%>" style="color:#fff;text-decoration:none"><%= esc(p.getName()) %></a></div>
              <div style="opacity:.85;font-size:.9rem"><%= esc(p.getShortDescription()==null ? "" : p.getShortDescription()) %></div>
            </td>
            <td><span class="pill"><%= esc(pType) %></span></td>
            <td><span class="pill"><%= esc(eType) %></span></td>
            <td>€ <%= p.getPrice() %></td>
            <td><%= p.getStockQuantity()==null ? "—" : p.getStockQuantity() %></td>
            <td><span class="pill <%= Boolean.TRUE.equals(p.getActive())?"ok":"warn" %>"><%= Boolean.TRUE.equals(p.getActive())?"SI":"NO" %></span></td>
            <td><span class="pill <%= Boolean.TRUE.equals(p.getFeatured())?"ok":"" %>"><%= Boolean.TRUE.equals(p.getFeatured())?"SI":"NO" %></span></td>
            <td>
              <div class="row-actions">

                <!-- Attiva/Disattiva -->
                <form method="post" action="<%=ctx%>/admin/products/action">
                  <input type="hidden" name="action" value="setActive">
                  <input type="hidden" name="id" value="<%= p.getProductId() %>">
                  <% if (csrf != null && !csrf.isEmpty()) { %><input type="hidden" name="csrf" value="<%= esc(csrf) %>"><% } %>
                  <!-- conserva filtri+pag -->
                  <input type="hidden" name="q" value="<%= esc(q) %>">
                  <input type="hidden" name="categoryId" value="<%= esc(categoryIdStr) %>">
                  <input type="hidden" name="onlyInactive" value="<%= onlyInactive ? "1" : "" %>">
                  <input type="hidden" name="page" value="<%= pageNum %>">
                  <input type="hidden" name="pageSize" value="<%= pageSize %>">
                  <input type="hidden" name="sort" value="<%= esc(sort) %>">
                  <input type="hidden" name="dir" value="<%= esc(dir) %>">
                  <input type="hidden" name="active" value="<%= Boolean.TRUE.equals(p.getActive()) ? "0" : "1" %>">
                  <button class="btn line" onclick="return confirm('<%= Boolean.TRUE.equals(p.getActive()) ? "Disattivare il prodotto?" : "Attivare il prodotto?" %>')">
                    <%= Boolean.TRUE.equals(p.getActive()) ? "Disattiva" : "Attiva" %>
                  </button>
                </form>

                <!-- Evidenzia/Non evidenzia -->
                <form method="post" action="<%=ctx%>/admin/products/action">
                  <input type="hidden" name="action" value="setFeatured">
                  <input type="hidden" name="id" value="<%= p.getProductId() %>">
                  <% if (csrf != null && !csrf.isEmpty()) { %><input type="hidden" name="csrf" value="<%= esc(csrf) %>"><% } %>
                  <input type="hidden" name="q" value="<%= esc(q) %>">
                  <input type="hidden" name="categoryId" value="<%= esc(categoryIdStr) %>">
                  <input type="hidden" name="onlyInactive" value="<%= onlyInactive ? "1" : "" %>">
                  <input type="hidden" name="page" value="<%= pageNum %>">
                  <input type="hidden" name="pageSize" value="<%= pageSize %>">
                  <input type="hidden" name="sort" value="<%= esc(sort) %>">
                  <input type="hidden" name="dir" value="<%= esc(dir) %>">
                  <input type="hidden" name="featured" value="<%= Boolean.TRUE.equals(p.getFeatured()) ? "0" : "1" %>">
                  <button class="btn line">
                    <%= Boolean.TRUE.equals(p.getFeatured()) ? "Rimuovi evidenza" : "Evidenzia" %>
                  </button>
                </form>

                <!-- Soft delete -->
                <form method="post" action="<%=ctx%>/admin/products/action" onsubmit="return confirm('Disattivare il prodotto (soft delete)?')">
                  <input type="hidden" name="action" value="delete">
                  <input type="hidden" name="id" value="<%= p.getProductId() %>">
                  <% if (csrf != null && !csrf.isEmpty()) { %><input type="hidden" name="csrf" value="<%= esc(csrf) %>"><% } %>
                  <input type="hidden" name="q" value="<%= esc(q) %>">
                  <input type="hidden" name="categoryId" value="<%= esc(categoryIdStr) %>">
                  <input type="hidden" name="onlyInactive" value="<%= onlyInactive ? "1" : "" %>">
                  <input type="hidden" name="page" value="<%= pageNum %>">
                  <input type="hidden" name="pageSize" value="<%= pageSize %>">
                  <input type="hidden" name="sort" value="<%= esc(sort) %>">
                  <input type="hidden" name="dir" value="<%= esc(dir) %>">
                  <button class="btn">Elimina</button>
                </form>

                <!-- Modifica -->
                <a class="btn line" href="<%=ctx%>/admin/products/edit?id=<%= p.getProductId() %>">Modifica</a>
              </div>
            </td>
          </tr>
        <% } %>
        </tbody>
      </table>

      <!-- Pager -->
      <div class="pager">
        <span>Totale: <strong><%= total %></strong> • Pagina <strong><%= pageNum %></strong>/<%= totalPages %></span>
        <% if (pageNum > 1) { %>
          <a href="<%=ctx%>/admin/products?<%=baseQuery%>&sort=<%=esc(sort)%>&dir=<%=esc(dir)%>&page=<%=pageNum-1%>">« Prec</a>
        <% } %>
        <%
          int win = 3;
          int start = Math.max(1, pageNum - win);
          int end = Math.min(totalPages, pageNum + win);
          for (int p = start; p <= end; p++) {
            if (p == pageNum) { %>
              <span class="cur"><%= p %></span>
            <% } else { %>
              <a href="<%=ctx%>/admin/products?<%=baseQuery%>&sort=<%=esc(sort)%>&dir=<%=esc(dir)%>&page=<%=p%>"><%= p %></a>
            <% }
          }
        %>
        <% if (pageNum < totalPages) { %>
          <a href="<%=ctx%>/admin/products?<%=baseQuery%>&sort=<%=esc(sort)%>&dir=<%=esc(dir)%>&page=<%=pageNum+1%>">Succ »</a>
        <% } %>
      </div>
    </div>

  </div>
</div>

<jsp:include page="/views/footer.jsp" />
</body>
</html>