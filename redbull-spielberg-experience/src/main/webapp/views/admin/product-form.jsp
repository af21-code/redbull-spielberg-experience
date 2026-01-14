<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ page import="java.util.*, model.Product, model.Category" %>
    <%! private static String esc(Object o) { if (o==null) return "" ; String s=String.valueOf(o); return
      s.replace("&", "&amp;" ).replace("<", "&lt;" ).replace(">", "&gt;")
      .replace("\"", "&quot;").replace("'", "&#39;");
      }
      %>
      <% String ctx=request.getContextPath(); Product p=(Product) request.getAttribute("product"); if (p==null) { p=new
        Product(); p.setActive(true); p.setFeatured(false); } Object catsObj=request.getAttribute("categories");
        List<Category> categories = new ArrayList<>();
          if (catsObj instanceof List
          <?>) {
        for (Object x : (List<?>) catsObj) if (x instanceof Category) categories.add((Category) x);
          }

          String err = (String) request.getAttribute("err");
          String csrf = (String) request.getAttribute("csrfToken");
          if (csrf == null || csrf.isBlank()) csrf = (String) session.getAttribute("csrfToken");

          boolean isEdit = (p.getProductId() != null);

          // comodi per i confronti
          String expName = (p.getExperienceType() == null ? "" : p.getExperienceType().name());
          String prodName = (p.getProductType() == null ? "" : p.getProductType().name());
          Integer curCatId = p.getCategoryId();
          %>
          <!DOCTYPE html>
          <html lang="it">

          <head>
            <meta charset="UTF-8">
            <title>
              <%= isEdit ? "Modifica prodotto" : "Nuovo prodotto" %>
            </title>
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
            <link rel="stylesheet" href="<%=ctx%>/styles/admin.css">
            <link rel="stylesheet" href="<%=ctx%>/styles/order-details.css">
          </head>

          <body>
            <jsp:include page="/views/header.jsp" />

            <div class="admin-bg">
              <div class="admin-shell">
                <aside class="admin-sidebar">
                  <a href="<%=ctx%>/admin">Dashboard</a>
                  <a href="<%=ctx%>/admin/products" class="active">Prodotti</a>
                  <a href="<%=ctx%>/admin/categories">Categorie</a>
                  <a href="<%=ctx%>/admin/orders">Ordini</a>
                  <a href="<%=ctx%>/admin/users">Utenti</a>
                  <a href="<%=ctx%>/admin/slots">Slot</a>
                </aside>

                <section class="admin-content">
                  <div class="admin-actions-bar">
                    <div>
                      <h2 class="admin-header-title">
                        <%= isEdit ? "Modifica Prodotto" : "Nuovo Prodotto" %>
                      </h2>
                      <div class="admin-subtitle">Modifica i dettagli del catalogo</div>
                    </div>
                    <a href="<%=ctx%>/admin/products" class="btn outline">← Torna alla lista</a>
                  </div>

                  <% if (err !=null) { %>
                    <div class="alert danger" style="margin-bottom: 20px;">
                      <%= esc(err) %>
                    </div>
                    <% } %>

                      <div class="card" style="padding: 32px; max-width: 900px;">
                        <form method="post" action="<%=ctx%>/admin/products/save" enctype="multipart/form-data">
                          <% if (csrf !=null && !csrf.isBlank()) { %>
                            <input type="hidden" name="csrf" value="<%= esc(csrf) %>">
                            <% } %>
                              <% if (isEdit) { %>
                                <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                                <% } %>
                                  <input type="hidden" name="imageUrl" value="<%= esc(p.getImageUrl()) %>">

                                  <!-- SEZIONE 1: Info Base -->
                                  <div
                                    style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px;">
                                    <div>
                                      <label style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Nome
                                        Prodotto *</label>
                                      <div class="input-group">
                                        <span class="input-icon">📦</span>
                                        <input type="text" name="name" required value="<%= esc(p.getName()) %>"
                                          placeholder="Es. Cappellino Team RedBull"
                                          style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px 10px 10px 40px;">
                                      </div>
                                    </div>
                                    <div>
                                      <label
                                        style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Categoria</label>
                                      <div class="input-group">
                                        <span class="input-icon">📂</span>
                                        <select name="categoryId"
                                          style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px 10px 10px 40px; appearance: none;">
                                          <option value="">— Seleziona Categoria —</option>
                                          <% for (Category c : categories) { Integer cid=c.getCategoryId(); String
                                            sel=(curCatId !=null && cid !=null && curCatId.equals(cid)) ? "selected"
                                            : "" ; %>
                                            <option value="<%= cid %>" <%=sel %>><%= esc(c.getName()) %>
                                            </option>
                                            <% } %>
                                        </select>
                                      </div>
                                    </div>
                                  </div>

                                  <!-- SEZIONE 2: Tipo & Prezzo -->
                                  <div
                                    style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px;">
                                    <div>
                                      <label style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Tipo
                                        Prodotto *</label>
                                      <select id="productType" name="productType" required
                                        style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px;">
                                        <option value="">— Seleziona —</option>
                                        <option value="MERCHANDISE" <%="MERCHANDISE" .equals(prodName) ? "selected" : ""
                                          %>>MERCHANDISE</option>
                                        <option value="EXPERIENCE" <%="EXPERIENCE" .equals(prodName) ? "selected" : ""
                                          %>>EXPERIENCE</option>
                                      </select>
                                    </div>
                                    <div>
                                      <label
                                        style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Prezzo
                                        (€) *</label>
                                      <div class="input-group">
                                        <span class="input-icon">💶</span>
                                        <input id="price" name="price" type="number" step="0.01" min="0" required
                                          value="<%= p.getPrice() == null ? "" : p.getPrice().toPlainString() %>"
                                          placeholder="0.00"
                                          style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px 10px 10px 40px;">
                                      </div>
                                    </div>
                                  </div>

                                  <!-- SEZIONE 3: Dinamica (Stock o Experience) -->
                                  <div
                                    style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px;">
                                    <div id="stockWrap">
                                      <label
                                        style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Stock
                                        (Qtà)</label>
                                      <input id="stockQuantity" name="stockQuantity" type="number" min="0"
                                        value="<%= p.getStockQuantity() == null ? "" : String.valueOf(p.getStockQuantity()) %>"
                                        placeholder="Solo per MERCHANDISE"
                                        style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px;">
                                    </div>
                                    <div>
                                      <label for="experienceType"
                                        style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Tipo
                                        Esperienza</label>
                                      <select id="experienceType" name="experienceType"
                                        style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px;">
                                        <option value="">— Nessuno / Opzionale —</option>
                                        <option value="F1" <%="F1" .equals(expName) ? "selected" : "" %>>F1</option>
                                        <option value="F2" <%="F2" .equals(expName) ? "selected" : "" %>>F2</option>
                                        <option value="NASCAR" <%="NASCAR" .equals(expName) ? "selected" : "" %>>NASCAR
                                        </option>
                                        <option value="STOCKCAR" <%="STOCKCAR" .equals(expName) ? "selected" : "" %>
                                          >STOCKCAR</option>
                                      </select>
                                    </div>
                                  </div>

                                  <!-- SEZIONE 4: Immagine e Descrizione -->
                                  <div style="margin-bottom: 24px;">
                                    <label
                                      style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Immagine
                                      Prodotto</label>

                                    <% if (p.getImageUrl() !=null && !p.getImageUrl().isEmpty()) { %>
                                      <div
                                        style="margin-bottom: 12px; padding: 10px; background: rgba(255,255,255,0.05); border-radius: 8px; display: inline-block;">
                                        <img src="<%= esc(p.getImageUrl()) %>" alt="Anteprima prodotto"
                                          style="max-height: 100px; max-width: 100%; border-radius: 4px; display: block;">
                                        <div style="font-size: 0.8rem; color: rgba(255,255,255,0.6); margin-top: 4px;">
                                          Immagine attuale</div>
                                      </div>
                                      <% } %>

                                        <input type="file" name="imageFile" accept=".jpg,.jpeg,.png,.webp"
                                          style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px;">
                                        <div style="font-size: 0.85rem; color: rgba(255,255,255,0.6); margin-top: 6px;">
                                          Carica una nuova immagine per sostituire quella attuale (JPG, PNG, WEBP).
                                        </div>
                                  </div>

                                  <div style="margin-bottom: 24px;">
                                    <label
                                      style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Descrizione
                                      Breve</label>
                                    <input name="shortDescription" type="text"
                                      value="<%= esc(p.getShortDescription()) %>"
                                      style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px;">
                                  </div>

                                  <div style="margin-bottom: 24px;">
                                    <label
                                      style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Descrizione
                                      Completa</label>
                                    <textarea name="description" rows="5"
                                      style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px; resize: vertical;"><%= esc(p.getDescription()) %></textarea>
                                  </div>

                                  <!-- SEZIONE 5: Checkbox & Footer -->
                                  <div
                                    style="background: rgba(255,255,255,0.05); padding: 20px; border-radius: 12px; display: flex; gap: 32px; align-items: center; margin-bottom: 32px;">
                                    <label
                                      style="display: flex; align-items: center; gap: 10px; cursor: pointer; font-weight: 600;">
                                      <input type="checkbox" name="featured" <%=Boolean.TRUE.equals(p.getFeatured())
                                        ? "checked" : "" %>
                                      style="width: 20px; height: 20px; accent-color: #0a84ff;">
                                      In Evidenza
                                    </label>

                                    <label
                                      style="display: flex; align-items: center; gap: 10px; cursor: pointer; font-weight: 600;">
                                      <input type="checkbox" name="active" <%=Boolean.TRUE.equals(p.getActive())
                                        ? "checked" : "" %>
                                      style="width: 20px; height: 20px; accent-color: #4cd964;">
                                      Attivo
                                    </label>
                                  </div>

                                  <div style="display: flex; gap: 16px;">
                                    <button class="btn"
                                      style="background: #0a84ff; padding: 12px 32px; font-size: 1rem;" type="submit">
                                      <%= isEdit ? "Salva Modifiche" : "Crea Prodotto" %>
                                    </button>
                                    <a href="<%=ctx%>/admin/products" class="btn outline"
                                      style="padding: 12px 24px;">Annulla</a>
                                  </div>
                        </form>
                      </div>
                </section>
              </div>
            </div>

            <script>
              (function () {
                var typeSel = document.getElementById('productType');
                var stockWrap = document.getElementById('stockWrap');

                function toggleStock() {
                  var v = (typeSel && typeSel.value) || '';
                  var merch = v === 'MERCHANDISE';
                  if (stockWrap) {
                    var inp = document.getElementById('stockQuantity');
                    if (merch) {
                      stockWrap.style.opacity = '1';
                      stockWrap.style.pointerEvents = 'auto';
                      if (inp) inp.required = false; // Stock might be optional or handled
                    } else {
                      stockWrap.style.opacity = '0.3';
                      stockWrap.style.pointerEvents = 'none';
                      if (inp) inp.value = '';
                    }
                  }
                }

                if (typeSel) {
                  typeSel.addEventListener('change', toggleStock);
                  toggleStock();
                }
              })();
            </script>

            <jsp:include page="/views/footer.jsp" />
          </body>

          </html>