<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat, java.text.NumberFormat, java.net.URLEncoder, java.nio.charset.StandardCharsets, java.util.Locale" %>

<%!
  // Escape basilare per evitare HTML injection e gestire < > nei campi testuali
  private String esc(Object o) {
    if (o == null) return "";
    String s = String.valueOf(o);
    return s
      .replace("&","&amp;")
      .replace("<","&lt;")
      .replace(">","&gt;");
  }
%>

<%
  String ctx = request.getContextPath();

  @SuppressWarnings("unchecked")
  List<Map<String,Object>> orders = (List<Map<String,Object>>) request.getAttribute("orders");
  if (orders == null) orders = Collections.emptyList();

  // Valori filtri/paginazione passati dal servlet
  String fromVal   = (String) request.getAttribute("from");
  String toVal     = (String) request.getAttribute("to");
  String qVal      = (String) request.getAttribute("q");
  String statusVal = (String) request.getAttribute("status");

  Integer pageObj       = (Integer) request.getAttribute("page");
  Integer pagesObj      = (Integer) request.getAttribute("pages");
  Integer pageSizeObj   = (Integer) request.getAttribute("pageSize");
  Integer totalCountObj = (Integer) request.getAttribute("total"); // <-- rinominata

  int pageNum  = pageObj       == null ? 1  : pageObj;
  int pages    = pagesObj      == null ? 1  : pagesObj;
  int pageSize = pageSizeObj   == null ? 20 : pageSizeObj;
  int total    = totalCountObj == null ? 0  : totalCountObj;

  // Versioni "non null"
  String fromNZ   = (fromVal   == null) ? "" : fromVal;
  String toNZ     = (toVal     == null) ? "" : toVal;
  String qNZ      = (qVal      == null) ? "" : qVal;
  String statusNZ = (statusVal == null) ? "" : statusVal;

  // URL-encode per sicurezza
  String fromEnc   = URLEncoder.encode(fromNZ,   StandardCharsets.UTF_8);
  String toEnc     = URLEncoder.encode(toNZ,     StandardCharsets.UTF_8);
  String qEnc      = URLEncoder.encode(qNZ,      StandardCharsets.UTF_8);
  String statusEnc = URLEncoder.encode(statusNZ, StandardCharsets.UTF_8);

  // Export CSV
  String exportHref = ctx + "/admin/orders?from=" + fromEnc +
                      "&to=" + toEnc + "&q=" + qEnc +
                      "&status=" + statusEnc + "&export=csv";

  // Base QS per paginazione
  String baseQS = "from=" + fromEnc + "&to=" + toEnc + "&q=" + qEnc +
                  "&status=" + statusEnc + "&pageSize=" + pageSize;

  // Formattazioni
  SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");
  NumberFormat cf = NumberFormat.getCurrencyInstance(Locale.ITALY);
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Admin · Ordini</title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/admin.css?v=1">
  <style>
    .filters{display:flex;gap:8px;flex-wrap:wrap;align-items:center}
    .filters input,.filters select{height:36px;padding:6px 10px}
    .table-actions{display:flex;justify-content:space-between;align-items:center;margin:8px 0 14px}
    .muted{opacity:.85}
    .pager{display:flex;gap:8px;align-items:center;justify-content:flex-end;margin-top:12px}
    .btn{background:#444;color:#fff;border:none;border-radius:10px;padding:8px 12px;font-weight:700;cursor:pointer;text-decoration:none}
    .btn.line{background:transparent;border:1px solid rgba(255,255,255,.35)}
    table{width:100%;border-collapse:collapse}
    th,td{padding:10px;border-bottom:1px solid rgba(255,255,255,.15);vertical-align:top}
  </style>
</head>
<body>
<jsp:include page="/views/header.jsp"/>

<div class="wrap">
  <div class="top">
    <!-- FILTRI -->
    <form method="get" action="<%=ctx%>/admin/orders" class="filters">
      <input type="date"  name="from"  value="<%= esc(fromNZ) %>">
      <input type="date"  name="to"    value="<%= esc(toNZ) %>">
      <input type="text"  name="q"     placeholder="Email, nome o cognome" value="<%= esc(qNZ) %>" style="min-width:240px">
      <select name="status">
        <option value="" <%= (statusNZ.isBlank()) ? "selected":"" %>>Tutti gli stati</option>
        <option <%= "PENDING".equalsIgnoreCase(statusNZ)?"selected":"" %>     value="PENDING">PENDING</option>
        <option <%= "CONFIRMED".equalsIgnoreCase(statusNZ)?"selected":"" %>   value="CONFIRMED">CONFIRMED</option>
        <option <%= "PROCESSING".equalsIgnoreCase(statusNZ)?"selected":"" %>  value="PROCESSING">PROCESSING</option>
        <option <%= "COMPLETED".equalsIgnoreCase(statusNZ)?"selected":"" %>   value="COMPLETED">COMPLETED</option>
        <option <%= "CANCELLED".equalsIgnoreCase(statusNZ)?"selected":"" %>   value="CANCELLED">CANCELLED</option>
      </select>
      <select name="pageSize">
        <option value="10"  <%= pageSize==10  ?"selected":"" %>>10</option>
        <option value="20"  <%= pageSize==20  ?"selected":"" %>>20</option>
        <option value="50"  <%= pageSize==50  ?"selected":"" %>>50</option>
        <option value="100" <%= pageSize==100 ?"selected":"" %>>100</option>
      </select>
      <button class="btn" type="submit">Filtra</button>
      <a class="btn line" href="<%= exportHref %>">Export CSV</a>
    </form>
    <div></div>
  </div>

  <div class="card">
    <div class="table-actions">
      <div class="muted">Totale risultati: <strong><%= total %></strong></div>
      <div class="muted">Pagina <%= pageNum %> di <%= Math.max(pages,1) %></div>
    </div>

    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Numero</th>
          <th>Cliente</th>
          <th>Totale</th>
          <th>Stato</th>
          <th>Pagamento</th>
          <th>Data</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
      <% if (orders.isEmpty()) { %>
        <tr><td colspan="8" class="muted">Nessun ordine trovato con i filtri selezionati.</td></tr>
      <% } else {
           for (Map<String,Object> o : orders) {
             java.sql.Timestamp ts = (java.sql.Timestamp) o.get("order_date");
             Object totalObj = o.get("total_amount"); // importo ordine
             String totalStr;
             if (totalObj instanceof java.math.BigDecimal) {
               totalStr = cf.format((java.math.BigDecimal) totalObj);
             } else if (totalObj instanceof Number) {
               totalStr = cf.format(((Number) totalObj).doubleValue());
             } else {
               totalStr = String.valueOf(totalObj);
             }

             String payStatus = String.valueOf(o.get("payment_status"));
             Object pmObj = o.get("payment_method");
             String payMethod = (pmObj == null) ? "" : String.valueOf(pmObj);
      %>
        <tr>
          <td><%= o.get("order_id") %></td>
          <td><%= esc(o.get("order_number")) %></td>
          <td><%= esc(o.get("customer")) %></td>
          <td><%= esc(totalStr) %></td>
          <td><%= esc(o.get("status")) %></td>
          <td>
            <%= esc(payStatus) %>
            <% if (!payMethod.isBlank() && !"null".equalsIgnoreCase(payMethod)) { %>
              (<%= esc(payMethod) %>)
            <% } %>
          </td>
          <td><%= ts==null ? "" : df.format(ts) %></td>
          <td style="text-align:right">
            <a class="btn" href="<%=ctx%>/admin/order?id=<%= o.get("order_id") %>">Dettagli</a>
          </td>
        </tr>
      <% } } %>
      </tbody>
    </table>

    <!-- PAGINAZIONE -->
    <div class="pager">
      <a class="btn line" href="<%=ctx%>/admin/orders?<%= baseQS %>&page=1"                        title="Prima">&laquo;</a>
      <a class="btn line" href="<%=ctx%>/admin/orders?<%= baseQS %>&page=<%= Math.max(1, pageNum-1) %>" title="Precedente">&lsaquo;</a>
      <span class="muted">Pagina <strong><%= pageNum %></strong> / <%= Math.max(pages,1) %></span>
      <a class="btn line" href="<%=ctx%>/admin/orders?<%= baseQS %>&page=<%= Math.min(Math.max(pages,1), pageNum+1) %>" title="Successiva">&rsaquo;</a>
      <a class="btn line" href="<%=ctx%>/admin/orders?<%= baseQS %>&page=<%= Math.max(pages,1) %>"      title="Ultima">&raquo;</a>
    </div>
  </div>
</div>

<jsp:include page="/views/footer.jsp"/>
</body>
</html>