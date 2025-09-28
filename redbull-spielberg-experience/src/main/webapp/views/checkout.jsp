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
  <link rel="stylesheet" href="<%=ctx%>/styles/checkout.css?v=2">
</head>
<body>
<jsp:include page="header.jsp"/>

<div class="checkout-wrap">
  <div class="grid">
    <!-- FORM -->
    <div class="card">
      <div class="stepper">
        <div class="step is-active" data-step="1">
          <span class="bubble">1</span>
          <span>Indirizzi</span>
        </div>
        <div class="divider"></div>
        <div class="step" data-step="2">
          <span class="bubble">2</span>
          <span>Pagamento</span>
        </div>
      </div>

      <% if (request.getAttribute("checkoutError") != null) { %>
        <a id="srv-error-anchor"></a>
        <div class="srv-error"><%= request.getAttribute("checkoutError") %></div>
        <script>
          // porta in vista l'errore del server
          setTimeout(() => {
            const a = document.getElementById('srv-error-anchor');
            if (a) a.scrollIntoView({behavior:'smooth', block:'center'});
          }, 0);
        </script>
      <% } %>

      <!-- action -> /checkout/confirm -->
      <form id="checkout-form" method="post" action="<%=ctx%>/checkout/confirm" novalidate autocomplete="off">
        <!-- idempotency key (dal servlet) -->
        <input type="hidden" name="idempotencyKey" value="${idempotencyKey}">
        <!-- CSRF token (dal servlet / filtro) -->
        <input type="hidden" name="csrf" value="${csrfToken}">

        <!-- HIDDEN fields per il backend (input, NON textarea) -->
        <input type="hidden" name="shippingAddress" id="shippingAddress">
        <input type="hidden" name="billingAddress"  id="billingAddress">

        <!-- STEP 1: ADDRESSES -->
        <section class="step-panel is-visible" data-step-panel="1" aria-label="Indirizzi">
          <h2>Dati di Spedizione</h2>
          <div class="grid-2">
            <div class="field">
              <label for="ship_name">Nome e cognome</label>
              <input id="ship_name" type="text" autocomplete="name" required>
              <div class="error-msg"></div>
            </div>
            <div class="field">
              <label for="ship_phone">Telefono</label>
              <input id="ship_phone" type="tel" autocomplete="tel" placeholder="+39..." required>
              <div class="error-msg"></div>
            </div>
          </div>

          <div class="field">
            <label for="ship_street">Via e numero</label>
            <input id="ship_street" type="text" autocomplete="address-line1" required>
            <div class="error-msg"></div>
          </div>

          <div class="grid-3">
            <div class="field">
              <label for="ship_city">Città</label>
              <input id="ship_city" type="text" autocomplete="address-level2" required>
              <div class="error-msg"></div>
            </div>
            <div class="field">
              <label for="ship_prov">Provincia</label>
              <input id="ship_prov" type="text" maxlength="2" placeholder="es. MI" required>
              <div class="error-msg"></div>
            </div>
            <div class="field">
              <label for="ship_zip">CAP</label>
              <input id="ship_zip" type="text" inputmode="numeric" pattern="\\d{5}" placeholder="00000" required>
              <div class="error-msg"></div>
            </div>
          </div>

          <div class="field">
            <label for="ship_country">Paese</label>
            <input id="ship_country" type="text" value="Italia" required>
            <div class="error-msg"></div>
          </div>

          <hr class="sep">

          <div class="flex-between">
            <h2>Fatturazione</h2>
            <label class="switch">
              <input id="same_as_shipping" type="checkbox" checked>
              <span>Uguale alla spedizione</span>
            </label>
          </div>

          <div id="billing-fields" class="billing-fields is-hidden">
            <div class="grid-2">
              <div class="field">
                <label for="bill_name">Nome e cognome</label>
                <input id="bill_name" type="text" autocomplete="name">
                <div class="error-msg"></div>
              </div>
              <div class="field">
                <label for="bill_cf">Codice Fiscale / P.IVA (opz.)</label>
                <input id="bill_cf" type="text" autocomplete="on">
                <div class="error-msg"></div>
              </div>
            </div>

            <div class="field">
              <label for="bill_street">Via e numero</label>
              <input id="bill_street" type="text" autocomplete="address-line1">
              <div class="error-msg"></div>
            </div>

            <div class="grid-3">
              <div class="field">
                <label for="bill_city">Città</label>
                <input id="bill_city" type="text" autocomplete="address-level2">
                <div class="error-msg"></div>
              </div>
              <div class="field">
                <label for="bill_prov">Provincia</label>
                <input id="bill_prov" type="text" maxlength="2" placeholder="es. MI">
                <div class="error-msg"></div>
              </div>
              <div class="field">
                <label for="bill_zip">CAP</label>
                <input id="bill_zip" type="text" inputmode="numeric" pattern="\\d{5}" placeholder="00000">
                <div class="error-msg"></div>
              </div>
            </div>

            <div class="field">
              <label for="bill_country">Paese</label>
              <input id="bill_country" type="text" value="Italia">
              <div class="error-msg"></div>
            </div>
          </div>

          <div class="nav-row">
            <button class="btn next" type="button" data-next>Continua</button>
          </div>
        </section>

        <!-- STEP 2: PAYMENT -->
        <section class="step-panel" data-step-panel="2" aria-label="Pagamento">
          <h2>Metodo di Pagamento</h2>

          <div class="pay-grid">
            <label class="pay-card">
              <input type="radio" name="paymentMethod" value="CARD" required>
              <div class="pay-card-body">
                <div class="pay-title">Carta</div>
                <div class="pay-desc">Visa, MasterCard, Amex</div>
              </div>
            </label>

            <label class="pay-card">
              <input type="radio" name="paymentMethod" value="PAYPAL" required>
              <div class="pay-card-body">
                <div class="pay-title">PayPal</div>
                <div class="pay-desc">Paga con il tuo account</div>
              </div>
            </label>

            <label class="pay-card">
              <input type="radio" name="paymentMethod" value="BANK_TRANSFER" required>
              <div class="pay-card-body">
                <div class="pay-title">Bonifico</div>
                <div class="pay-desc">Istruzioni dopo la conferma</div>
              </div>
            </label>
          </div>

          <!-- OPTIONAL card UI (solo estetica) -->
          <div class="card-extra" data-card-extra>
            <div class="grid-3">
              <div class="field">
                <label>Numero carta</label>
                <input type="text" inputmode="numeric" placeholder="•••• •••• •••• ••••">
              </div>
              <div class="field">
                <label>Scadenza</label>
                <input type="text" placeholder="MM/AA">
              </div>
              <div class="field">
                <label>CVV</label>
                <input type="password" inputmode="numeric" placeholder="•••">
              </div>
            </div>
            <p class="hint">I dati carta non vengono memorizzati. Il pagamento è simulato per il progetto.</p>
          </div>

          <div class="field">
            <label for="notes">Note (opz.)</label>
            <textarea name="notes" id="notes" rows="2" placeholder="Richieste particolari..."></textarea>
          </div>

          <div class="form-error" id="form-error" aria-live="polite" style="visibility:hidden"></div>

          <div class="nav-row">
            <button class="btn ghost" type="button" data-back>Torna indietro</button>
            <button class="btn" type="submit">Conferma ordine</button>
          </div>
        </section>
      </form>
    </div>

    <!-- SUMMARY -->
    <div class="card sticky">
      <h2>Riepilogo</h2>
      <div>
        <% if (items != null) {
             for (CartItem it : items) { %>
          <div class="summary-line">
            <span><%= it.getProductName() %> × <%= it.getQuantity() %></span>
            <span>€ <%= it.getTotal() %></span>
          </div>
        <% } } %>
        <hr class="sep">
        <div class="summary-line total">
          <span>Totale</span><span>€ <%= total %></span>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="footer.jsp"/>
<script src="<%=ctx%>/scripts/checkout.js?v=2"></script>
</body>
</html>