<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%
  User authUser = (User) session.getAttribute("authUser");
  String ctx = request.getContextPath();
  String uri = request.getRequestURI();
  boolean shopActive   = (uri != null) && (uri.endsWith("/shop") || uri.endsWith("/views/shop.jsp"));
  boolean ordersActive = (uri != null) && (uri.endsWith("/orders") || uri.endsWith("/views/orders.jsp"));
%>

<header>
  <div class="container nav-container">
    <div class="logo">
      <a href="<%=ctx%>/index.jsp">
        <img src="https://cdn-3.motorsport.com/images/mgl/Y99JQRbY/s8/red-bull-racing-logo-1.jpg" alt="Red Bull Racing Logo" />
      </a>
    </div>

    <nav>
      <ul class="main-menu">
        <li><a href="<%=ctx%>/index.jsp">ESPLORA</a></li>
        <li><a href="<%=ctx%>/index.jsp#rb-21">RB-21</a></li>
        <li><a href="<%=ctx%>/index.jsp#track">PISTA</a></li>
        <li>
          <a href="<%=ctx%>/shop" class="<%= shopActive ? "active" : "" %>">SHOP</a>
        </li>
      </ul>

      <ul class="menu-right">
        <% if (authUser == null) { %>
          <li><a href="<%=ctx%>/views/login.jsp" class="btn-login">Login</a></li>
        <% } else { %>
          <li><a href="<%=ctx%>/orders" class="btn-cart <%= ordersActive ? "active" : "" %>">Ordini</a></li>
          <li><a href="<%=ctx%>/cart/view" class="btn-cart">Carrello</a></li>
          <li>
            <form action="<%=ctx%>/logout" method="get" style="display:inline;">
              <button class="Btn" type="submit" title="Logout">
                <div class="sign">
                  <svg viewBox="0 0 512 512" aria-hidden="true" focusable="false">
                    <path d="M377.9 105.9L500.7 228.7c7.2 7.2 11.3 17.1 11.3 27.3s-4.1 20.1-11.3 27.3L377.9 406.1c-6.4 6.4-15 9.9-24 9.9c-18.7 0-33.9-15.2-33.9-33.9l0-62.1-128 0c-17.7 0-32-14.3-32-32l0-64c0-17.7 14.3-32 32-32l128 0 0-62.1c0-18.7 15.2-33.9 33.9-33.9c9 0 17.6 3.6 24 9.9zM160 96L96 96c-17.7 0-32 14.3-32 32l0 256c0 17.7 14.3 32 32 32l64 0c17.7 0 32 14.3 32 32s-14.3 32-32 32l-64 0c-53 0-96-43-96-96L0 128C0 75 43 32 96 32l64 0c17.7 0 32 14.3 32 32s-14.3 32-32 32z"></path>
                  </svg>
                </div>
                <div class="text">Logout</div>
              </button>
            </form>
          </li>
        <% } %>
      </ul>
    </nav>
  </div>
</header>