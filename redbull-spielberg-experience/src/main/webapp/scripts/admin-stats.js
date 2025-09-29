(function(){
  const ctx = window.ADM_CTX || "";
  const $from = document.getElementById("adm-stats-from");
  const $to   = document.getElementById("adm-stats-to");
  const $btn  = document.getElementById("adm-stats-refresh");

  const $orders  = document.getElementById("kpi-orders");
  const $paid    = document.getElementById("kpi-paid");
  const $rev     = document.getElementById("kpi-revenue");
  const $avg     = document.getElementById("kpi-avg");
  const $tbody   = document.getElementById("adm-stats-tbody");

  // default: ultimi 7 giorni
  const today = new Date();
  const toISO = d => new Date(d.getTime() - d.getTimezoneOffset()*60000).toISOString().slice(0,10);

  const defTo = toISO(today);
  const defFrom = toISO(new Date(today.getFullYear(), today.getMonth(), today.getDate() - 6));
  if ($from && !$from.value) $from.value = defFrom;
  if ($to && !$to.value)     $to.value   = defTo;

  async function load(){
    const from = $from.value || defFrom;
    const to   = $to.value   || defTo;

    if ($tbody) $tbody.innerHTML = `<tr><td colspan="3" class="muted">Caricamento…</td></tr>`;
    [$orders,$paid,$rev,$avg].forEach(el => el && (el.textContent = "…"));

    try{
      const res = await fetch(`${ctx}/admin/stats?from=${from}&to=${to}`, { credentials: "same-origin" });
      if (!res.ok) throw new Error("HTTP " + res.status);
      const data = await res.json();

      // KPI
      const k = data.kpi || {};
      $orders.textContent = (k.orders ?? 0);
      $paid.textContent   = (k.paidOrders ?? 0);

      const fmt = new Intl.NumberFormat("it-IT", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
      const rev = Number(k.revenue ?? 0);
      const avg = Number(k.avgOrder ?? 0);
      $rev.textContent = fmt.format(rev);
      $avg.textContent = fmt.format(avg);

      // Serie
      const s = Array.isArray(data.series) ? data.series : [];
      if (!s.length){
        $tbody.innerHTML = `<tr><td colspan="3" class="muted">Nessun dato nel periodo selezionato.</td></tr>`;
      } else {
        $tbody.innerHTML = s.map(row => {
          const date = row.date;
          const ord  = row.orders ?? 0;
          const r    = fmt.format(Number(row.revenue ?? 0));
          return `<tr><td>${date}</td><td>${ord}</td><td>€ ${r}</td></tr>`;
        }).join("");
      }
    } catch(e){
      console.error(e);
      if ($tbody) $tbody.innerHTML = `<tr><td colspan="3" class="muted">Errore nel caricamento.</td></tr>`;
      [$orders,$paid,$rev,$avg].forEach(el => el && (el.textContent = "—"));
    }
  }

  $btn && $btn.addEventListener("click", load);
  load(); // autoload
})();