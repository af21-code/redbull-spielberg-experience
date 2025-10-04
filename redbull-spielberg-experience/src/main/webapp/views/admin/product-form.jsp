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
  if (p == null) { p = new Product(); p.setActive(true); p.setFeatured(false); }

  String err = (String) request.getAttribute("err");
  String csrf = (String) request.getAttribute("csrfToken");
  if (csrf == null || csrf.isBlank()) csrf = (String) session.getAttribute("csrfToken");

  boolean isEdit = (p.getProductId() != null);

  String expName = (p.getExperienceType() == null ? "" : p.getExperienceType().name());
  String prodName = (p.getProductType() == null ? "" : p.getProductType().name());
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
    .hint{font-size:.9rem;opacity:.85;margin-top:6px}
    .thumb{border-radius:10px;border:1px solid rgba(255,255,255,.2);max-height:120px}
  </style>
</head>
<body>
<jsp:include page="/views/header.jsp" />

<div class="wrap">
  <div class="container">
    <div class="card" style="margin-bottom:12px">
      <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap">
        <h2 style="margin:0"><%= isEdit ? "Modifica prodotto" : "Nuovo prodotto" %></h2>
        <a href="<%=ctx%>/admin/products" class="btn">← Torna ai prodotti</a>
      </div>
      <% if (err != null) { %>
        <p class="error"><%= esc(err) %></p>
      <% } %>
    </div>

    <div class="card">
      <!-- enctype multipart per upload -->
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
            <label for="categoryId">Categoria (ID)</label>
            <input id="categoryId" name="categoryId" type="number" min="1"
                   value="<%= p.getCategoryId()==null ? "" : String.valueOf(p.getCategoryId()) %>">
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
            <label for="imageUrl">Immagine (URL) oppure carica un file</label>
            <input id="imageUrl" name="imageUrl" type="text" placeholder="https://…"
                   value="<%= esc(p.getImageUrl()) %>">
            <div class="hint">Se carichi un file, verrà usato al posto dell’URL.</div>
            <div style="margin-top:8px">
              <input type="file" name="imageFile" accept="image/jpeg,image/png,image/webp" />
            </div>
            <% if (p.getImageUrl()!=null && !p.getImageUrl().isBlank()) { %>
              <div class="hint" style="margin-top:8px">
                <img src="<%= esc(p.getImageUrl()) %>" alt="preview" class="thumb">
              </div>
            <% } %>
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
      var merch = (typeSel && typeSel.value) === 'MERCHANDISE';
      if (stockWrap){
        stockWrap.style.display = merch ? '' : 'none';
        var inp = document.getElementById('stockQuantity');
        if (inp && !merch) inp.value = '';
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