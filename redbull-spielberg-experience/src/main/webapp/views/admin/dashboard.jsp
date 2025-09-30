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
  <link rel="stylesheet" href="<%=ctx%>/styles/admin.css?v=3">
  <style>
    /* layout KPI */
    .kpi-grid{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-top:10px}
    @media (max-width: 860px){.kpi-grid{grid-template-columns:1fr}}
    .kpi{background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.15);border-radius:16px;padding:16px}
    .kpi .label{opacity:.85;margin-bottom:6px}
    .kpi .value{font-weight:900;font-size:1.6rem}

    /* storico / stats */
    .stats-controls{display:flex;gap:8px;flex-wrap:wrap;align-items:center;margin-bottom:10px}
    .stats-controls input[type=date]{background:#001e36;color:#fff;border:1px solid rgba(255,255,255,.2);border-radius:10px;padding:8px 10px}
    .stats-row{display:grid;grid-template-columns:1fr 1fr;gap:16px}
    @media (max-width: 980px){ .stats-row{grid-template-columns:1fr} }
    .mini-kpi{display:grid;grid-template-columns:1fr 1fr;gap:10px}
    .mini-kpi .cell{background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.15);border-radius:12px;padding:12px}
    .mini-kpi .label{opacity:.85;font-size:.95rem}
    .mini-kpi .val{font-weight:900;font-size:1.15rem}
    .err{background:#b33939;border:1px solid rgba(0,0,0,.2);border-radius:10px;padding:10px}
    .tbl{width:100%;border-collapse:collapse}
    .tbl th,.tbl td{padding:8px;border-bottom:1px solid rgba(255,255,255,.12)}
    .tbl thead th{color:#F5A600}
    .right{text-align:right}

    /* box azioni rapide */
    .quick-actions .btn{min-width:210px}
  </style>
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
        <!-- ✅ nuovo accesso diretto agli slot -->
        <a href="<%=ctx%>/admin/slots">Genera Slot</a>
      </aside>

      <section class="admin-content">
        <div class="top">
          <h1 class="mt-0">Dashboard</h1>
          <!-- i pulsanti nella top sono nascosti da admin.css per evitare duplicati -->
          <div class="gap-6">
            <a class="btn"         href="<%=ctx%>/admin/orders">Vai agli Ordini</a>
            <a class="btn gray"    href="<%=ctx%>/admin/products">Gestisci Prodotti</a>
            <a class="btn outline" href="<%=ctx%>/admin/users">Gestisci Utenti</a>
          </div>
        </div>

        <!-- ✅ Box azioni rapide visibile -->
        <div class="card quick-actions" style="margin-top:8px">
          <div class="gap-6">
            <a class="btn" href="<%=ctx%>/admin/slots">Gestisci slot (date & capienza)</a>
            <a class="btn gray" href="<%=ctx%>/admin/products">Prodotti</a>
            <a class="btn outline" href="<%=ctx%>/admin/orders">Ordini</a>
          </div>
        </div>

        <!-- KPI del giorno -->
        <div class="kpi-grid">
          <div class="kpi">
            <div class="label">Ordini di oggi</div>
            <div class="value"><%= ordersToday %></div>
          </div>
          <div class="kpi">
            <div class="label">Incasso di oggi</div>
            <div class="value"><%= euro %></div>
          </div>
          <div class="kpi">
            <div class="label">Ordini in attesa</div>
            <div class="value"><%= pendingCount %></div>
          </div>
          <div class="kpi">
            <div class="label">Prodotti sotto scorta</div>
            <div class="value"><%= lowStockCount %></div>
          </div>
        </div>

        <!-- STORICO / STATISTICHE (senza grafico) -->
        <div class="card" style="margin-top:16px" id="stats-card">
          <div class="stats-controls">
            <h2 class="mt-0" style="margin-right:auto">Storico vendite</h2>
            <label>Da <input type="date" id="from"></label>
            <label>A <input type="date" id="to"></label>
            <button class="btn" id="btn-load" type="button">Aggiorna</button>
          </div>

          <div id="stats-error" class="err" style="display:none"></div>

          <div class="stats-row">
            <div class="card">
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
            </div>

            <div class="card">
              <table class="tbl" id="tbl">
                <thead>
                  <tr><th>Giorno</th><th class="right">Ordini</th><th class="right">Incasso</th></tr>
                </thead>
                <tbody></tbody>
              </table>
            </div>
          </div>
        </div>

        <div class="card" style="margin-top:16px">
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

        // Tabella
        data.series.forEach(function(r){
          const tr = document.createElement('tr');
          tr.innerHTML =
            '<td>' + r.date + '</td>' +
            '<td class="right">' + number(r.orders) + '</td>' +
            '<td class="right">' + euro(r.revenue) + '</td>';
          tblBody.appendChild(tr);
        });
      }

      function showErr(msg){
        errBox.textContent = msg;
        errBox.style.display='block';
      }

      function number(x){
        return new Intl.NumberFormat('it-IT').format(x||0);
      }
      function euro(x){
        const num = (typeof x==='number') ? x : Number(x);
        return new Intl.NumberFormat('it-IT',{style:'currency',currency:'EUR'}).format(isFinite(num)?num:0);
      }
    })();
  </script>
</body>
</html>