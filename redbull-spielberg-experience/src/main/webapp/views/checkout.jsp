<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ page
    import="java.util.*, java.math.BigDecimal, model.CartItem, java.text.DecimalFormat, java.text.DecimalFormatSymbols, java.util.Locale"
    %>

    <%! // ---- Helper: escape HTML sicuro senza dipendenze ----
      private static String esc(Object o) { if (o==null)
      return "" ; String s=String.valueOf(o); return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
      .replace("\"","&quot;").replace("'","&#39;");
      }

      // ---- Helper per risolvere il path immagine (con fallback) ----
      @SuppressWarnings("unused")
      private static String resolveImg(String ctx, String imageUrl, String vehicleCode, String productType) {
      if (imageUrl != null && !imageUrl.isBlank()) {
      String u = imageUrl.trim();
      String l = u.toLowerCase(Locale.ROOT);
      if (l.startsWith("data:")) return u; // già data URI
      if (l.startsWith("http://") || l.startsWith("https://")) return u; // URL esterno
      // Heuristica: base64 pura dal DB
      if (u.length() > 100 && u.matches("[A-Za-z0-9+/=\\r\\n]+")) {
      return "data:image/jpeg;base64," + u.replaceAll("\\s+", "");
      }
      if (u.startsWith("/")) return ctx + u; // assoluto in app
      return ctx + "/" + u; // relativo
      }
      String v = (vehicleCode == null) ? "" : vehicleCode.trim().toLowerCase(Locale.ROOT);
      if ("EXPERIENCE".equalsIgnoreCase(productType)) {
      if ("rb21".equals(v) || "f1".equals(v)) return ctx + "/images/vehicles/rb21.jpg";
      if ("f2".equals(v)) return ctx + "/images/vehicles/f2.jpg";
      }
      return ctx + "/images/vehicles/placeholder-vehicle.jpg";
      }
      %>

      <% String ctx=request.getContextPath(); // Carrello dal session scope (come nel tuo file originale)
        @SuppressWarnings("unchecked") List<CartItem> items = (List<CartItem>) session.getAttribute("cartItems");
          model.User auth = (model.User) session.getAttribute("authUser");
          String defaultShipName = (auth == null) ? "" : ( (auth.getFirstName()==null?"":auth.getFirstName()) + " " +
          (auth.getLastName()==null?"":auth.getLastName()) ).trim();
          String defaultShipPhone = (auth == null || auth.getPhoneNumber()==null) ? "" : auth.getPhoneNumber();

          // Formattazione prezzi (IT)
          DecimalFormatSymbols sy = new DecimalFormatSymbols(Locale.ITALY);
          sy.setDecimalSeparator(',');
          sy.setGroupingSeparator('.');
          DecimalFormat money = new DecimalFormat("#,##0.00", sy);

          BigDecimal total = BigDecimal.ZERO;
          if (items != null) for (CartItem it : items) total = total.add(it.getTotal());
          %>

          <!DOCTYPE html>
          <html lang="it">

          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <title>Checkout</title>
            <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
            <link rel="stylesheet" href="<%=ctx%>/styles/checkout.css?v=2">
            <style>
              /* Piccolo ritocco per le thumb nel riepilogo (non tocca il resto del CSS) */
              .summary-line {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 10px
              }

              .summary-line .sum-left {
                display: flex;
                align-items: center;
                gap: 10px;
                min-width: 0
              }

              .sum-thumb {
                width: 64px;
                height: 48px;
                object-fit: cover;
                border-radius: 8px;
                border: 1px solid rgba(255, 255, 255, .15)
              }

              .sum-name {
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                max-width: 320px
              }

              @media (max-width: 600px) {
                .sum-name {
                  max-width: 200px
                }
              }
            </style>
          </head>

          <body>
            <jsp:include page="header.jsp" />

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

                  <% Object ce=request.getAttribute("checkoutError"); if (ce !=null) { %>
                    <a id="srv-error-anchor"></a>
                    <div class="srv-error">
                      <%= esc(ce) %>
                    </div>
                    <script>
                      // porta in vista l'errore del server
                      setTimeout(() => {
                        const a = document.getElementById('srv-error-anchor');
                        if (a) a.scrollIntoView({ behavior: 'smooth', block: 'center' });
                      }, 0);
                    </script>
                    <% } %>

                      <!-- action -> /checkout/confirm -->
                      <form id="checkout-form" method="post" action="<%=ctx%>/checkout/confirm" novalidate
                        autocomplete="off">
                        <!-- idempotency key (dal servlet) -->
                        <input type="hidden" name="idempotencyKey" value="${idempotencyKey}">
                        <!-- CSRF token (dal servlet / filtro) -->
                        <input type="hidden" name="csrf" value="${csrfToken}">

                        <!-- HIDDEN fields per il backend (input, NON textarea) -->
                        <input type="hidden" name="shippingAddress" id="shippingAddress">
                        <input type="hidden" name="billingAddress" id="billingAddress">

                        <!-- STEP 1: ADDRESSES -->
                        <section class="step-panel is-visible" data-step-panel="1" aria-label="Indirizzi">
                          <h2>Dati di Spedizione</h2>
                          <div class="grid-2">
                            <div class="field">
                              <label for="ship_name">Nome e cognome</label>
                              <input id="ship_name" type="text" autocomplete="name" value="<%=esc(defaultShipName)%>"
                                required>
                              <div class="error-msg"></div>
                            </div>
                            <div class="field">
                              <label for="ship_phone">Telefono</label>
                              <input id="ship_phone" type="tel" autocomplete="tel" placeholder="+39..."
                                value="<%=esc(defaultShipPhone)%>" required>
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
                              <input id="ship_zip" type="text" inputmode="numeric" pattern="\\d{5}" placeholder="00000"
                                required>
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
                                <input id="bill_zip" type="text" inputmode="numeric" pattern="\\d{5}"
                                  placeholder="00000">
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
                              <span class="pay-card-body" style="display:block">
                                <span class="pay-title" style="display:block">Carta</span>
                                <span class="pay-desc" style="display:block">Visa, MasterCard, Amex</span>
                              </span>
                            </label>

                            <label class="pay-card">
                              <input type="radio" name="paymentMethod" value="PAYPAL" required>
                              <span class="pay-card-body" style="display:block">
                                <span class="pay-title" style="display:block">PayPal</span>
                                <span class="pay-desc" style="display:block">Paga con il tuo account</span>
                              </span>
                            </label>

                            <label class="pay-card">
                              <input type="radio" name="paymentMethod" value="BANK_TRANSFER" required>
                              <span class="pay-card-body" style="display:block">
                                <span class="pay-title" style="display:block">Bonifico</span>
                                <span class="pay-desc" style="display:block">Istruzioni dopo la conferma</span>
                              </span>
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
                            <p class="hint">I dati carta non vengono memorizzati. Il pagamento è simulato per il
                              progetto.</p>
                          </div>


                          <div class="field">
                            <label for="notes">Note (opz.)</label>
                            <textarea name="notes" id="notes" rows="2"
                              placeholder="Richieste particolari..."></textarea>
                          </div>

                          <div class="form-error" id="form-error" aria-live="polite" style="visibility:hidden">
                          </div>

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
                    <% if (items !=null) { for (CartItem it : items) { String img=resolveImg(ctx, it.getImageUrl(),
                      it.getVehicleCode(), it.getProductType()); %>
                      <div class="summary-line">
                        <div class="sum-left">
                          <img class="sum-thumb"
                            src="<%= esc(resolveImg(ctx, it.getImageUrl(), it.getVehicleCode(), it.getProductType())) %>"
                            alt="<%= esc(it.getProductName()) %>"
                            onerror="this.onerror=null;this.src='<%=ctx%>/images/placeholder.jpg';">
                          <div>
                            <div class="sum-name">
                              <%= esc(it.getProductName()) %>
                            </div>
                            <div class="muted" style="font-size:0.85rem;">
                              Qty <%= it.getQuantity() %> × € <%= money.format(it.getUnitPrice()) %>
                                  <% if (it.getSize() !=null && !it.getSize().isBlank()) { %> · Taglia: <%=
                                      esc(it.getSize()) %>
                                      <% } %>
                            </div>
                            <div><strong>€ <%= money.format(it.getTotal()) %></strong></div>
                          </div>
                          <% } } %>
                            <hr class="sep">
                            <div class="summary-line total">
                              <span>Totale</span><span>€ <%= money.format(total) %></span>
                            </div>
                        </div>
                      </div>
                  </div>
                </div>

                <jsp:include page="footer.jsp" />
                <script src="<%=ctx%>/scripts/checkout.js?v=2"></script>
          </body>

          </html>