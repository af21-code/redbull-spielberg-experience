<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  String ctx = request.getContextPath();

  Integer ordersToday   = (Integer) request.getAttribute("ordersToday");
  java.math.BigDecimal revenueToday = (java.math.BigDecimal) request.getAttribute("revenueToday");
  Integer pendingCount  = (Integer) request.getAttribute("pendingCount");
  Integer lowStockCount = (Integer) request.getAttribute("lowStockCount");

  if (ordersToday == null)   ordersToday = 0;
  if (revenueToday == null)  revenueToday = java.math.BigDecimal.ZERO;
  if (pendingCount == null)  pendingCount = 0;
  if (lowStockCount == null) lowStockCount = 0;

  String euro = "€ " + revenueToday.toPlainString();
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8" />
  <title>Admin · Dashboard</title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/admin.css?v=6">
</head>
<body>
  <jsp:include page="/views/header.jsp"/>
  <main class="admin-bg">
    <div class="admin-shell">
      <aside class="admin-sidebar">
        <a href="<%=ctx%>/admin" class="active">Dashboard</a>
        <a href="<%=ctx%>/admin/products">Prodotti</a>
        <a href="<%=ctx%>/admin/orders">Ordini</a>
        <a href="<%=ctx%>/admin/users">Utenti</a>
      </aside>

      <section class="admin-content">
        <div class="top">
          <h1 class="mt-0">Dashboard</h1>
          <!-- pulsanti rapidi nascosti via CSS per evitare duplicati -->
          <div class="gap-6">
            <a class="btn"         href="<%=ctx%>/admin/orders">Vai agli Ordini</a>
            <a class="btn gray"    href="<%=ctx%>/admin/products">Gestisci Prodotti</a>
            <a class="btn outline" href="<%=ctx%>/admin/users">Gestisci Utenti</a>
          </div>
        </div>

        <!-- KPI del giorno -->
        <div class="kpi-grid">
          <div class="kpi">
            <div class="icon-badge kpi-orders" aria-hidden="true"></div>
            <div class="label">Ordini di oggi</div>
            <div class="value"><%= ordersToday %></div>
          </div>

          <div class="kpi">
            <div class="icon-badge kpi-revenue" aria-hidden="true"></div>
            <div class="label">Incasso di oggi</div>
            <div class="value"><%= euro %></div>
          </div>

          <div class="kpi">
            <div class="icon-badge kpi-pending" aria-hidden="true"></div>
            <div class="label">Ordini in attesa</div>
            <div class="value"><%= pendingCount %></div>
          </div>

          <div class="kpi">
            <div class="icon-badge kpi-lowstock" aria-hidden="true"></div>
            <div class="label">Prodotti sotto scorta</div>
            <div class="value"><%= lowStockCount %></div>
          </div>
        </div>

        <!-- STORICO / STATISTICHE (KPI + tabella) -->
        <div class="card stats-card" id="stats-card">
          <div class="stats-controls">
            <h2 class="mt-0" style="margin-right:auto">Storico vendite</h2>
            <label>Da <input type="date" id="from" aria-label="Data iniziale"></label>
            <label>A <input type="date" id="to" aria-label="Data finale"></label>
            <button class="btn" id="btn-load" type="button">Aggiorna</button>
          </div>

          <div id="stats-error" class="err" style="display:none"></div>
          <div id="period" class="period-note muted" aria-live="polite"></div>

          <div class="mini-kpi">
            <div class="cell">
              <div class="label">Ordini (totali)</div>
              <div class="val" id="k-orders">—</div>
            </div>
            <div class="cell">
              <div class="label">Ordini pagati</div>
              <div class="val" id="k-paid">—</div>
            </div>
            <div class="cell">
              <div class="label">Incasso</div>
              <div class="val" id="k-rev">—</div>
            </div>
            <div class="cell">
              <div class="label">Scontrino medio</div>
              <div class="val" id="k-avg">—</div>
            </div>
          </div>

          <div class="card sub-card">
            <table class="tbl" id="tbl">
              <thead>
                <tr><th>Giorno</th><th class="right">Ordini</th><th class="right">Incasso</th></tr>
              </thead>
              <tbody></tbody>
            </table>
          </div>
        </div>

        <div class="card foot-note">
          <p class="muted">Benvenuto nel pannello amministratore.</p>
        </div>
      </section>
    </div>
  </main>
  <jsp:include page="/views/footer.jsp"/>

  <script>
    (function(){
      const BASE = '<%=ctx%>';
      const elFrom = document.getElementById('from');
      const elTo   = document.getElementById('to');
      const btn    = document.getElementById('btn-load');
      const errBox = document.getElementById('stats-error');
      const kOrders= document.getElementById('k-orders');
      const kPaid  = document.getElementById('k-paid');
      const kRev   = document.getElementById('k-rev');
      const kAvg   = document.getElementById('k-avg');
      const tblBody= document.querySelector('#tbl tbody');
      const period = document.getElementById('period');

      // default ultimi 7 giorni
      const to = new Date();
      const from = new Date(); from.setDate(to.getDate() - 6);
      elFrom.value = toIso(from);
      elTo.value   = toIso(to);

      btn.addEventListener('click', load);
      load();

      function toIso(d){ return d.toISOString().slice(0,10); }

      async function load(){
        errBox.style.display='none';
        tblBody.innerHTML = '';
        kOrders.textContent = kPaid.textContent = kRev.textContent = kAvg.textContent = '—';
        period.textContent = '';

        const qs = new URLSearchParams({from: elFrom.value, to: elTo.value});
        let res;
        try{
          res = await fetch(BASE + '/admin/stats?' + qs.toString(), {headers:{'Accept':'application/json'}});
        }catch(e){
          return showErr('Impossibile contattare il server.');
        }
        if(!res.ok){
          return showErr('Errore nel caricamento ('+res.status+').');
        }
        let data;
        try{ data = await res.json(); }catch(e){ return showErr('Risposta non valida.'); }
        if(data.error){ return showErr(data.error); }

        // KPI
        kOrders.textContent = number(data.kpi.orders);
        kPaid.textContent   = number(data.kpi.paidOrders);
        kRev.textContent    = euro(data.kpi.revenue);
        kAvg.textContent    = euro(data.kpi.avgOrder);

        // Periodo
        var start = (data.series && data.series.length) ? data.series[0].date : elFrom.value;
        var end   = (data.series && data.series.length) ? data.series[data.series.length-1].date : elTo.value;
        period.textContent = 'Periodo: ' + start + ' → ' + end;

        // Tabella
        if (data.series && data.series.length){
          data.series.forEach(function(r){
            const tr = document.createElement('tr');
            tr.innerHTML =
              '<td>' + r.date + '</td>' +
              '<td class="right">' + number(r.orders) + '</td>' +
              '<td class="right">' + euro(r.revenue) + '</td>';
            tblBody.appendChild(tr);
          });
        } else {
          const tr = document.createElement('tr');
          tr.innerHTML = '<td colspan="3" class="muted">Nessun dato nel periodo selezionato.</td>';
          tblBody.appendChild(tr);
        }
      }

      function showErr(msg){
        errBox.textContent = msg;
        errBox.style.display='block';
      }
      function number(x){ return new Intl.NumberFormat('it-IT').format(x||0); }
      function euro(x){
        const num = (typeof x==='number') ? x : Number(x);
        return new Intl.NumberFormat('it-IT',{style:'currency',currency:'EUR'}).format(isFinite(num)?num:0);
      }
    })();
  </script>
</body>
</html>