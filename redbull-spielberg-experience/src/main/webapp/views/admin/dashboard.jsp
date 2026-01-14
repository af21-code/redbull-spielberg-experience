<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <% String ctx=request.getContextPath(); Integer ordersToday=(Integer) request.getAttribute("ordersToday");
    java.math.BigDecimal revenueToday=(java.math.BigDecimal) request.getAttribute("revenueToday"); Integer
    pendingCount=(Integer) request.getAttribute("pendingCount"); Integer lowStockCount=(Integer)
    request.getAttribute("lowStockCount"); if (ordersToday==null) ordersToday=0; if (revenueToday==null)
    revenueToday=java.math.BigDecimal.ZERO; if (pendingCount==null) pendingCount=0; if (lowStockCount==null)
    lowStockCount=0; String euro="€ " + revenueToday.toPlainString(); %>
    <!DOCTYPE html>
    <html lang="it">

    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <title>Admin · Dashboard</title>
      <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
      <link rel="stylesheet" href="<%=ctx%>/styles/admin.css">
      <link rel="stylesheet" href="<%=ctx%>/styles/order-details.css">
    </head>

    <body>
      <jsp:include page="/views/header.jsp" />

      <div class="admin-bg">
        <div class="admin-shell">
          <aside class="admin-sidebar">
            <a href="<%=ctx%>/admin" class="active">Dashboard</a>
            <a href="<%=ctx%>/admin/products">Prodotti</a>
            <a href="<%=ctx%>/admin/categories">Categorie</a>
            <a href="<%=ctx%>/admin/orders">Ordini</a>
            <a href="<%=ctx%>/admin/users">Utenti</a>
            <a href="<%=ctx%>/admin/slots">Slot</a>
          </aside>

          <section class="admin-content">
            <div class="admin-actions-bar">
              <div>
                <h2 class="admin-header-title">Dashboard</h2>
                <div class="admin-subtitle">Panoramica attività e statistiche</div>
              </div>
              <div style="font-size: 0.9rem; opacity: 0.7;">
                <%= java.time.format.DateTimeFormatter.ofPattern("d MMMM yyyy").format(java.time.LocalDate.now()) %>
              </div>
            </div>

            <!-- KPI Cards -->
            <div class="kpi-grid">
              <div class="kpi-card">
                <div class="kpi-label">Ordini Oggi</div>
                <div class="kpi-value">
                  <%= ordersToday %>
                </div>
              </div>
              <div class="kpi-card kpi-success">
                <div class="kpi-label">Incasso Oggi</div>
                <div class="kpi-value">
                  <%= euro %>
                </div>
              </div>
              <div class="kpi-card kpi-warning">
                <div class="kpi-label">In Attesa</div>
                <div class="kpi-value">
                  <%= pendingCount %>
                </div>
              </div>
              <div class="kpi-card kpi-danger">
                <div class="kpi-label">Bassa Scorta</div>
                <div class="kpi-value">
                  <%= lowStockCount %>
                </div>
              </div>
            </div>

            <!-- Quick Actions -->
            <div class="card card-spaced" style="margin-bottom: 24px;">
              <h3 style="margin: 0 0 16px 0; font-size: 1.1rem; color: #fff;">Azioni Rapide</h3>
              <div style="display: flex; gap: 12px; flex-wrap: wrap;">
                <a class="btn" href="<%=ctx%>/admin/slots">⚡ Gestisci Slot</a>
                <a class="btn outline" href="<%=ctx%>/admin/products/edit">➕ Nuovo Prodotto</a>
                <a class="btn outline" href="<%=ctx%>/admin/orders">📦 Vedi Ordini</a>
              </div>
            </div>

            <!-- Historical Stats -->
            <div class="card card-spaced" id="stats-card">
              <div class="dashboard-section-header">
                <h3 style="margin: 0; font-size: 1.1rem;">Storico Vendite</h3>

                <!-- Compact Date Toolbar -->
                <div class="dashboard-date-toolbar">
                  <input type="date" id="from" aria-label="Da">
                  <span class="arrow">➜</span>
                  <input type="date" id="to" aria-label="A">
                  <div class="sep"></div>
                  <button id="btn-load" type="button" title="Aggiorna">🔄</button>
                </div>
              </div>

              <div id="stats-error" class="toast error"
                style="display:none; position: static; transform: none; margin-bottom: 16px;"></div>

              <div class="stats-grid">
                <!-- Table Section -->
                <div class="card table-panel"
                  style="background: rgba(0,0,0,0.2); border: 1px solid rgba(255,255,255,0.05);">
                  <table class="modern-table" id="tbl">
                    <thead>
                      <tr>
                        <th>Giorno</th>
                        <th class="right">Ordini</th>
                        <th class="right">Incasso</th>
                      </tr>
                    </thead>
                    <tbody>
                      <!-- Filled by JS -->
                    </tbody>
                  </table>
                </div>

                <!-- Mini KPI Section -->
                <div class="mini-kpi-col">
                  <div class="card" style="padding: 16px; background: rgba(255,255,255,0.03);">
                    <div class="notes-text">Ordini Totali</div>
                    <div class="val" id="k-orders" style="font-size: 1.5rem; font-weight: 700; color: #fff;">—</div>
                  </div>
                  <div class="card" style="padding: 16px; background: rgba(255,255,255,0.03);">
                    <div class="notes-text">Ordini Pagati</div>
                    <div class="val" id="k-paid" style="font-size: 1.5rem; font-weight: 700; color: #4cd964;">—</div>
                  </div>
                  <div class="card" style="padding: 16px; background: rgba(255,255,255,0.03);">
                    <div class="notes-text">Incasso Totale</div>
                    <div class="val" id="k-rev" style="font-size: 1.5rem; font-weight: 700; color: #fff;">—</div>
                  </div>
                  <div class="card" style="padding: 16px; background: rgba(255,255,255,0.03);">
                    <div class="notes-text">Scontrino Medio</div>
                    <div class="val" id="k-avg"
                      style="font-size: 1.5rem; font-weight: 700; color: rgba(255,255,255,0.7);">—</div>
                  </div>
                </div>
              </div>
            </div>
          </section>
        </div>
      </div>

      <jsp:include page="/views/footer.jsp" />

      <script>
        (function () {
          const BASE = '<%=ctx%>';
          const elFrom = document.getElementById('from');
          const elTo = document.getElementById('to');
          const btn = document.getElementById('btn-load');
          const errBox = document.getElementById('stats-error');
          const kOrders = document.getElementById('k-orders');
          const kPaid = document.getElementById('k-paid');
          const kRev = document.getElementById('k-rev');
          const kAvg = document.getElementById('k-avg');
          const tblBody = document.querySelector('#tbl tbody');

          // Default last 7 days
          const to = new Date();
          const from = new Date();
          from.setDate(to.getDate() - 6);
          elFrom.value = toIso(from);
          elTo.value = toIso(to);

          btn.addEventListener('click', load);
          load();

          function toIso(d) {
            return d.toISOString().slice(0, 10);
          }

          async function load() {
            errBox.style.display = 'none';
            tblBody.innerHTML = '';
            kOrders.textContent = kPaid.textContent = kRev.textContent = kAvg.textContent = '—';

            // Loading state
            tblBody.innerHTML = '<tr><td colspan="3" class="center muted" style="padding: 24px;">Caricamento dati...</td></tr>';

            const qs = new URLSearchParams({ from: elFrom.value, to: elTo.value });
            let res;
            try {
              res = await fetch(BASE + '/admin/stats?' + qs.toString(), { headers: { 'Accept': 'application/json' } });
            } catch (e) {
              return showErr('Impossibile contattare il server.');
            }
            if (!res.ok) {
              return showErr('Errore nel caricamento (' + res.status + ').');
            }
            let data;
            try {
              data = await res.json();
            } catch (e) {
              return showErr('Risposta non valida.');
            }
            if (data.error) {
              return showErr(data.error);
            }

            // Clear loading
            tblBody.innerHTML = '';

            // KPI
            kOrders.textContent = number(data.kpi.orders);
            kPaid.textContent = number(data.kpi.paidOrders);
            kRev.textContent = euro(data.kpi.revenue);
            kAvg.textContent = euro(data.kpi.avgOrder);

            // Table
            if (!data.series || data.series.length === 0) {
              tblBody.innerHTML = '<tr><td colspan="3" class="center muted empty-state"><div class="empty-icon">📊</div>Nessun dato nel periodo.</td></tr>';
            } else {
              data.series.forEach(function (r) {
                const tr = document.createElement('tr');
                tr.innerHTML =
                  '<td data-label="Giorno">' + r.date + '</td>' +
                  '<td data-label="Ordini" class="right" style="font-weight:500">' + number(r.orders) + '</td>' +
                  '<td data-label="Incasso" class="right price-highlight" style="font-size:0.95rem">' + euro(r.revenue) + '</td>';
                tblBody.appendChild(tr);
              });
            }
          }

          function showErr(msg) {
            errBox.textContent = msg;
            errBox.style.display = 'block';
          }

          function number(x) {
            return new Intl.NumberFormat('it-IT').format(x || 0);
          }

          function euro(x) {
            const num = (typeof x === 'number') ? x : Number(x);
            return new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format(isFinite(num) ? num : 0);
          }
        })();
      </script>
    </body>

    </html>