<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.Product, model.Category" %>
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
  if (p == null) { p = new Product(); p.setActive(true); p.setFeatured(false); }

  // categorie per la select
  Object catsObj = request.getAttribute("categories");
  List<Category> categories = new ArrayList<>();
  if (catsObj instanceof List<?>) {
    for (Object x : (List<?>) catsObj) if (x instanceof Category) categories.add((Category) x);
  }

  String err = (String) request.getAttribute("err");
  String csrf = (String) request.getAttribute("csrfToken");
  if (csrf == null || csrf.isBlank()) csrf = (String) session.getAttribute("csrfToken");

  boolean isEdit = (p.getProductId() != null);

  // comodi per i confronti senza dipendere dalle costanti enum a compile-time
  String expName = (p.getExperienceType() == null ? "" : p.getExperienceType().name());
  String prodName = (p.getProductType() == null ? "" : p.getProductType().name());

  Integer curCatId = p.getCategoryId();
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title><%= isEdit ? "Modifica prodotto" : "Nuovo prodotto" %></title>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/admin.css">
  <style>
    .wrap{padding:30px 18px 80px;background:linear-gradient(135deg,#001e36 0%,#000b2b 100%);min-height:60vh;color:#fff}
    .container{max-width:900px;margin:0 auto}
    .card{background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.15);border-radius:16px;padding:18px}
    .row{display:grid;grid-template-columns:1fr 1fr;gap:12px}
    @media (max-width:900px){ .row{grid-template-columns:1fr} }
    label{font-weight:700;margin-bottom:6px;display:block}
    input,select,textarea{width:100%;background:#001E36;color:#fff;border:1px solid #0a3565;border-radius:10px;padding:10px 12px}
    .btn{background:#444;color:#fff;border:none;border-radius:10px;padding:10px 14px;font-weight:700;cursor:pointer;text-decoration:none}
    .btn.primary{background:#E30613}
    .muted{opacity:.85}
    .error{background:#b33939;border-color:#b33939;border-radius:10px;padding:10px 12px;margin:0 0 12px}
    .grid2{display:grid;grid-template-columns:1fr 1fr;gap:12px}
  </style>
</head>
<body>
<jsp:include page="/views/header.jsp" />

<div class="wrap">
  <div class="container">
    <div class="card" style="margin-bottom:12px">
      <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap">
        <h2 style="margin:0"><%= isEdit ? "Modifica prodotto" : "Nuovo prodotto" %></h2>
        <div style="display:flex;gap:8px;flex-wrap:wrap">
          <a href="<%=ctx%>/admin/products" class="btn">← Prodotti</a>
          <a href="<%=ctx%>/admin/categories" class="btn">Categorie</a>
        </div>
      </div>
      <% if (err != null) { %>
        <p class="error"><%= esc(err) %></p>
      <% } %>
    </div>

    <div class="card">
      <form method="post" action="<%=ctx%>/admin/products/save" enctype="multipart/form-data">
        <% if (csrf != null && !csrf.isBlank()) { %>
          <input type="hidden" name="csrf" value="<%= esc(csrf) %>">
        <% } %>
        <% if (isEdit) { %>
          <input type="hidden" name="productId" value="<%= p.getProductId() %>">
        <% } %>

        <div class="row">
          <div>
            <label for="name">Nome *</label>
            <input id="name" name="name" type="text" required value="<%= esc(p.getName()) %>">
          </div>
          <div>
            <label for="categoryId">Categoria</label>
            <select id="categoryId" name="categoryId">
              <option value="">— Nessuna —</option>
              <% for (Category c : categories) {
                   Integer cid = c.getCategoryId();
                   String sel = (curCatId != null && cid != null && curCatId.equals(cid)) ? "selected" : "";
              %>
                <option value="<%= cid %>" <%= sel %>><%= esc(c.getName()) %></option>
              <% } %>
            </select>
            <div class="muted" style="margin-top:6px;font-size:.9rem">Gestisci le categorie dalla pagina “Categorie”.</div>
          </div>
        </div>

        <div class="row">
          <div>
            <label for="productType">Tipo prodotto *</label>
            <select id="productType" name="productType" required>
              <option value="">— Seleziona —</option>
              <option value="MERCHANDISE" <%= "MERCHANDISE".equals(prodName) ? "selected" : "" %>>MERCHANDISE</option>
              <option value="EXPERIENCE"  <%= "EXPERIENCE".equals(prodName)  ? "selected" : "" %>>EXPERIENCE</option>
            </select>
          </div>
          <div>
            <label for="experienceType">Experience type (opzionale)</label>
            <select id="experienceType" name="experienceType">
              <option value="">— nessuno —</option>
              <option value="F1"       <%= "F1".equals(expName)       ? "selected" : "" %>>F1</option>
              <option value="F2"       <%= "F2".equals(expName)       ? "selected" : "" %>>F2</option>
              <option value="NASCAR"   <%= "NASCAR".equals(expName)   ? "selected" : "" %>>NASCAR</option>
              <option value="STOCKCAR" <%= "STOCKCAR".equals(expName) ? "selected" : "" %>>STOCKCAR</option>
            </select>
          </div>
        </div>

        <div class="row">
          <div>
            <label for="price">Prezzo *</label>
            <input id="price" name="price" type="number" step="0.01" min="0" required
                   value="<%= p.getPrice()==null ? "" : p.getPrice().toPlainString() %>">
          </div>
          <div id="stockWrap">
            <label for="stockQuantity">Stock (solo MERCHANDISE)</label>
            <input id="stockQuantity" name="stockQuantity" type="number" min="0"
                   value="<%= p.getStockQuantity()==null ? "" : String.valueOf(p.getStockQuantity()) %>">
          </div>
        </div>

        <div class="row">
          <div>
            <label for="shortDescription">Descrizione breve</label>
            <input id="shortDescription" name="shortDescription" type="text"
                   value="<%= esc(p.getShortDescription()) %>">
          </div>
          <div>
            <label for="imageUrl">Immagine (URL)</label>
            <input id="imageUrl" name="imageUrl" type="text" value="<%= esc(p.getImageUrl()) %>">
            <div class="muted" style="margin-top:6px;font-size:.9rem">
              In alternativa puoi caricare un file sotto (se presente, ha priorità).
            </div>
            <input type="file" name="imageFile" accept=".jpg,.jpeg,.png,.webp" style="margin-top:8px">
          </div>
        </div>

        <div class="row">
          <div class="grid2" style="align-items:center">
            <div>
              <label for="featured" style="display:inline">In evidenza</label>
              <input id="featured" name="featured" type="checkbox" <%= Boolean.TRUE.equals(p.getFeatured())?"checked":"" %>>
            </div>
            <div>
              <label for="active" style="display:inline">Attivo</label>
              <input id="active" name="active" type="checkbox" <%= Boolean.TRUE.equals(p.getActive())?"checked":"" %>>
            </div>
          </div>
          <div>
            <label for="description">Descrizione</label>
            <textarea id="description" name="description" rows="6"><%= esc(p.getDescription()) %></textarea>
          </div>
        </div>

        <div style="display:flex;gap:10px;flex-wrap:wrap;margin-top:14px">
          <button class="btn primary" type="submit"><%= isEdit ? "Salva modifiche" : "Crea prodotto" %></button>
          <a class="btn" href="<%=ctx%>/admin/products">Annulla</a>
        </div>
      </form>
    </div>
  </div>
</div>

<script>
  (function(){
    var typeSel = document.getElementById('productType');
    var stockWrap = document.getElementById('stockWrap');
    function toggleStock(){
      var v = (typeSel && typeSel.value) || '';
      var merch = v === 'MERCHANDISE';
      if (stockWrap){
        stockWrap.style.display = merch ? '' : 'none';
        var inp = document.getElementById('stockQuantity');
        if (inp) { if (!merch) inp.value = ''; }
      }
    }
    if (typeSel){
      typeSel.addEventListener('change', toggleStock);
      toggleStock();
    }
  })();
</script>

<jsp:include page="/views/footer.jsp" />
</body>
</html>