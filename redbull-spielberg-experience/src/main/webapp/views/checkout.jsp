<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.math.BigDecimal, model.CartItem" %>
<%
  String ctx = request.getContextPath();
  @SuppressWarnings("unchecked")
  List<CartItem> items = (List<CartItem>) session.getAttribute("cartItems");
  BigDecimal total = BigDecimal.ZERO;
  if (items != null) for (CartItem it : items) total = total.add(it.getTotal());
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Checkout</title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <style>
    .checkout-wrap{padding:40px 24px 80px;background:linear-gradient(135deg,#001e36 0%,#000b2b 100%);color:#fff;min-height:60vh;}
    .grid{max-width:1100px;margin:0 auto;display:grid;grid-template-columns:2fr 1fr;gap:24px}
    .card{background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.15);border-radius:16px;padding:16px}
    h2{margin:0 0 12px}
    .row{display:flex;gap:12px}
    input,textarea,select{width:100%;padding:10px;border-radius:10px;border:none;background:#001e36;color:#fff}
    .summary-line{display:flex;justify-content:space-between;margin:6px 0}
    .total{font-weight:800;color:#F5A600}
    .btn{width:100%;margin-top:10px;background:#E30613;color:#fff;border:none;padding:12px;border-radius:10px;font-weight:800;cursor:pointer}
    .err{margin:0 0 12px;color:#ff7878}
    @media(max-width:900px){.grid{grid-template-columns:1fr}}
  </style>
</head>
<body>
<jsp:include page="header.jsp"/>

<div class="checkout-wrap">
  <div class="grid">
    <div class="card">
      <h2>Dati spedizione e pagamento</h2>
      <% if (request.getAttribute("checkoutError") != null) { %>
        <p class="err"><%= request.getAttribute("checkoutError") %></p>
      <% } %>

      <form method="post" action="<%=ctx%>/checkout">
        <label>Indirizzo di spedizione</label>
        <textarea name="shippingAddress" rows="3" required placeholder="Via, numero, città, CAP"></textarea>

        <div class="row">
          <div style="flex:1">
            <label>Indirizzo di fatturazione (opz.)</label>
            <textarea name="billingAddress" rows="3" placeholder="Se diverso dalla spedizione"></textarea>
          </div>
          <div style="flex:1">
            <label>Metodo di pagamento</label>
            <select name="paymentMethod" required>
              <option value="CARD">Carta</option>
              <option value="PAYPAL">PayPal</option>
              <option value="BANK_TRANSFER">Bonifico</option>
            </select>
          </div>
        </div>

        <label>Note (opz.)</label>
        <textarea name="notes" rows="2" placeholder="Richieste particolari..."></textarea>

        <button class="btn" type="submit">Conferma ordine</button>
      </form>
    </div>

    <div class="card">
      <h2>Riepilogo</h2>
      <div>
        <% if (items != null) {
             for (CartItem it : items) { %>
          <div class="summary-line">
            <span><%= it.getProductName() %> × <%= it.getQuantity() %></span>
            <span>€ <%= it.getTotal() %></span>
          </div>
        <% } } %>
        <hr style="border-color:rgba(255,255,255,0.15)">
        <div class="summary-line total">
          <span>Totale</span><span>€ <%= total %></span>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="footer.jsp"/>
</body>
</html>