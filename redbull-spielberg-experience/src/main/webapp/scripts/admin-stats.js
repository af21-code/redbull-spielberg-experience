(function(){
  var ctx = window.ADM_CTX || "";
  var $from = document.getElementById("adm-stats-from");
  var $to   = document.getElementById("adm-stats-to");
  var $btn  = document.getElementById("adm-stats-refresh");

  var $orders  = document.getElementById("kpi-orders");
  var $paid    = document.getElementById("kpi-paid");
  var $rev     = document.getElementById("kpi-revenue");
  var $avg     = document.getElementById("kpi-avg");
  var $tbody   = document.getElementById("adm-stats-tbody");

  // default: ultimi 7 giorni
  var today = new Date();
  var toISO = function(d){
    return new Date(d.getTime() - d.getTimezoneOffset()*60000).toISOString().slice(0,10);
  };

  var defTo = toISO(today);
  var defFrom = toISO(new Date(today.getFullYear(), today.getMonth(), today.getDate() - 6));
  if ($from && !$from.value) $from.value = defFrom;
  if ($to && !$to.value)     $to.value   = defTo;

  function setText(el, v){ if (el) el.textContent = v; }

  function load(){
    var from = ($from && $from.value) ? $from.value : defFrom;
    var to   = ($to && $to.value) ? $to.value : defTo;

    if ($tbody) $tbody.innerHTML = '<tr><td colspan="3" class="muted">Caricamento…</td></tr>';
    [ $orders, $paid, $rev, $avg ].forEach(function(el){ setText(el, "…"); });

    var url = ctx + "/admin/stats?from=" + encodeURIComponent(from) + "&to=" + encodeURIComponent(to);

    fetch(url, { credentials: "same-origin" })
      .then(function(res){
        if (!res.ok) throw new Error("HTTP " + res.status);
        return res.json();
      })
      .then(function(data){
        var k = (data && data.kpi) ? data.kpi : {};
        setText($orders, (k.orders != null ? k.orders : 0));
        setText($paid, (k.paidOrders != null ? k.paidOrders : 0));

        var fmt = new Intl.NumberFormat("it-IT", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        var rev = Number(k.revenue != null ? k.revenue : 0);
        var avg = Number(k.avgOrder != null ? k.avgOrder : 0);
        setText($rev, fmt.format(rev));
        setText($avg, fmt.format(avg));

        var s = (data && Array.isArray(data.series)) ? data.series : [];
        if (!$tbody) return;
        if (!s.length){
          $tbody.innerHTML = '<tr><td colspan="3" class="muted">Nessun dato nel periodo selezionato.</td></tr>';
        } else {
          var rows = '';
          for (var i = 0; i < s.length; i++){
            var row = s[i] || {};
            var date = row.date;
            var ord  = (row.orders != null ? row.orders : 0);
            var r    = fmt.format(Number(row.revenue != null ? row.revenue : 0));
            rows += '<tr><td>' + date + '</td><td>' + ord + '</td><td>€ ' + r + '</td></tr>';
          }
          $tbody.innerHTML = rows;
        }
      })
      .catch(function(e){
        try { console.error(e); } catch(_) {}
        if ($tbody) $tbody.innerHTML = '<tr><td colspan="3" class="muted">Errore nel caricamento.</td></tr>';
        [ $orders, $paid, $rev, $avg ].forEach(function(el){ setText(el, "—"); });
      });
  }

  if ($btn) $btn.addEventListener("click", load);
  load(); // autoload
})();