<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%
  String ctx = request.getContextPath();
  List<Map<String,Object>> orders = (List<Map<String,Object>>) request.getAttribute("orders");
  SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Admin · Prodotti</title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/admin.css?v=1">
</head>
<body>
<jsp:include page="../header.jsp"/>
<div class="wrap">
  <div class="top">
    <form method="get" action="<%=ctx%>/admin/orders" style="display:flex;gap:8px;flex-wrap:wrap">
      <input type="date" name="from" value="<%= request.getParameter("from")==null?"":request.getParameter("from") %>">
      <input type="date" name="to"   value="<%= request.getParameter("to")==null?"":request.getParameter("to") %>">
      <input type="number" name="userId" placeholder="User ID" min="1" value="<%= request.getParameter("userId")==null?"":request.getParameter("userId") %>">
      <button class="btn" type="submit">Filtra</button>
    </form>
    <div></div>
  </div>

  <div class="card">
    <table>
      <thead>
        <tr>
          <th>ID</th><th>Numero</th><th>Cliente</th><th>Totale</th><th>Status</th><th>Pag.</th><th>Data</th><th></th>
        </tr>
      </thead>
      <tbody>
      <% if (orders != null) for (Map<String,Object> o : orders) { %>
        <tr>
          <td><%= o.get("order_id") %></td>
          <td><%= o.get("order_number") %></td>
          <td><%= o.get("customer_name")==null? ("user#"+o.get("user_id")) : o.get("customer_name") %></td>
          <td>€ <%= o.get("total_amount") %></td>
          <td><%= o.get("status") %></td>
          <td><%= o.get("payment_status") %> (<%= o.get("payment_method") %>)</td>
          <td><%= o.get("order_date")==null?"":df.format((java.sql.Timestamp)o.get("order_date")) %></td>
          <td style="text-align:right">
            <a class="btn" href="<%=ctx%>/order?id=<%= o.get("order_id") %>">Dettagli</a>
          </td>
        </tr>
      <% } %>
      </tbody>
    </table>
  </div>
</div>
<jsp:include page="../footer.jsp"/>
</body>
</html>