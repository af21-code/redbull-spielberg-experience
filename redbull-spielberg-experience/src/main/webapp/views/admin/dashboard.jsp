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
            <div
              style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; margin-bottom: 24px;">
              <div class="card" style="padding: 24px;">
                <div
                  style="color: rgba(255,255,255,0.6); font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px;">
                  Ordini Oggi
                </div>
                <div style="font-size: 2rem; font-weight: 700; color: #fff;">
                  <%= ordersToday %>
                </div>
              </div>
              <div class="card" style="padding: 24px;">
                <div
                  style="color: rgba(46, 204, 113, 0.8); font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px;">
                  Incasso Oggi
                </div>
                <div style="font-size: 2rem; font-weight: 700; color: #4cd964;">
                  <%= euro %>
                </div>
              </div>
              <div class="card" style="padding: 24px;">
                <div
                  style="color: rgba(255, 179, 0, 0.8); font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px;">
                  In Attesa
                </div>
                <div style="font-size: 2rem; font-weight: 700; color: #ffb300;">
                  <%= pendingCount %>
                </div>
              </div>
              <div class="card" style="padding: 24px; position: relative; overflow: hidden;">
                <div
                  style="color: rgba(255, 59, 48, 0.8); font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px;">
                  Bassa Scorta
                </div>
                <div style="font-size: 2rem; font-weight: 700; color: #ff3b30;">
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
              <div
                style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 12px;">
                <h3 style="margin: 0; font-size: 1.1rem;">Storico Vendite</h3>

                <!-- Compact Date Toolbar -->
                <div
                  style="display: inline-flex; align-items: center; background: rgba(0,0,0,0.25); border: 1px solid rgba(255,255,255,0.1); border-radius: 8px; padding: 4px;">
                  <input type="date" id="from"
                    style="background:transparent; border:none; color:#fff; font-family:inherit; font-size:0.9rem; padding: 4px 8px; outline:none;"
                    aria-label="Da">
                  <span style="color:rgba(255,255,255,0.3); font-size:0.8rem;">➜</span>
                  <input type="date" id="to"
                    style="background:transparent; border:none; color:#fff; font-family:inherit; font-size:0.9rem; padding: 4px 8px; outline:none;"
                    aria-label="A">
                  <div style="width:1px; height:20px; background:rgba(255,255,255,0.1); margin: 0 4px;"></div>
                  <button id="btn-load" type="button"
                    style="background:transparent; border:none; cursor:pointer; padding: 4px 8px; font-size:1.1rem; line-height:1;"
                    title="Aggiorna">🔄</button>
                </div>
              </div>

              <div id="stats-error" class="toast error"
                style="display:none; position: static; transform: none; margin-bottom: 16px;"></div>

              <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px;">
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
                <div style="display: flex; flex-direction: column; gap: 12px;">
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
                  '<td>' + r.date + '</td>' +
                  '<td class="right" style="font-weight:500">' + number(r.orders) + '</td>' +
                  '<td class="right price-highlight" style="font-size:0.95rem">' + euro(r.revenue) + '</td>';
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