<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.math.BigDecimal, java.text.SimpleDateFormat" %>
<%
  String ctx = request.getContextPath();

  @SuppressWarnings("unchecked")
  List<Map<String,Object>> orders = (List<Map<String,Object>>) request.getAttribute("orders");
  if (orders == null) orders = Collections.emptyList();

  int total    = (request.getAttribute("total")    instanceof Integer) ? (Integer) request.getAttribute("total")    : 0;
  int pageNo   = (request.getAttribute("page")     instanceof Integer) ? (Integer) request.getAttribute("page")     : 1; // <- rinominata
  int pages    = (request.getAttribute("pages")    instanceof Integer) ? (Integer) request.getAttribute("pages")    : 1;
  int pageSize = (request.getAttribute("pageSize") instanceof Integer) ? (Integer) request.getAttribute("pageSize") : 20;

  String from   = String.valueOf(request.getAttribute("from"));   if ("null".equals(from)) from = "";
  String to     = String.valueOf(request.getAttribute("to"));     if ("null".equals(to)) to = "";
  String q      = String.valueOf(request.getAttribute("q"));      if ("null".equals(q)) q = "";
  String status = String.valueOf(request.getAttribute("status")); if ("null".equals(status)) status = "";

  SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");

  // helper per comporre query string mantenendo i filtri
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
  <title>Amministrazione • Ordini</title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/admin.css">
  <style>
    .wrap{padding:30px 18px 80px;background:linear-gradient(135deg,#001e36 0%,#000b2b 100%);min-height:60vh;color:#fff}
    .container{max-width:1200px;margin:0 auto}
    .card{background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.15);border-radius:16px;padding:16px}
    .title{margin:0 0 16px}
    .row{display:flex;gap:12px;flex-wrap:wrap;align-items:center}
    .filters .field{display:flex;flex-direction:column;gap:6px}
    .filters input,.filters select{background:#001E36;color:#fff;border:1px solid #0a3565;border-radius:10px;padding:8px 10px}
    .filters .btn{background:#444;color:#fff;border:none;border-radius:10px;padding:10px 14px;font-weight:700;cursor:pointer;text-decoration:none}
    .filters .btn.primary{background:#E30613}
    .table{width:100%;border-collapse:collapse;margin-top:12px}
    .table th,.table td{padding:10px;border-bottom:1px solid rgba(255,255,255,.15);vertical-align:top}
    .pill{display:inline-block;padding:2px 8px;border:1px solid rgba(255,255,255,.3);border-radius:999px}
    .muted{opacity:.85}
    .pagination{display:flex;gap:6px;flex-wrap:wrap;margin-top:12px}
    .pagination a,.pagination span{padding:6px 10px;border-radius:8px;border:1px solid rgba(255,255,255,.25);text-decoration:none;color:#fff}
    .pagination .active{background:#E30613;border-color:#E30613}
    .right{margin-left:auto}
  </style>
</head>
<body>
<jsp:include page="/views/header.jsp" />

<div class="wrap">
  <div class="container">
    <div class="row" style="justify-content:space-between;align-items:flex-end">
      <h2 class="title">Ordini (Admin)</h2>
      <div class="muted">Totale risultati: <strong><%= total %></strong></div>
    </div>

    <!-- FILTRI -->
    <div class="card filters">
      <form method="get" action="<%=ctx%>/admin/orders" class="row" style="align-items:flex-end">
        <div class="field">
          <label for="from">Da</label>
          <input type="date" id="from" name="from" value="<%= from %>">
        </div>
        <div class="field">
          <label for="to">A</label>
          <input type="date" id="to" name="to" value="<%= to %>">
        </div>
        <div class="field" style="min-width:220px">
          <label for="q">Cliente (nome/cognome/email)</label>
          <input type="text" id="q" name="q" value="<%= q %>" placeholder="Es. mario.rossi@email.com">
        </div>
        <div class="field">
          <label for="status">Stato</label>
          <select id="status" name="status">
            <option value="" <%= status.isBlank()?"selected":"" %>>Tutti</option>
            <option value="PENDING" <%= "PENDING".equalsIgnoreCase(status)?"selected":"" %>>PENDING</option>
            <option value="CONFIRMED" <%= "CONFIRMED".equalsIgnoreCase(status)?"selected":"" %>>CONFIRMED</option>
            <option value="PROCESSING" <%= "PROCESSING".equalsIgnoreCase(status)?"selected":"" %>>PROCESSING</option>
            <option value="COMPLETED" <%= "COMPLETED".equalsIgnoreCase(status)?"selected":"" %>>COMPLETED</option>
            <option value="CANCELLED" <%= "CANCELLED".equalsIgnoreCase(status)?"selected":"" %>>CANCELLED</option>
          </select>
        </div>
        <div class="field">
          <label for="pageSize">Per pagina</label>
          <select id="pageSize" name="pageSize">
            <option value="10"  <%= pageSize==10 ?"selected":"" %>>10</option>
            <option value="20"  <%= pageSize==20 ?"selected":"" %>>20</option>
            <option value="50"  <%= pageSize==50 ?"selected":"" %>>50</option>
            <option value="100" <%= pageSize==100?"selected":"" %>>100</option>
          </select>
        </div>
        <div class="field">
          <button class="btn primary" type="submit">Filtra</button>
        </div>
        <div class="right">
          <a class="btn" href="<%=ctx%>/admin/orders?<%= baseQS %>&export=csv">Esporta CSV</a>
        </div>
      </form>
    </div>

    <!-- TABELLA -->
    <div class="card">
      <table class="table">
        <thead>
        <tr>
          <th># Ordine</th>
          <th>Data</th>
          <th>Cliente</th>
          <th>Totale</th>
          <th>Stato</th>
          <th>Pagamento</th>
          <th>Metodo</th>
          <th></th>
        </tr>
        </thead>
        <tbody>
        <% if (orders.isEmpty()) { %>
          <tr><td colspan="8" class="muted">Nessun ordine trovato con i filtri correnti.</td></tr>
        <% } %>
        <%
          for (Map<String,Object> r : orders) {
            String onum = String.valueOf(r.get("order_number"));
            Object oda  = r.get("order_date");
            String date = (oda instanceof java.util.Date) ? df.format((java.util.Date) oda) : String.valueOf(oda);
            String cust = String.valueOf(r.get("customer"));
            BigDecimal tot = (BigDecimal) r.get("total_amount"); if (tot == null) tot = BigDecimal.ZERO;
            String st   = String.valueOf(r.get("status"));
            String pay  = String.valueOf(r.get("payment_status"));
            String pm   = String.valueOf(r.get("payment_method"));
            int oid     = (r.get("order_id") instanceof Number) ? ((Number) r.get("order_id")).intValue() : -1;
        %>
          <tr>
            <td><strong><%= onum %></strong></td>
            <td class="muted"><%= date %></td>
            <td style="max-width:280px"><%= cust %></td>
            <td>€ <%= tot %></td>
            <td><span class="pill"><%= st %></span></td>
            <td><span class="pill"><%= pay %></span></td>
            <td><%= pm %></td>
            <td><a class="pill" href="<%=ctx%>/admin/order?id=<%= oid %>">Dettagli</a></td>
          </tr>
        <% } %>
        </tbody>
      </table>

      <!-- PAGINAZIONE -->
      <div class="pagination">
        <% if (pageNo > 1) { %>
          <a href="<%=ctx%>/admin/orders?<%= baseQS %>&page=<%= (pageNo-1) %>">« Prec</a>
        <% } else { %><span class="muted">« Prec</span><% } %>

        <% for (int i = 1; i <= pages; i++) { %>
          <% if (i == pageNo) { %>
            <span class="active"><%= i %></span>
          <% } else { %>
            <a href="<%=ctx%>/admin/orders?<%= baseQS %>&page=<%= i %>"><%= i %></a>
          <% } %>
        <% } %>

        <% if (pageNo < pages) { %>
          <a href="<%=ctx%>/admin/orders?<%= baseQS %>&page=<%= (pageNo+1) %>">Succ »</a>
        <% } else { %><span class="muted">Succ »</span><% } %>
      </div>
    </div>

  </div>
</div>

<jsp:include page="/views/footer.jsp" />
</body>
</html>