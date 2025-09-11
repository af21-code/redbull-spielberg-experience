<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%
  User authUser = (User) session.getAttribute("authUser");
  String ctx = request.getContextPath();
  String uri = request.getRequestURI() == null ? "" : request.getRequestURI();

  boolean ordersActive = uri.contains("/orders") || uri.endsWith("/views/orders.jsp");
  boolean shopActive   = uri.contains("/shop") || uri.contains("/booking") || uri.endsWith("/views/shop.jsp");
%>

<!-- Inietta dinamicamente il CSS del logout nel <head> anche se questo file è incluso dentro <body> -->
<script>
(function(){
  try {
    var id = "rb-logout-css";
    if (!document.getElementById(id)) {
      var l = document.createElement("link");
      l.id = id; l.rel = "stylesheet";
      l.href = "<%=ctx%>/styles/logoutbtn.css?v=3";
      (document.head || document.getElementsByTagName('head')[0]).appendChild(l);
    }
  } catch(e){}
})();
</script>

<!-- Fallback minimo e ad alta specificità, nel caso il link non carichi -->
<style>
header .menu-right .Btn{
  --bg:#1f2937; --bgH:#E30613; --txt:#fff; --ring:rgba(227,6,19,.35);
  display:inline-flex; align-items:center; gap:.6rem;
  background:var(--bg) !important; color:var(--txt) !important;
  border:1px solid rgba(255,255,255,.12); border-radius:12px;
  padding:.55rem .9rem; cursor:pointer;
  transition:background .2s, transform .15s, box-shadow .2s, border-color .2s;
}
header .menu-right .Btn .sign{ display:grid; place-items:center; width:20px; height:20px; }
header .menu-right .Btn .sign svg{ width:100%; height:100%; transition:transform .2s; }
header .menu-right .Btn .text{ font-weight:700; letter-spacing:.2px; }
header .menu-right .Btn:hover{
  background:var(--bgH) !important; transform:translateY(-1px);
  box-shadow:0 10px 24px var(--ring); border-color:rgba(227,6,19,.55);
}
header .menu-right .Btn:hover .sign svg{ transform:translateX(2px); }
header .menu-right .Btn:active{ transform:translateY(0); box-shadow:none; }
</style>

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
        <li><a href="<%=ctx%>/views/rb21.jsp">RB-21</a></li>
        <li><a href="<%=ctx%>/index.jsp#track">PISTA</a></li>
        <li><a href="<%=ctx%>/shop" class="<%= shopActive ? "active" : "" %>">SHOP</a></li>
      </ul>

      <ul class="menu-right">
        <% if (authUser == null) { %>
          <li><a href="<%=ctx%>/views/login.jsp" class="btn-login">Login</a></li>
        <% } else { %>
          <li><a href="<%=ctx%>/orders" class="btn-cart <%= ordersActive ? "active" : "" %>">Ordini</a></li>
          <li><a href="<%=ctx%>/cart/view" class="btn-cart">Carrello</a></li>
          <li>
            <form action="<%=ctx%>/logout" method="get" style="display:inline;">
              <button class="Btn" type="submit" title="Logout" aria-label="Logout">
                <div class="sign" aria-hidden="true">
                  <svg viewBox="0 0 512 512" focusable="false">
                    <path d="M377.9 105.9L500.7 228.7c7.2 7.2 11.3 17.1 11.3 27.3s-4.1 20.1-11.3 27.3L377.9 406.1c-6.4 6.4-15 9.9-24 9.9c-18.7 0-33.9-15.2-33.9-33.9l0-62.1-128 0c-17.7 0-32-14.3-32-32l0-64c0-17.7 14.3-32 32-32l128 0 0-62.1c0-18.7 15.2-33.9 33.9-33.9c9 0 17.6 3.6 24 9.9zM160 96L96 96c-17.7 0-32 14.3-32 32l0 256c0 17.7 14.3 32 32 32l64 0c17.7 0 32 14.3 32 32s-14.3 32-32 32l-64 0c-53 0-96-43-96-96L0 128C0 75 43 32 96 32l64 0c17.7 0 32 14.3 32 32s-14.3 32-32 32z"/>
                  </svg>
                </div>
                <span class="text">Logout</span>
              </button>
            </form>
          </li>
        <% } %>
      </ul>
    </nav>
  </div>
</header>