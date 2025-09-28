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
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/admin.css?v=3">
  <style>
    .kpi-grid{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-top:10px}
    @media (max-width: 860px){.kpi-grid{grid-template-columns:1fr}}
    .kpi{background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.15);border-radius:16px;padding:16px}
    .kpi .label{opacity:.85;margin-bottom:6px}
    .kpi .value{font-weight:900;font-size:1.6rem}
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
      </aside>

      <section class="admin-content">
        <div class="top">
          <h1 class="mt-0">Dashboard</h1>
          <div class="gap-6">
            <a class="btn"       href="<%=ctx%>/admin/orders">Vai agli Ordini</a>
            <a class="btn gray"  href="<%=ctx%>/admin/products">Gestisci Prodotti</a>
            <a class="btn outline" href="<%=ctx%>/admin/users">Gestisci Utenti</a>
          </div>
        </div>

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

        <div class="card" style="margin-top:16px">
          <p class="muted">Benvenuto nel pannello amministratore.</p>
        </div>
      </section>
    </div>
  </main>
  <jsp:include page="/views/footer.jsp"/>
</body>
</html>