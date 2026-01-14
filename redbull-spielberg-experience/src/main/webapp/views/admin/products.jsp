<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ page import="java.util.*, model.Product, model.Category" %>

    <%! private static String esc(Object o) { if (o==null) return "" ; String s=String.valueOf(o); return
      s.replace("&", "&amp;" ).replace("<", "&lt;" ).replace(">", "&gt;")
      .replace("\"", "&quot;").replace("'", "&#39;");
      }

      private static String toggledir(String curDir) {
      return ("asc".equalsIgnoreCase(curDir)) ? "desc" : "asc";
      }

      private static String sel(Object a, Object b) {
      return Objects.equals(a, b) ? "selected" : "";
      }
      %>

      <% String ctx=request.getContextPath(); /* CSRF */ String csrf=(String) request.getAttribute("csrfToken"); if
        (csrf==null || csrf.isBlank()) csrf=(String) session.getAttribute("csrfToken"); /* Filtri GET */ String
        q=Optional.ofNullable((String) request.getAttribute("q")).orElse(""); String
        categoryIdStr=String.valueOf(request.getAttribute("categoryId")); if ("null".equalsIgnoreCase(categoryIdStr))
        categoryIdStr="" ; boolean onlyInactive=Boolean.TRUE.equals(request.getAttribute("onlyInactive")); int
        pageNum=Optional.ofNullable((Integer) request.getAttribute("page")).orElse(1); int
        pageSize=Optional.ofNullable((Integer) request.getAttribute("pageSize")).orElse(12); int
        total=Optional.ofNullable((Integer) request.getAttribute("total")).orElse(0); int
        totalPages=Optional.ofNullable((Integer) request.getAttribute("totalPages")).orElse(1); String
        sort=Optional.ofNullable((String) request.getAttribute("sort")).orElse(""); String
        dir=Optional.ofNullable((String) request.getAttribute("dir")).orElse(""); /* Flash */ String
        ok=request.getParameter("ok"); String err=request.getParameter("err"); /* Prodotti */ Object
        obj=request.getAttribute("products"); List<Product> products = new ArrayList<>();
          if (obj instanceof List
          <?>) {
        for (Object x : (List<?>) obj) if (x instanceof Product) products.add((Product) x);
          }

          /* Categorie */
          Object cobj = request.getAttribute("allCategories");
          List<Category> cats = new ArrayList<>();
              if (cobj instanceof List
              <?>) {
        for (Object x : (List<?>) cobj) if (x instanceof Category) cats.add((Category) x);
              }

              String baseQuery = "q=" + java.net.URLEncoder.encode(q, java.nio.charset.StandardCharsets.UTF_8)
              + (categoryIdStr.isEmpty() ? "" : "&categoryId=" + esc(categoryIdStr))
              + (onlyInactive ? "&onlyInactive=1" : "")
              + "&pageSize=" + pageSize;
              %>
              <!DOCTYPE html>
              <html lang="it">

              <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1" />
                <title>Admin • Prodotti</title>
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
                          <h2 class="admin-header-title">Prodotti</h2>
                          <div class="admin-subtitle">Gestione catalogo • <strong>
                              <%= total %>
                            </strong> prodotti
                          </div>
                        </div>
                        <a class="btn" href="<%=ctx%>/admin/products/edit">+ Aggiungi</a>
                      </div>

                      <!-- Toast Container -->
                      <div id="toast-container"></div>

                      <!-- Compact Toolbar -->
                      <form class="admin-toolbar" method="get" action="<%=ctx%>/admin/products">
                        <div class="search-box">
                          <input type="text" name="q" placeholder="Cerca prodotto..." value="<%=esc(q)%>">
                        </div>

                        <select name="categoryId">
                          <option value="">Tutte le categorie</option>
                          <% if (!cats.isEmpty()) { for (Category c : cats) { %>
                            <option value="<%= c.getCategoryId() %>" <%=sel(String.valueOf(c.getCategoryId()),
                              categoryIdStr) %>><%= esc(c.getName()) %>
                            </option>
                            <% } } %>
                        </select>

                        <label class="toggle-check">
                          <input type="checkbox" name="onlyInactive" value="1" <%=onlyInactive ? "checked" : "" %>>
                          <span>Solo inattivi</span>
                        </label>

                        <input type="hidden" name="sort" value="<%= esc(sort) %>">
                        <input type="hidden" name="dir" value="<%= esc(dir) %>">
                        <input type="hidden" name="pageSize" value="<%= pageSize %>">

                        <div class="toolbar-actions">
                          <button class="btn-filter" type="submit">Filtra</button>
                          <a class="btn-reset" href="<%=ctx%>/admin/products">🔄 Reset</a>
                        </div>
                      </form>

                      <!-- Table with Fixed Height Scroll -->
                      <div class="table-scroll-panel">
                        <div class="table-scroll-body">
                          <table class="modern-table">
                            <thead>
                              <tr>
                                <th style="width:40%">
                                  <a href="<%=ctx%>/admin/products?<%=baseQuery%>&sort=name&dir=<%= esc("name".equals(sort)?toggledir(dir):"asc") %>"
                                    style="color: inherit; text-decoration: none; display: flex; align-items: center;
                                    gap:
                                    4px;">
                                    Nome <%= "name" .equals(sort) ? ("asc".equalsIgnoreCase(dir) ? "▲" : "▼" ) : "" %>
                                  </a>
                                </th>
                                <th width="10%">Tipo</th>
                                <th width="10%">Exp</th>
                                <th width="10%">Prezzo</th>
                                <th width="10%">Stock</th>
                                <th width="10%">Stato</th>
                                <th width="10%" class="right">Azioni</th>
                              </tr>
                            </thead>
                            <tbody>
                              <% if (products.isEmpty()) { %>
                                <tr>
                                  <td colspan="7" class="center muted empty-state">
                                    <div class="empty-icon">📦</div>
                                    Nessun prodotto trovato.
                                  </td>
                                </tr>
                                <% } %>
                                  <% for (Product p : products) { String pType=p.getProductType()==null ? "—" :
                                    p.getProductType().name(); String eType=p.getExperienceType()==null ? "—" :
                                    p.getExperienceType().name(); boolean isActive=Boolean.TRUE.equals(p.getActive());
                                    %>
                                    <tr>
                                      <td data-label="Nome">
                                        <div style="font-weight:600; font-size: 1rem; color: #fff; margin-bottom: 2px;">
                                          <a href="<%=ctx%>/admin/products/edit?id=<%=p.getProductId()%>"
                                            style="color:inherit; text-decoration:none;">
                                            <%= esc(p.getName()) %>
                                          </a>
                                        </div>
                                        <% if (p.getShortDescription() !=null && !p.getShortDescription().isEmpty()) {
                                          %>
                                          <div class="muted" style="font-size: 0.85rem; line-height: 1.3;">
                                            <%= esc(p.getShortDescription()) %>
                                          </div>
                                          <% } %>
                                      </td>
                                      <td data-label="Tipo"><span class="chip">
                                          <%= esc(pType) %>
                                        </span></td>
                                      <td data-label="Exp"><span class="chip">
                                          <%= esc(eType) %>
                                        </span></td>
                                      <td data-label="Prezzo" class="price-cell">€ <%= p.getPrice() %>
                                      </td>
                                      <td data-label="Stock" style="font-weight: 500;">
                                        <%= p.getStockQuantity()==null ? "—" : p.getStockQuantity() %>
                                      </td>
                                      <td data-label="Stato">
                                        <span class="chip <%= isActive ? " success" : "warn" %>">
                                          <%= isActive ? "Attivo" : "Inattivo" %>
                                        </span>
                                      </td>
                                      <td data-label="Azioni" class="right">
                                        <div style="display: flex; gap: 8px; justify-content: flex-end;">
                                          <form method="post" action="<%=ctx%>/admin/products/action" data-toggle-form>
                                            <input type="hidden" name="action" value="setActive">
                                            <input type="hidden" name="id" value="<%= p.getProductId() %>">
                                            <% if (csrf !=null && !csrf.isEmpty()) { %>
                                              <input type="hidden" name="csrf" value="<%= esc(csrf) %>">
                                              <% } %>
                                                <input type="hidden" name="active" value="<%= isActive ? " 0" : "1" %>">
                                                <button type="button" class="btn sm outline"
                                                  onclick="confirmToggle(this, '<%= esc(p.getName()) %>', <%= !isActive %>)">
                                                  <%= isActive ? "Off" : "On" %>
                                                </button>
                                          </form>
                                          <a class="btn sm outline"
                                            href="<%=ctx%>/admin/products/edit?id=<%= p.getProductId() %>">✏️</a>
                                        </div>
                                      </td>
                                    </tr>
                                    <% } %>
                            </tbody>
                          </table>
                        </div>
                        <!-- Close table-scroll-body -->

                        <!-- Footer Paginazione -->
                        <div class="pagination-footer">
                          <div class="page-info">
                            Pagina <strong>
                              <%= pageNum %>
                            </strong> di <%= totalPages %>
                          </div>

                          <div class="page-size-selector">
                            <span>Righe per pagina:</span>
                            <select onchange="updatePageSize(this.value)">
                              <option value="12" <%=sel(12, pageSize) %>>12</option>
                              <option value="24" <%=sel(24, pageSize) %>>24</option>
                              <option value="50" <%=sel(50, pageSize) %>>50</option>
                            </select>
                          </div>

                          <div class="modern-pagination">
                            <% if (pageNum> 1) { %>
                              <a href="<%=ctx%>/admin/products?<%=baseQuery%>&sort=<%=esc(sort)%>&dir=<%=esc(dir)%>&page=<%=pageNum-1%>"
                                title="Precedente">←</a>
                              <% } %>

                                <% int startP=Math.max(1, pageNum - 2); int endP=Math.min(totalPages, pageNum + 2); for
                                  (int i=startP; i <=endP; i++) { %>
                                  <a href="<%=ctx%>/admin/products?<%=baseQuery%>&sort=<%=esc(sort)%>&dir=<%=esc(dir)%>&page=<%=i%>"
                                    class="<%= i == pageNum ? " active" : "" %>"><%= i %>
                                  </a>
                                  <% } %>

                                    <% if (pageNum < totalPages) { %>
                                      <a href="<%=ctx%>/admin/products?<%=baseQuery%>&sort=<%=esc(sort)%>&dir=<%=esc(dir)%>&page=<%=pageNum+1%>"
                                        title="Successiva">→</a>
                                      <% } %>
                          </div>
                        </div>
                      </div>
                      <!-- Close table-scroll-panel -->
                    </section>
                  </div>
                </div>

                <!-- Custom Confirmation Modal -->
                <div id="confirmModal" class="modal-overlay">
                  <div class="modal-box">
                    <div class="modal-title">Conferma Azione</div>
                    <div class="modal-desc" id="modalDesc">Procedere?</div>
                    <div class="modal-actions">
                      <button class="btn-modal-cancel" onclick="closeModal()">Annulla</button>
                      <button class="btn-modal-confirm" onclick="confirmAction()">Conferma</button>
                    </div>
                  </div>
                </div>

                <script>
                  // --- Toast Logic ---
                  function showToast(msg, type = 'info') {
                    const container = document.getElementById('toast-container');
                    const toast = document.createElement('div');
                    toast.className = 'toast ' + type;

                    let icon = 'ℹ️';
                    if (type === 'success') icon = '✅';
                    if (type === 'error') icon = '⚠️';

                    toast.innerHTML = '<span class="toast-icon">' + icon + '</span><span class="toast-msg">' + msg + '</span>';
                    container.appendChild(toast);

                    setTimeout(() => {
                      toast.style.animation = 'toastFadeOut 0.3s forwards';
                      setTimeout(() => toast.remove(), 300);
                    }, 4000);
                  }

                  document.addEventListener("DOMContentLoaded", () => {
                    const urlParams = new URLSearchParams(window.location.search);
                    const ok = urlParams.get('ok');
                    const err = urlParams.get('err');

                    if (ok) {
                      showToast(ok, 'success');
                      window.history.replaceState({}, document.title, window.location.pathname + window.location.search.replace(/[\?&]ok=[^&]+/, '').replace(/[\?&]err=[^&]+/, ''));
                    }
                    if (err) {
                      showToast(err, 'error');
                      window.history.replaceState({}, document.title, window.location.pathname + window.location.search.replace(/[\?&]ok=[^&]+/, '').replace(/[\?&]err=[^&]+/, ''));
                    }
                  });

                  function updatePageSize(size) {
                    const url = new URL(window.location);
                    url.searchParams.set('pageSize', size);
                    url.searchParams.set('page', '1');
                    window.location.href = url.toString();
                  }

                  // --- Modal Logic ---
                  let pendingForm = null;

                  function confirmToggle(btn, productName, targetActive) {
                    pendingForm = btn.form;
                    const action = targetActive ? "attivare" : "disattivare";

                    // Update modal text
                    document.getElementById('modalDesc').textContent = 'Sei sicuro di voler ' + action + ' il prodotto: ' + productName + '?';

                    // Show modal
                    document.getElementById('confirmModal').classList.add('active');
                  }

                  function closeModal() {
                    document.getElementById('confirmModal').classList.remove('active');
                    pendingForm = null;
                  }

                  function confirmAction() {
                    if (pendingForm) {
                      pendingForm.submit();
                    }
                  }
                </script>

                <jsp:include page="/views/footer.jsp" />
              </body>

              </html>