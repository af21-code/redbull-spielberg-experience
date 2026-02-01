<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ page import="java.util.*, model.User" %>

    <%! private static String esc(Object o) { if (o==null) return "" ; String s=String.valueOf(o); return
      s.replace("&", "&amp;" ).replace("<", "&lt;" ).replace(">", "&gt;")
      .replace("\"", "&quot;").replace("'", "&#39;");
      }
      %>

      <% String ctx=request.getContextPath(); @SuppressWarnings("unchecked") List<User> list = (List<User>)
          request.getAttribute("users");
          String q = request.getParameter("q") == null ? "" : request.getParameter("q");
          String type = request.getParameter("type") == null ? "" : request.getParameter("type");
          boolean onlyInactive = "1".equals(request.getParameter("onlyInactive"));

          String okMsg = request.getParameter("ok");
          String errMsg = request.getParameter("err");
          %>
          <!DOCTYPE html>
          <html lang="it">

          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <title>Admin · Utenti</title>
            <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
            <link rel="stylesheet" href="<%=ctx%>/styles/admin.css">
            <link rel="stylesheet" href="<%=ctx%>/styles/order-details.css">
          </head>

          <body>
            <jsp:include page="../header.jsp" />

            <div class="admin-bg">
              <div class="admin-shell">
                <!-- Sidebar -->
                <aside class="admin-sidebar">
                  <a href="<%=ctx%>/admin">Dashboard</a>
                  <a href="<%=ctx%>/admin/products">Prodotti</a>
                  <a href="<%=ctx%>/admin/categories">Categorie</a>
                  <a href="<%=ctx%>/admin/orders">Ordini</a>
                  <a href="<%=ctx%>/admin/users" class="active">Utenti</a>
                  <a href="<%=ctx%>/admin/slots">Slot</a>
                </aside>

                <!-- Content -->
                <section class="admin-content">
                  <div class="admin-actions-bar">
                    <div>
                      <h2 class="admin-header-title">Utenti</h2>
                      <div class="admin-subtitle">Gestione utenti e permessi</div>
                    </div>
                  </div>

                  <!-- Toast Container -->
                  <div id="toast-container"></div>

                  <!-- Compact Toolbar -->
                  <form class="admin-toolbar" method="get" action="<%=ctx%>/admin/users">
                    <div class="search-box">
                      <input type="text" name="q" placeholder="Cerca nome/email…" value="<%= esc(q) %>">
                    </div>

                    <select name="type">
                      <option value="">Tutti i ruoli</option>
                      <option value="VISITOR" <%="VISITOR" .equals(type) ? "selected" : "" %>>Visitor</option>
                      <option value="REGISTERED" <%="REGISTERED" .equals(type) ? "selected" : "" %>>Registered</option>
                      <option value="PREMIUM" <%="PREMIUM" .equals(type) ? "selected" : "" %>>Premium</option>
                      <option value="ADMIN" <%="ADMIN" .equals(type) ? "selected" : "" %>>Admin</option>
                    </select>

                    <label class="toggle-check">
                      <input type="checkbox" name="onlyInactive" value="1" <%=onlyInactive ? "checked" : "" %>>
                      <span>Solo disattivi</span>
                    </label>

                    <div class="toolbar-actions">
                      <button class="btn-filter" type="submit">Filtra</button>
                      <a class="btn-reset" href="<%=ctx%>/admin/users">🔄 Reset</a>
                    </div>
                  </form>

                  <!-- Table with Fixed Height Scroll -->
                  <div class="table-scroll-panel">
                    <div class="table-scroll-body">
                      <table class="modern-table">
                        <thead>
                          <tr>
                            <th width="5%">ID</th>
                            <th width="20%">Nome</th>
                            <th width="25%">Email</th>
                            <th width="20%">Ruolo</th>
                            <th width="10%">Stato</th>
                            <th width="10%">Registrato</th>
                            <th width="10%" class="right">Azioni</th>
                          </tr>
                        </thead>
                        <tbody>
                          <% if (list !=null && !list.isEmpty()) { for (User u : list) { boolean active=false; try {
                            java.lang.reflect.Method m; try { m=u.getClass().getMethod("getActive"); } catch
                            (NoSuchMethodException e) { m=u.getClass().getMethod("isActive"); } Object val=m.invoke(u);
                            if (val instanceof Boolean) active=(Boolean) val; } catch (Exception ignore) {} %>
                            <tr>
                              <td data-label="ID" class="order-id-cell">
                                <%= u.getUserId() %>
                              </td>
                              <td data-label="Nome" class="customer-cell">
                                <%= esc(u.getFirstName()) %>
                                  <%= esc(u.getLastName()) %>
                              </td>
                              <td data-label="Email" class="customer-cell-email"
                                style="font-size: 0.95rem; color: #fff;">
                                <%= esc(u.getEmail()) %>
                              </td>

                              <td data-label="Ruolo">
                                <form method="post" action="<%=ctx%>/admin/users/role" data-role-form>
                                  <input type="hidden" name="csrf" value="${csrfToken}">
                                  <input type="hidden" name="id" value="<%= u.getUserId() %>">
                                  <select name="role" class="table-select" onfocus="this.dataset.prev = this.value;"
                                    onchange="confirmRoleChange(this)">
                                    <% String current=String.valueOf(u.getUserType()); String[]
                                      roles={"VISITOR", "REGISTERED" , "PREMIUM" , "ADMIN" }; for (String r : roles) {
                                      %>
                                      <option value="<%= r %>" <%=r.equalsIgnoreCase(current) ? "selected" : "" %>><%= r
                                          %>
                                      </option>
                                      <% } %>
                                  </select>
                                </form>
                              </td>

                              <td data-label="Stato">
                                <span class="chip <%= active ? " success" : " warn" %>">
                                  <%= active ? "Attivo" : "Disattivo" %>
                                </span>
                              </td>
                              <td data-label="Registrato" class="table-date">
                                <%= u.getRegistrationDate()==null ? "—" : esc(u.getRegistrationDate()) %>
                              </td>
                              <td data-label="Azioni" class="right">
                                <form method="post" action="<%=ctx%>/admin/users/toggle" style="display:inline">
                                  <input type="hidden" name="csrf" value="${csrfToken}">
                                  <input type="hidden" name="id" value="<%= u.getUserId() %>">
                                  <input type="hidden" name="active" value="<%= active ? " 0" : "1" %>">
                                  <button class="btn sm <%= active ? " gray" : " red" %>" type="button"
                                    onclick="confirmStatusChange(this.form, '<%= active ? "disattivare" : "attivare" %>')">
                                    <%= active ? "Disattiva" : "Attiva" %>
                                  </button>
                                </form>
                              </td>
                            </tr>
                            <% } } else { %>
                              <tr>
                                <td colspan="7" class="center muted empty-state">
                                  <div class="empty-icon">👥</div>
                                  Nessun utente trovato.
                                </td>
                              </tr>
                              <% } %>
                        </tbody>
                      </table>
                    </div>
                  </div>
                </section>
              </div>
            </div>

            <!-- Custom Confirmation Modal -->
            <div id="confirmModal" class="modal-overlay">
              <div class="modal-box">
                <div class="modal-title" id="modalTitle">Conferma Azione</div>
                <div class="modal-desc" id="modalDesc">Sei sicuro di voler cambiare il ruolo a questo utente?</div>
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

              // --- Modal Logic ---
              const modal = document.getElementById('confirmModal');
              const modalTitle = document.getElementById('modalTitle');
              const modalDesc = document.getElementById('modalDesc');
              let pendingForm = null;
              let pendingSelect = null;
              let prevValue = null;

              function confirmRoleChange(select) {
                pendingSelect = select;
                pendingForm = select.form;
                prevValue = select.dataset.prev;
                const newVal = select.value;
                modalTitle.textContent = 'Conferma modifica ruolo';
                modalDesc.textContent = 'Stai per cambiare il ruolo in ' + newVal + '. Confermi l\'operazione?';
                modal.classList.add('active');
              }

              function confirmStatusChange(form, actionLabel) {
                pendingForm = form;
                pendingSelect = null;
                prevValue = null;
                modalTitle.textContent = 'Conferma cambio stato';
                modalDesc.textContent = 'Stai per ' + actionLabel + ' questo utente. Confermi l\'operazione?';
                modal.classList.add('active');
              }

              function closeModal() {
                modal.classList.remove('active');
                if (pendingSelect && prevValue !== null) {
                  pendingSelect.value = prevValue;
                }
                pendingForm = null;
                pendingSelect = null;
                prevValue = null;
              }

              function confirmAction() {
                if (pendingForm) {
                  pendingForm.submit();
                }
              }
            </script>
            <jsp:include page="../footer.jsp" />
          </body>

          </html>
