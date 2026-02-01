<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ page import="java.util.*, model.Category" %>
    <%! @SuppressWarnings("unused") private static String esc(Object o) { if (o==null) return "" ; String
      s=String.valueOf(o); return s.replace("&", "&amp;" ).replace("<", "&lt;" ).replace(">", "&gt;")
      .replace("\"", "&quot;").replace("'", "&#39;");
      }
      %>
      <% String ctx=request.getContextPath(); @SuppressWarnings("unchecked") List<Category> categories = (List<Category>
          ) request.getAttribute("categories");
          if (categories == null) categories = new ArrayList<>();

            String ok = request.getParameter("ok");
            String err = request.getParameter("err");
            %>
            <!DOCTYPE html>
            <html lang="it">

            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1" />
              <title>Admin • Categorie</title>
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
                    <a href="<%=ctx%>/admin/products">Prodotti</a>
                    <a href="<%=ctx%>/admin/categories" class="active">Categorie</a>
                    <a href="<%=ctx%>/admin/orders">Ordini</a>
                    <a href="<%=ctx%>/admin/users">Utenti</a>
                    <a href="<%=ctx%>/admin/slots">Slot</a>
                  </aside>

                  <section class="admin-content">
                    <div class="admin-actions-bar">
                      <div>
                        <h2 class="admin-header-title">Categorie</h2>
                        <div class="admin-subtitle">Gestione tassonomia prodotti</div>
                      </div>
                      <a class="btn" href="<%=ctx%>/admin/categories/edit">+ Nuova Categoria</a>
                    </div>

                    <!-- Toast Container -->
                    <div id="toast-container"></div>

                    <div class="card table-panel">
                      <table class="modern-table">
                        <thead>
                          <tr>
                            <th width="60" class="center">ID</th>
                            <th width="200">Nome</th>
                            <th>Descrizione</th>
                            <th width="100" class="center">Stato</th>
                            <th width="80" class="right">Azioni</th>
                          </tr>
                        </thead>
                        <tbody>
                          <% if (categories.isEmpty()) { %>
                            <tr>
                              <td colspan="5" class="center muted empty-state">Nessuna categoria trovata.</td>
                            </tr>
                            <% } %>
                              <% for (Category c : categories) { %>
                                <tr>
                                  <td class="center order-id-cell" data-label="ID">
                                    <%= c.getCategoryId() %>
                                  </td>
                                  <td data-label="Nome" class="customer-cell">
                                    <%= esc(c.getName()) %>
                                  </td>
                                  <td data-label="Descrizione" class="table-desc">
                                    <%= esc(c.getDescription()) !=null && !esc(c.getDescription()).isEmpty() ?
                                      esc(c.getDescription()) : "—" %>
                                  </td>
                                  <td class="center" data-label="Stato">
                                    <span class="chip <%= c.isActive() ? " success" : "warn" %>">
                                      <%= c.isActive() ? "Attiva" : "Inattiva" %>
                                    </span>
                                  </td>
                                  <td class="right" data-label="Azioni">
                                    <a class="btn sm outline"
                                      href="<%=ctx%>/admin/categories/edit?id=<%= c.getCategoryId() %>"
                                      title="Modifica">
                                      ✏️
                                    </a>
                                  </td>
                                </tr>
                                <% } %>
                        </tbody>
                      </table>
                    </div>
                  </section>
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
              </script>

              <jsp:include page="/views/footer.jsp" />
            </body>

            </html>