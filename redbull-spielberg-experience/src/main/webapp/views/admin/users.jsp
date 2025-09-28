<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.User" %>
<%
  String ctx = request.getContextPath();
  @SuppressWarnings("unchecked")
  List<User> list = (List<User>) request.getAttribute("users");
  String q = request.getParameter("q") == null ? "" : request.getParameter("q");
  String type = request.getParameter("type") == null ? "" : request.getParameter("type");
  boolean onlyInactive = "1".equals(request.getParameter("onlyInactive"));

  String okMsg  = request.getParameter("ok");
  String errMsg = request.getParameter("err");
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Admin · Utenti</title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/admin.css?v=1">
</head>
<body>
<jsp:include page="../header.jsp"/>
<div class="wrap container-1100">

  <div class="top">
    <h1 class="mt-0">Utenti</h1>
    <form method="get" action="<%=ctx%>/admin/users" class="filters">
      <input type="search" name="q" placeholder="Cerca nome/email…" value="<%= q %>">
      <select name="type" aria-label="Ruolo">
        <option value="">Tutti i ruoli</option>
        <option value="VISITOR"    <%= "VISITOR".equals(type)?"selected":"" %>>Visitor</option>
        <option value="REGISTERED" <%= "REGISTERED".equals(type)?"selected":"" %>>Registered</option>
        <option value="PREMIUM"    <%= "PREMIUM".equals(type)?"selected":"" %>>Premium</option>
        <option value="ADMIN"      <%= "ADMIN".equals(type)?"selected":"" %>>Admin</option>
      </select>
      <label class="checkbox-inline">
        <input type="checkbox" name="onlyInactive" value="1" <%= onlyInactive?"checked":"" %> >
        <span>Solo disattivi</span>
      </label>
      <button class="btn" type="submit">Filtra</button>
    </form>
  </div>

  <% if (okMsg != null) { %>
    <div class="alert success"><%= okMsg %></div>
  <% } else if (errMsg != null) { %>
    <div class="alert danger"><%= errMsg %></div>
  <% } %>

  <div class="card">
    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Nome</th>
          <th>Email</th>
          <th>Ruolo</th>
          <th>Stato</th>
          <th>Registrato</th>
          <th class="right">Azioni</th>
        </tr>
      </thead>
      <tbody>
      <% if (list != null && !list.isEmpty()) {
           for (User u : list) {
             // --- ricava boolean active compatibile con getActive() o isActive()
             boolean active = false;
             try {
               java.lang.reflect.Method m;
               try { m = u.getClass().getMethod("getActive"); }
               catch (NoSuchMethodException e) { m = u.getClass().getMethod("isActive"); }
               Object val = m.invoke(u);
               if (val instanceof Boolean) active = (Boolean) val;
             } catch (Exception ignore) {}
      %>
        <tr>
          <td><%= u.getUserId() %></td>
          <td><%= (u.getFirstName()==null?"":u.getFirstName()) %> <%= (u.getLastName()==null?"":u.getLastName()) %></td>
          <td><%= u.getEmail() %></td>
          <td>
            <form method="post" action="<%=ctx%>/admin/users/role" class="gap-6">
              <input type="hidden" name="csrf" value="${csrfToken}">
              <input type="hidden" name="id" value="<%= u.getUserId() %>">
              <select name="role">
                <%
                  String current = String.valueOf(u.getUserType());
                  String[] roles = {"VISITOR","REGISTERED","PREMIUM","ADMIN"};
                  for (String r : roles) {
                %>
                  <option value="<%= r %>" <%= r.equalsIgnoreCase(current)?"selected":"" %>><%= r %></option>
                <% } %>
              </select>
              <button class="btn sm" type="submit">Cambia</button>
            </form>
          </td>
          <td>
            <span class="chip <%= active ? "success":"warn" %>">
              <%= active ? "Attivo" : "Disattivo" %>
            </span>
          </td>
          <td><%= u.getRegistrationDate()==null ? "—" : u.getRegistrationDate() %></td>
          <td class="right">
            <form method="post" action="<%=ctx%>/admin/users/toggle" style="display:inline">
              <input type="hidden" name="csrf" value="${csrfToken}">
              <input type="hidden" name="id" value="<%= u.getUserId() %>">
              <input type="hidden" name="active" value="<%= active ? "0":"1" %>">
              <button class="btn <%= active ? "gray":"red" %>" type="submit"
                      onclick="return confirm('Confermi l\\'aggiornamento dello stato?');">
                <%= active ? "Disattiva":"Attiva" %>
              </button>
            </form>
          </td>
        </tr>
      <% } } else { %>
        <tr><td colspan="7" class="center muted">Nessun utente trovato.</td></tr>
      <% } %>
      </tbody>
    </table>
  </div>
</div>
<jsp:include page="../footer.jsp"/>
</body>
</html>