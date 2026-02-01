<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ page import="java.util.*, model.Product, model.Category" %>
    <%! @SuppressWarnings("unused") private static String esc(Object o) { if (o==null) return "" ; String
      s=String.valueOf(o); return s.replace("&", "&amp;" ).replace("<", "&lt;" ).replace(">", "&gt;")
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

          boolean hasVariants = (p.getVariants() != null && !p.getVariants().isEmpty());
          boolean isMerchServer = "MERCHANDISE".equals(prodName);
          int variantsSum = 0;
          if (hasVariants) {
          for (model.ProductVariant v : p.getVariants()) {
          if (v.getStockQuantity() != null) variantsSum += Math.max(0, v.getStockQuantity());
          }
          }

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
            <style>
              .variants-table {
                display: flex;
                flex-direction: column;
                gap: 8px;
              }

              .variants-head,
              .variant-row {
                display: grid;
                grid-template-columns: 1.3fr 1fr 0.9fr 0.8fr 0.5fr;
                gap: 8px;
                align-items: center;
              }

              .variants-head {
                color: #aaa;
                font-size: 0.9rem;
              }

              .variant-row input {
                width: 100%;
                border: 1px solid rgba(255, 255, 255, 0.15);
                border-radius: 8px;
                background: rgba(0, 0, 0, 0.2);
                color: #fff;
                padding: 8px;
              }

              .variant-row .toggle {
                display: flex;
                align-items: center;
                gap: 6px;
                color: #fff;
              }

              @media (max-width: 900px) {

                .variants-head,
                .variant-row {
                  grid-template-columns: repeat(2, minmax(0, 1fr));
                  grid-auto-rows: auto;
                }

                .variants-head span:nth-child(n+3) {
                  display: none;
                }

                .variant-row input {
                  padding: 10px;
                }

                .variant-row .toggle {
                  justify-content: flex-start;
                }

                .variant-row button {
                  width: 100%;
                }
              }

              @media (max-width: 600px) {

                .variants-head,
                .variant-row {
                  grid-template-columns: 1fr;
                }

                .variants-table {
                  gap: 12px;
                }

                .variant-row {
                  row-gap: 10px;
                }
              }
            </style>
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
                  <div class="container-900">
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
                                        <label
                                          style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Nome
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
                                        <label
                                          style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Tipo
                                          Prodotto *</label>
                                        <select id="productType" name="productType" required
                                          style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px;">
                                          <option value="">— Seleziona —</option>
                                          <option value="MERCHANDISE" <%="MERCHANDISE" .equals(prodName) ? "selected"
                                            : "" %>>MERCHANDISE</option>
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
                                          value="<%= (hasVariants || isMerchServer) ? String.valueOf(variantsSum) : (p.getStockQuantity() == null ? "" : String.valueOf(p.getStockQuantity())) %>"
                                          placeholder="Solo per MERCHANDISE" <%=(hasVariants || isMerchServer)
                                          ? "readonly" : "" %>
                                        style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius:
                                        8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px;">
                                        <div id="stockDerivedNote"
                                          style="font-size: 0.85rem; color: rgba(255,255,255,0.6); margin-top: 6px; <%= (hasVariants || isMerchServer) ? "" : "display:none;" %>">
                                          Stock generale derivato dalle varianti.
                                        </div>
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
                                          <option value="NASCAR" <%="NASCAR" .equals(expName) ? "selected" : "" %>
                                            >NASCAR
                                          </option>
                                          <option value="STOCKCAR" <%="STOCKCAR" .equals(expName) ? "selected" : "" %>
                                            >STOCKCAR</option>
                                        </select>
                                      </div>
                                    </div>

                                    <!-- SEZIONE 3b: Varianti / Taglie (solo MERCHANDISE) -->
                                    <div id="variantsWrap" class="card"
                                      style="padding:16px; margin-bottom:24px; display:none;">
                                      <div
                                        style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                                        <div>
                                          <h4 style="margin:0; color:#fff;">Taglie / Varianti</h4>
                                          <div class="admin-subtitle">Gestisci stock e prezzo opzionale per taglia</div>
                                        </div>
                                        <button type="button" class="btn sm" onclick="addVariantRow()">+ Aggiungi
                                          taglia</button>
                                      </div>
                                      <div class="variants-table">
                                        <div class="variants-head">
                                          <span>Taglia*</span><span>SKU</span><span>Stock</span><span>Attivo</span><span></span>
                                        </div>
                                        <div id="variantRows">
                                          <% if (p.getVariants()!=null && !p.getVariants().isEmpty()) { for
                                            (model.ProductVariant v : p.getVariants()) { %>
                                            <div class="variant-row">
                                              <input name="variantSize" placeholder="Es. S"
                                                value="<%= esc(v.getSize()) %>" required>
                                              <input name="variantSku" placeholder="SKU" value="<%= esc(v.getSku()) %>">
                                              <input name="variantStock" type="number" min="0" placeholder="Stock"
                                                value="<%= v.getStockQuantity()==null?"":v.getStockQuantity() %>">
                                              <label class="toggle">
                                                <input type="checkbox" name="variantActive"
                                                  <%=Boolean.TRUE.equals(v.getActive())?"checked":"" %>>
                                              </label>
                                              <button type="button" class="btn sm secondary"
                                                onclick="this.parentElement.remove()">X</button>
                                            </div>
                                            <% } } else { %>
                                              <div class="variant-row">
                                                <input name="variantSize" placeholder="Es. S" required>
                                                <input name="variantSku" placeholder="SKU">
                                                <input name="variantStock" type="number" min="0" placeholder="Stock">
                                                <label class="toggle">
                                                  <input type="checkbox" name="variantActive" checked>
                                                  <span>Attivo</span>
                                                </label>
                                                <button type="button" class="btn sm secondary"
                                                  onclick="this.parentElement.remove()">X</button>
                                              </div>
                                              <% } %>
                                        </div>
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
                                          <div
                                            style="font-size: 0.8rem; color: rgba(255,255,255,0.6); margin-top: 4px;">
                                            Immagine attuale</div>
                                        </div>
                                        <% } %>

                                          <input type="file" name="imageFile" accept=".jpg,.jpeg,.png,.webp"
                                            style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px;">
                                          <div
                                            style="font-size: 0.85rem; color: rgba(255,255,255,0.6); margin-top: 6px;">
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
                                      <button class="btn primary" type="submit">
                                        <%= isEdit ? "Salva Modifiche" : "Crea Prodotto" %>
                                      </button>
                                      <a href="<%=ctx%>/admin/products" class="btn outline">Annulla</a>
                                    </div>
                          </form>
                        </div>
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

            <script>
              const productTypeSelect = document.getElementById('productType');
              const stockWrap = document.getElementById('stockWrap');
              const expType = document.getElementById('experienceType');
              const variantsWrap = document.getElementById('variantsWrap');

              function setVariantsRequired(on) {
                const sizes = document.querySelectorAll('#variantRows input[name="variantSize"]');
                sizes.forEach(inp => on ? inp.setAttribute('required', 'required') : inp.removeAttribute('required'));
              }

              function toggleSections() {
                const isMerch = productTypeSelect.value === 'MERCHANDISE';
                if (stockWrap) stockWrap.style.display = isMerch ? 'block' : 'none';
                if (variantsWrap) variantsWrap.style.display = isMerch ? 'block' : 'none';
                if (!isMerch) {
                  if (expType) expType.removeAttribute('disabled');
                  setVariantsRequired(false); // evita required su campi nascosti
                } else {
                  if (expType) expType.setAttribute('disabled', 'disabled');
                  setVariantsRequired(true);
                }
                toggleDerivedStock();
              }
              productTypeSelect.addEventListener('change', toggleSections);
              toggleSections();

              function hasAnyVariant() {
                const sizes = document.querySelectorAll('#variantRows input[name="variantSize"]');
                return Array.from(sizes).some(inp => (inp.value || '').trim().length > 0);
              }

              function toggleDerivedStock() {
                const isMerch = productTypeSelect.value === 'MERCHANDISE';
                const stockInput = document.getElementById('stockQuantity');
                const note = document.getElementById('stockDerivedNote');
                const derived = isMerch;
                if (stockInput) {
                  stockInput.readOnly = derived;
                  if (derived) {
                    stockInput.value = sumVariantStock();
                  }
                }
                if (note) {
                  note.style.display = derived ? 'block' : 'none';
                }
              }

              function sumVariantStock() {
                const stocks = document.querySelectorAll('#variantRows input[name="variantStock"]');
                let sum = 0;
                stocks.forEach(inp => {
                  const v = parseInt((inp.value || '0').trim(), 10);
                  if (!isNaN(v) && v > 0) sum += v;
                });
                return sum;
              }

              function addVariantRow() {
                const isMerch = productTypeSelect.value === 'MERCHANDISE';
                const row = document.createElement('div');
                row.className = 'variant-row';
                row.innerHTML = `
                   <input name="variantSize" placeholder="Es. S" ${isMerch ? 'required' : ''}>
                   <input name="variantSku" placeholder="SKU">
                   <input name="variantStock" type="number" min="0" placeholder="Stock">
                   <label class="toggle">
                     <input type="checkbox" name="variantActive" checked>
                     <span>Attivo</span>
                   </label>
                   <button type="button" class="btn sm secondary" onclick="this.parentElement.remove(); toggleDerivedStock();">X</button>
                 `;
                document.getElementById('variantRows').appendChild(row);
                const sizeInput = row.querySelector('input[name="variantSize"]');
                if (sizeInput) {
                  sizeInput.addEventListener('input', toggleDerivedStock);
                }
                toggleDerivedStock();
              }

              document.addEventListener('input', function (e) {
                if (e.target && (e.target.name === 'variantSize' || e.target.name === 'variantStock')) {
                  toggleDerivedStock();
                }
              });
            </script>

            <jsp:include page="/views/footer.jsp" />
          </body>

          </html>