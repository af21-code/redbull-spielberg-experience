<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8" />
  <title>Admin · Dashboard</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/indexStyle.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/userLogo.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/admin.css?v=1">
</head>
<body>
  <jsp:include page="/views/header.jsp"/>
  <main class="admin-bg">
    <div class="admin-shell">
      <aside class="admin-sidebar">
        <a href="${pageContext.request.contextPath}/admin" class="active">Dashboard</a>
        <a href="${pageContext.request.contextPath}/admin/products">Prodotti</a>
        <a href="${pageContext.request.contextPath}/admin/orders">Ordini</a>
        <a href="${pageContext.request.contextPath}/admin/users">Utenti</a>
      </aside>

      <section class="admin-content">
        <div class="top">
          <h1 class="mt-0">Dashboard</h1>
          <div class="gap-6">
            <a class="btn" href="${pageContext.request.contextPath}/admin/products">Gestisci Prodotti</a>
            <a class="btn gray" href="${pageContext.request.contextPath}/admin/orders">Gestisci Ordini</a>
            <a class="btn outline" href="${pageContext.request.contextPath}/admin/users">Utenti</a>
          </div>
        </div>

        <div class="card">
          <p class="muted">Benvenuto nel pannello amministratore.</p>
          <ul>
            <li>Vai su <strong>Prodotti</strong> per inserire/modificare/archiviare elementi del catalogo.</li>
            <li>Vai su <strong>Ordini</strong> per filtrare per data o cliente e aggiornare lo stato.</li>
            <li>Vai su <strong>Utenti</strong> per consultare o promuovere/demotere un account.</li>
          </ul>
        </div>
      </section>
    </div>
  </main>
  <jsp:include page="/views/footer.jsp"/>
</body>
</html>