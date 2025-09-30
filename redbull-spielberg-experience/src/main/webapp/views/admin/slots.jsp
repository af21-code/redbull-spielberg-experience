<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  String ctx = request.getContextPath();

  // Messaggi esito operazione (opzionali, impostati dalla servlet)
  Boolean resultOk = (Boolean) request.getAttribute("result_ok");
  String  resultMsg= (String)  request.getAttribute("result_msg");

  // Echo parametri per ripopolare il form
  Integer echoProductId = (Integer) request.getAttribute("echo_productId");
  String  echoStart     = (String)  request.getAttribute("echo_start");
  Integer echoDays      = (request.getAttribute("echo_days") instanceof Integer) ? (Integer) request.getAttribute("echo_days") : null;
  String  echoTimes     = (String)  request.getAttribute("echo_times");
  Integer echoCapacity  = (request.getAttribute("echo_capacity") instanceof Integer) ? (Integer) request.getAttribute("echo_capacity") : null;

  // Default se mancanti
  String defStart    = java.time.LocalDate.now().toString();
  String defTimes    = "09:00,11:00,14:00,16:00";
  String defDays     = "90";
  String defCapacity = "8";
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Admin · Gestione Slot</title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/admin.css?v=3">
  <style>
    .helper{opacity:.85;margin-top:6px}
    .grid-2{display:grid;grid-template-columns:1fr 1fr;gap:12px}
    @media (max-width: 900px){ .grid-2{grid-template-columns:1fr} }
    .result-ok{background:rgba(46,204,113,.18);border:1px solid rgba(46,204,113,.35);border-radius:12px;padding:12px}
    .result-err{background:rgba(227,6,19,.18);border:1px solid rgba(227,6,19,.35);border-radius:12px;padding:12px}
    .form-card{padding:16px}
  </style>
</head>
<body>
  <jsp:include page="/views/header.jsp"/>
  <main class="admin-bg">
    <div class="admin-shell">
      <aside class="admin-sidebar">
        <a href="<%=ctx%>/admin">Dashboard</a>
        <a href="<%=ctx%>/admin/products">Prodotti</a>
        <a href="<%=ctx%>/admin/orders">Ordini</a>
        <a href="<%=ctx%>/admin/users">Utenti</a>
        <a href="<%=ctx%>/admin/slots" class="active">Gestione Slot</a>
      </aside>

      <section class="admin-content">
        <div class="top">
          <h1 class="mt-0">Gestione Slot · Experience</h1>
          <div class="gap-6">
            <a class="btn outline" href="<%=ctx%>/admin">Torna alla Dashboard</a>
          </div>
        </div>

        <% if (resultMsg != null) { %>
          <div class="<%= (resultOk != null && resultOk) ? "result-ok" : "result-err" %>" role="alert">
            <%= resultMsg %>
          </div>
        <% } %>

        <div class="card form-card" style="margin-top:12px">
          <form method="post" action="<%=ctx%>/admin/slots/generate" novalidate>
            <div class="grid-2">
              <div>
                <label>Product ID (experience) *</label>
                <input type="number" name="productId" min="1" required
                       value="<%= (echoProductId!=null? String.valueOf(echoProductId) : "") %>">
                <div class="helper">ID del prodotto di tipo EXPERIENCE per cui generare gli slot.</div>
              </div>
              <div>
                <label>Data inizio *</label>
                <input type="date" name="start" required
                       value="<%= (echoStart!=null && !echoStart.isBlank()? echoStart : defStart) %>">
                <div class="helper">Formato YYYY-MM-DD (default: oggi).</div>
              </div>
            </div>

            <div class="grid-2" style="margin-top:12px">
              <div>
                <label>Numero giorni</label>
                <input type="number" name="days" min="1"
                       value="<%= (echoDays!=null? String.valueOf(echoDays) : defDays) %>">
                <div class="helper">Intervallo a partire dalla data di inizio (default: 90).</div>
              </div>
              <div>
                <label>Capienza per slot</label>
                <input type="number" name="capacity" min="1"
                       value="<%= (echoCapacity!=null? String.valueOf(echoCapacity) : defCapacity) %>">
                <div class="helper">Posti massimi per ciascuno slot (default: 8).</div>
              </div>
            </div>

            <div style="margin-top:12px">
              <label>Orari (comma-separated)</label>
              <input type="text" name="times"
                     placeholder="09:00,11:00,14:00,16:00"
                     value="<%= (echoTimes!=null && !echoTimes.isBlank()? echoTimes : defTimes) %>">
              <div class="helper">Lista orari in formato HH:mm separati da virgola.</div>
            </div>

            <div class="table-actions">
              <button class="btn" type="submit">Genera slot</button>
              <a class="btn gray" href="<%=ctx%>/admin">Annulla</a>
            </div>
          </form>
        </div>

        <div class="card" style="margin-top:12px">
          <p class="muted">
            Verranno creati, per ogni giorno nell’intervallo, gli slot indicati se non già presenti
              (es. per 90 giorni e 4 orari, 360 slot in totale).<br>
          </p>
        </div>
      </section>
    </div>
  </main>
  <jsp:include page="/views/footer.jsp"/>
</body>
</html>