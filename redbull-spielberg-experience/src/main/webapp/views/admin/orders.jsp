<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ page import="java.util.*, java.math.BigDecimal, java.text.SimpleDateFormat" %>
    <%! private static String esc(Object o) { if (o==null) return "" ; String s=String.valueOf(o); return
      s.replace("&", "&amp;" ).replace("<", "&lt;" ).replace(">", "&gt;")
      .replace("\"", "&quot;").replace("'", "&#39;");
      }

      private static String statusClass(String status) {
      if (status == null) return "chip";
      switch (status.toUpperCase()) {
      case "COMPLETED":
      return "chip success";
      case "CONFIRMED":
      case "PROCESSING":
      return "chip info";
      case "PENDING":
      return "chip warn";
      default:
      return "chip";
      }
      }

      private static String payClass(String pay) {
      if (pay == null) return "chip";
      String upper = pay.toUpperCase();
      if (upper.contains("PAID") || upper.contains("SUCCESS")) return "chip success";
      if (upper.contains("PENDING")) return "chip warn";
      return "chip";
      }
      %>
      <% String ctx=request.getContextPath(); Object ordAttr=request.getAttribute("orders"); List<Map<?, ?>> orders;
        if (ordAttr instanceof List
        <?>) {
        List<?> tmp = (List
        <?>) ordAttr;
        List<Map<?, ?>> safe = new ArrayList<>();
          for (Object x : tmp) {
          if (x instanceof Map
          <?, ?>) safe.add((Map
          <?, ?>) x);
          }
          orders = safe;
          } else {
          orders = Collections.emptyList();
          }

          int total = (request.getAttribute("total") instanceof Integer) ? (Integer) request.getAttribute("total") : 0;
          int pageNo = (request.getAttribute("page") instanceof Integer) ? (Integer) request.getAttribute("page") : 1;
          int pages = (request.getAttribute("pages") instanceof Integer) ? (Integer) request.getAttribute("pages") : 1;
          int pageSize = (request.getAttribute("pageSize") instanceof Integer) ? (Integer)
          request.getAttribute("pageSize") : 20;

          String from = String.valueOf(request.getAttribute("from"));
          if ("null".equals(from)) from = "";
          String to = String.valueOf(request.getAttribute("to"));
          if ("null".equals(to)) to = "";
          String q = String.valueOf(request.getAttribute("q"));
          if ("null".equals(q)) q = "";
          String status = String.valueOf(request.getAttribute("status"));
          if ("null".equals(status)) status = "";

          SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");

          String baseQS = "from=" + java.net.URLEncoder.encode(from, "UTF-8") +
          "&to=" + java.net.URLEncoder.encode(to, "UTF-8") +
          "&q=" + java.net.URLEncoder.encode(q, "UTF-8") +
          "&status=" + java.net.URLEncoder.encode(status, "UTF-8") +
          "&pageSize=" + pageSize;
          %>
          <!DOCTYPE html>
          <html lang="it">

          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <title>Admin • Ordini</title>
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
                  <a href="<%=ctx%>/admin/categories">Categorie</a>
                  <a href="<%=ctx%>/admin/orders" class="active">Ordini</a>
                  <a href="<%=ctx%>/admin/users">Utenti</a>
                  <a href="<%=ctx%>/admin/slots">Slot</a>
                </aside>

                <section class="admin-content">
                  <div class="admin-actions-bar">
                    <div>
                      <h2 class="admin-header-title">Ordini</h2>
                      <div class="admin-subtitle">
                        Gestione completa ordini • <strong>
                          <%= total %>
                        </strong> totali
                      </div>
                    </div>
                    <a class="btn sm outline" href="<%=ctx%>/admin/orders?<%= esc(baseQS) %>&export=csv">
                      📄 Esporta CSV
                    </a>
                  </div>

                  <!-- Card: Filtri -->
                  <form class="card filters-panel" method="get" action="<%=ctx%>/admin/orders">
                    <div class="filters filters-container">

                      <div class="search-bar-container search-container-grow">
                        <div class="input-group search-input-group">
                          <span class="input-icon" style="padding-left: 10px;">🔍</span>
                          <input type="text" name="q" value="<%= esc(q) %>" placeholder="Cerca cliente, ID ordine..."
                            style="padding-left: 35px;">
                        </div>
                        <div class="divider"></div>
                        <select name="status" class="status-select">
                          <option value="">Tutti gli stati</option>
                          <option value="PENDING" <%="PENDING" .equalsIgnoreCase(status) ? "selected" : "" %>>In Attesa
                          </option>
                          <option value="CONFIRMED" <%="CONFIRMED" .equalsIgnoreCase(status) ? "selected" : "" %>
                            >Confermato</option>
                          <option value="PROCESSING" <%="PROCESSING" .equalsIgnoreCase(status) ? "selected" : "" %>>In
                            Lavorazione</option>
                          <option value="COMPLETED" <%="COMPLETED" .equalsIgnoreCase(status) ? "selected" : "" %>
                            >Completato</option>
                          <option value="CANCELLED" <%="CANCELLED" .equalsIgnoreCase(status) ? "selected" : "" %>
                            >Annullato</option>
                        </select>
                      </div>

                      <!-- Compact Date Toolbar -->
                      <div
                        style="display: inline-flex; align-items: center; background: rgba(0,0,0,0.25); border: 1px solid rgba(255,255,255,0.1); border-radius: 8px; padding: 4px 8px; height: 42px;">
                        <input type="date" name="from" value="<%= esc(from) %>"
                          style="background:transparent; border:none; color:#fff; font-family:inherit; font-size:0.9rem; outline:none; width: 110px;"
                          aria-label="Da">
                        <span style="color:rgba(255,255,255,0.3); font-size:0.8rem; margin: 0 4px;">➜</span>
                        <input type="date" name="to" value="<%= esc(to) %>"
                          style="background:transparent; border:none; color:#fff; font-family:inherit; font-size:0.9rem; outline:none; width: 110px;"
                          aria-label="A">
                      </div>



                      <button class="btn filter-btn" type="submit">Filtra</button>
                      <a class="btn outline reset-btn" href="<%=ctx%>/admin/orders">↺</a>
                    </div>
                  </form>

                  <!-- Card: Table -->
                  <div class="card table-panel">
                    <table class="modern-table">
                      <thead>
                        <tr>
                          <th width="12%"># Ordine</th>
                          <th width="15%">Data</th>
                          <th width="25%">Cliente</th>
                          <th width="12%">Totale</th>
                          <th width="12%">Stato</th>
                          <th width="12%">Pagamento</th>
                          <th width="12%" style="text-align:right">Azioni</th>
                        </tr>
                      </thead>
                      <tbody>
                        <% if (orders.isEmpty()) { %>
                          <tr>
                            <td colspan="7" class="center muted empty-state">
                              <div class="empty-icon">📭</div>
                              Nessun ordine trovato.
                            </td>
                          </tr>
                          <% } %>
                            <% for (Map<?, ?> r : orders) {
                              String onum = String.valueOf(r.get("order_number"));
                              Object oda = r.get("order_date");
                              String date = (oda instanceof java.util.Date) ? df.format((java.util.Date) oda) :
                              String.valueOf(oda);
                              String cust = String.valueOf(r.get("customer"));
                              BigDecimal tot = (r.get("total_amount") instanceof BigDecimal) ? (BigDecimal)
                              r.get("total_amount") : BigDecimal.ZERO;
                              String st = String.valueOf(r.get("status"));
                              String pay = String.valueOf(r.get("payment_status"));
                              String pm = String.valueOf(r.get("payment_method"));
                              int oid = (r.get("order_id") instanceof Number) ? ((Number) r.get("order_id")).intValue()
                              : -1;
                              %>
                              <tr>
                                <td data-label="Ordine">
                                  <div class="order-id-cell">
                                    <%= esc(onum) %>
                                  </div>
                                </td>
                                <td data-label="Data" class="table-date">
                                  <%= esc(date) %>
                                </td>
                                <td data-label="Cliente">
                                  <div class="customer-cell">
                                    <%= esc(cust) %>
                                  </div>
                                  <div class="customer-cell-email">
                                    <%= esc(pm) %>
                                  </div>
                                </td>
                                <td data-label="Totale">
                                  <div class="price-cell">€ <%= tot %>
                                  </div>
                                </td>
                                <td data-label="Stato"><span class="<%= statusClass(st) %>">
                                    <%= esc(st) %>
                                  </span></td>
                                <td data-label="Pagamento"><span class="<%= payClass(pay) %>">
                                    <%= esc(pay) %>
                                  </span></td>
                                <td data-label="Azioni" style="text-align:right">
                                  <a class="btn sm outline" href="<%=ctx%>/admin/order?id=<%= oid %>">Dettagli</a>
                                </td>
                              </tr>
                              <% } %>
                      </tbody>
                    </table>

                    <!-- Footer Table -->
                    <div class="pagination-footer">
                      <div class="page-info">
                        Pagina <strong>
                          <%= pageNo %>
                        </strong> di <%= pages %>
                      </div>

                      <div class="page-size-selector" style="display: flex; align-items: center; gap: 8px;">
                        <span style="font-size: 0.85rem; opacity: 0.6;">Righe per pagina:</span>
                        <select onchange="updatePageSize(this.value)"
                          style="background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2); color: #fff; border-radius: 6px; padding: 2px 6px; font-size: 0.85rem; outline: none;">
                          <option value="20" <%=pageSize==20 ? "selected" : "" %>>20</option>
                          <option value="50" <%=pageSize==50 ? "selected" : "" %>>50</option>
                          <option value="100" <%=pageSize==100 ? "selected" : "" %>>100</option>
                        </select>
                      </div>

                      <div class="modern-pagination">
                        <% if (pageNo> 1) { %>
                          <a href="<%=ctx%>/admin/orders?<%= esc(baseQS) %>&page=<%= (pageNo-1) %>"
                            title="Precedente">←</a>
                          <% } %>

                            <% int startP=Math.max(1, pageNo - 2); int endP=Math.min(pages, pageNo + 2); for (int
                              i=startP; i <=endP; i++) { %>
                              <a href="<%=ctx%>/admin/orders?<%= esc(baseQS) %>&page=<%= i %>" class="<%= i==pageNo ? "active" : "" %>"><%= i %></a>
                              <% } %>

                                <% if (pageNo < pages) { %>
                                  <a href="<%=ctx%>/admin/orders?<%= esc(baseQS) %>&page=<%= (pageNo+1) %>"
                                    title="Successiva">→</a>
                                  <% } %>
                      </div>
                    </div>
                  </div>

                </section>
              </div>
            </div>

            <script>
              function updatePageSize(size) {
                const url = new URL(window.location);
                url.searchParams.set('pageSize', size);
                url.searchParams.set('page', '1');
                window.location.href = url.toString();
              }
            </script>
            <jsp:include page="/views/footer.jsp" />
          </body>

          </html>