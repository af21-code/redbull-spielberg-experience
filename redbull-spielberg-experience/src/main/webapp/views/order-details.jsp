<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ page import="java.util.*, java.math.BigDecimal, java.text.SimpleDateFormat" %>

    <%! // Escape HTML semplice
      private static String esc(Object o) { if (o==null) return ""
      ; String s=String.valueOf(o); return s.replace("&", "&amp;" ).replace("<", "&lt;" ).replace(">", "&gt;")
      .replace("\"", "&quot;").replace("'", "&#39;");
      }

      // Normalizza path immagine
      private String normImg(String p, String ctx) {
      if (p == null || p.isBlank()) return null;
      String s = p.trim();
      if (s.startsWith("http://") || s.startsWith("https://") || s.startsWith("//")) return s;
      if (s.startsWith("/")) return ctx + s;
      return ctx + "/" + s;
      }

      // Risolve immagine item
      private String resolveImg(String imageUrl, String vehicleCode, String productType, String ctx) {
      String db = normImg(imageUrl, ctx);
      if (db != null) return db;

      boolean isExp = productType != null && "EXPERIENCE".equalsIgnoreCase(productType);
      String v = vehicleCode == null ? "" : vehicleCode.trim().toLowerCase(java.util.Locale.ITALY);

      if (isExp) {
      if ("rb21".equals(v) || "f1".equals(v)) return ctx + "/images/vehicles/rb21.jpg";
      if ("f2".equals(v)) return ctx + "/images/vehicles/f2.jpg";
      if ("nascar".equals(v) || "stockcar".equals(v)) return ctx + "/images/vehicles/placeholder-vehicle.jpg";
      return ctx + "/images/vehicles/placeholder-vehicle.jpg";
      } else {
      return ctx + "/images/placeholder.jpg";
      }
      }

      private static Map<String, Object> asMapSO(Object obj) {
        return (obj instanceof Map) ? (Map<String, Object>) obj : null;
          }

          private static List<Map<String, Object>> asListOfMapSO(Object obj) {
            List<Map<String, Object>> out = new ArrayList<>();
                if (obj instanceof List
                <?>) {
            for (Object x : (List<?>) obj) {
                if (x instanceof Map
                <?, ?>) out.add((Map<String, Object>) x);
                  }
                  }
                  return out;
                  }
                  %>

                  <% String ctx=request.getContextPath(); Map<String, Object> o =
                    asMapSO(request.getAttribute("order"));
                    List<Map<String, Object>> items = asListOfMapSO(request.getAttribute("items"));

                      if (o == null) {
                      response.sendRedirect(ctx + "/orders");
                      return;
                      }

                      String onum = String.valueOf(o.get("order_number"));
                      BigDecimal tot = (o.get("total_amount") instanceof BigDecimal) ? (BigDecimal)
                      o.get("total_amount") : BigDecimal.ZERO;
                      String status = String.valueOf(o.get("status"));
                      String pay = String.valueOf(o.get("payment_status"));
                      String payMethod = String.valueOf(o.get("payment_method"));
                      String carrier = (String) o.get("carrier");
                      String tracking = (String) o.get("tracking_code");
                      String shipAddr = (String) o.get("shipping_address");
                      String billAddr = (String) o.get("billing_address");
                      String notes = (String) o.get("notes");
                      java.sql.Timestamp orderDate = (java.sql.Timestamp) o.get("order_date");
                      java.sql.Date eta = (java.sql.Date) o.get("estimated_delivery");
                      java.sql.Timestamp shippedAt = (java.sql.Timestamp) o.get("shipped_at");

                      String buyerFirst = String.valueOf(o.get("buyer_first_name"));
                      String buyerLast = String.valueOf(o.get("buyer_last_name"));
                      String buyerMail = String.valueOf(o.get("buyer_email"));
                      String buyerPhone = (String) o.get("buyer_phone");

                      SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");

                      String csrf = (String) request.getAttribute("csrfToken");
                      if (csrf == null || csrf.isEmpty()) csrf = (String) session.getAttribute("csrfToken");

                      String trackUrl = null;
                      if (carrier != null && tracking != null && !carrier.isBlank() && !tracking.isBlank()) {
                      if ("DHL".equalsIgnoreCase(carrier))
                      trackUrl = "https://www.dhl.com/it-it/home/tracking/tracking-express.html?tracking-id=" +
                      tracking;
                      else if ("UPS".equalsIgnoreCase(carrier))
                      trackUrl = "https://www.ups.com/track?tracknum=" + tracking;
                      else if ("FEDEX".equalsIgnoreCase(carrier) || "FEDEX EXPRESS".equalsIgnoreCase(carrier))
                      trackUrl = "https://www.fedex.com/fedextrack/?trknbr=" + tracking;
                      }

                      String statusClass = "badge";
                      if ("COMPLETED".equalsIgnoreCase(status)) statusClass += " ok";
                      else if ("CANCELLED".equalsIgnoreCase(status)) statusClass += " warn";

                      String backHref = ctx + "/orders";
                      boolean cancellable = !"COMPLETED".equalsIgnoreCase(status)
                      && !"CANCELLED".equalsIgnoreCase(status)
                      && shippedAt == null;
                      %>

                      <!DOCTYPE html>
                      <html lang="it">

                      <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1" />
                        <title>Ordine <%= esc(onum) %>
                        </title>
                        <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
                        <link rel="stylesheet" href="<%=ctx%>/styles/order-details.css">
                        <style>
                          .modal {
                            position: fixed;
                            inset: 0;
                            z-index: 9999;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                          }

                          .modal-backdrop {
                            position: absolute;
                            inset: 0;
                            background: rgba(0, 0, 0, 0.55);
                            backdrop-filter: blur(1px);
                          }

                          .modal-box {
                            position: relative;
                            background: #0b0f1a;
                            color: #fff;
                            padding: 20px;
                            border-radius: 12px;
                            box-shadow: 0 18px 36px rgba(0, 0, 0, 0.45);
                            max-width: 420px;
                            width: 90%;
                            z-index: 1;
                          }

                          .modal-actions {
                            margin-top: 16px;
                            display: flex;
                            gap: 10px;
                            justify-content: flex-end;
                          }

                          body.no-scroll {
                            overflow: hidden;
                          }
                        </style>
                      </head>

                      <body>
                        <jsp:include page="/views/header.jsp" />

                        <div class="page-wrap">
                          <div class="container">

                            <div class="card order-header-card">
                              <div class="row order-header-row">
                                <div class="row order-header-left">
                                  <h2 class="title" style="margin:0">Ordine <%= esc(onum) %>
                                  </h2>
                                  <span class="<%= esc(statusClass) %>">
                                    <%= esc(status) %>
                                  </span>
                                  <span class="badge <%= " PAID".equalsIgnoreCase(pay) ? "ok" : "warn" %>"><%= esc(pay)
                                      %></span>
                                </div>
                                <a class="btn line" href="<%= esc(backHref) %>">← Torna agli ordini</a>
                              </div>
                            </div>

                            <div class="grid">
                              <div class="col-left">
                                <div class="card">
                                  <h3 class="section-title">Articoli</h3>
                                  <% if (items.isEmpty()) { %>
                                    <p class="muted">Nessun articolo in questo ordine.</p>
                                    <% } %>

                                      <% for (Map<String, Object> r : items) {
                                        String name = String.valueOf(r.get("product_name"));
                                        Number qtyN = (Number) r.get("quantity");
                                        int qty = qtyN == null ? 0 : qtyN.intValue();
                                        BigDecimal up = (r.get("unit_price") instanceof BigDecimal) ? (BigDecimal)
                                        r.get("unit_price") : BigDecimal.ZERO;
                                        BigDecimal tp = (r.get("total_price") instanceof BigDecimal) ? (BigDecimal)
                                        r.get("total_price") : up.multiply(BigDecimal.valueOf(qty));
                                        String img = (String) r.get("image_url");
                                        String driver = (String) r.get("driver_name");
                                        String driverNum = (String) r.get("driver_number");
                                        String comp = (String) r.get("companion_name");
                                        String veh = (String) r.get("vehicle_code");
                                        String size = (String) r.get("size");
                                        String ptype = r.get("product_type") == null ? null :
                                        String.valueOf(r.get("product_type"));
                                        java.sql.Date ev = (java.sql.Date) r.get("event_date");
                                        String imgSrc = resolveImg(img, veh, ptype, ctx);
                                        %>
                                        <div class="item">
                                          <img class="thumb" src="<%= esc(imgSrc) %>" alt="<%= esc(name) %>"
                                            onerror="this.onerror=null;this.src='<%= ctx %>/images/vehicles/placeholder-vehicle.jpg';">
                                          <div>
                                            <div><strong>
                                                <%= esc(name) %>
                                              </strong></div>
                                            <div class="small muted">Q.tà <%= qty %> × € <%= up %>
                                            </div>
                                            <div class="small muted item-meta">
                                              <% boolean first=true; %>
                                                <% if (driver !=null && !driver.isBlank()) { %>
                                                  <span>Pilota: <strong>
                                                      <%= esc(driver) %>
                                                    </strong></span>
                                                  <% first=false; } %>
                                                    <% if (driverNum !=null && !driverNum.isBlank()) { %>
                                                      <% if (!first) { %> • <% } %><span>N°: <%= esc(driverNum) %>
                                                          </span>
                                                          <% first=false; } %>
                                                            <% if (comp !=null && !comp.isBlank()) { %>
                                                              <% if (!first) { %> • <% } %><span>Accompagnatore: <%=
                                                                      esc(comp) %></span>
                                                                  <% first=false; } %>
                                                                    <% if (veh !=null && !veh.isBlank()) { %>
                                                                      <% if (!first) { %> • <% } %><span>Veicolo: <%=
                                                                              esc(veh) %></span>
                                                                          <% first=false; } %>
                                                                            <% if (ev !=null) { %>
                                                                              <% if (!first) { %> • <% } %><span>Data:
                                                                                    <%= new
                                                                                      SimpleDateFormat("dd/MM/yyyy").format(ev)
                                                                                      %>
                                                                                  </span>
                                                                                  <% first=false; } %>
                                                                                    <% if (size !=null &&
                                                                                      !size.isBlank()) { %>
                                                                                      <% if (!first) { %> • <% } %>
                                                                                          <span>Taglia: <%= esc(size) %>
                                                                                          </span>
                                                                                          <% } %>
                                            </div>
                                          </div>
                                          <div class="price">€ <%= tp %>
                                          </div>
                                        </div>
                                        <% } %>

                                          <hr class="divider">
                                          <div class="row row-end">
                                            <div class="total">Totale ordine: € <%= tot %>
                                            </div>
                                          </div>
                                </div>

                                <% if (notes !=null && !notes.isBlank()) { %>
                                  <div class="card card-spaced">
                                    <h3 class="section-title">Note</h3>
                                    <p class="muted notes-text">
                                      <%= esc(notes) %>
                                    </p>
                                  </div>
                                  <% } %>
                              </div>

                              <div class="col-right">
                                <!-- Dettagli ordine -->
                                <div class="card">
                                  <h3 class="section-title">Dettagli ordine</h3>
                                  <div class="kvs">
                                    <div>Metodo</div>
                                    <div><strong>
                                        <%= esc(payMethod) %>
                                      </strong></div>
                                    <div>Creato</div>
                                    <div><strong>
                                        <%= (orderDate==null ? "—" : esc(new SimpleDateFormat("dd/MM/yyyy HH:mm").format(orderDate))) %>
                                      </strong></div>
                                    <% if (eta !=null) { %>
                                      <div>Consegna stimata</div>
                                      <div><strong>
                                          <%= esc(new java.text.SimpleDateFormat("dd/MM/yyyy").format(eta)) %>
                                        </strong></div>
                                      <% } %>
                                        <div>Totale</div>
                                        <div><strong class="price-highlight">€ <%= tot %></strong></div>
                                  </div>
                                </div>

                                <!-- Stato spedizione -->
                                <div class="card card-spaced">
                                  <h3 class="section-title">Stato spedizione</h3>
                                  <% if (tracking !=null && !tracking.isBlank()) { %>
                                    <p class="muted tracking-info">
                                      Corriere: <strong>
                                        <%= esc(carrier) %>
                                      </strong><br>
                                      Codice: <strong>
                                        <%= esc(tracking) %>
                                      </strong>
                                    </p>
                                    <% if (trackUrl !=null) { %>
                                      <a class="btn block" href="<%= esc(trackUrl) %>" target="_blank"
                                        rel="noopener">Apri tracking</a>
                                      <% } %>
                                        <% } else { %>
                                          <p class="muted">Nessun codice di tracking disponibile.</p>
                                          <% } %>
                                </div>

                                <!-- Acquirente -->
                                <div class="card card-spaced">
                                  <h3 class="section-title">Acquirente</h3>
                                  <div class="kvs">
                                    <div>Nome</div>
                                    <div><strong>
                                        <%= esc(buyerFirst) %>
                                          <%= esc(buyerLast) %>
                                      </strong></div>
                                    <div>Email</div>
                                    <div><a href="mailto:<%= esc(buyerMail) %>" class="email-link">
                                        <%= esc(buyerMail) %>
                                      </a></div>
                                    <div>Telefono</div>
                                    <div>
                                      <%= (buyerPhone==null || buyerPhone.isBlank()) ? "—" : esc(buyerPhone) %>
                                    </div>
                                  </div>
                                </div>

                                <!-- Indirizzi -->
                                <div class="card card-spaced">
                                  <h3 class="section-title">Indirizzi</h3>
                                  <div class="kvs" style="grid-template-columns:auto 1fr">
                                    <div>Spedizione</div>
                                    <div>
                                      <pre
                                        class="muted address-text"><%= shipAddr == null ? "—" : esc(shipAddr) %></pre>
                                    </div>
                                    <div>Fatturazione</div>
                                    <div>
                                      <pre
                                        class="muted address-text"><%= billAddr == null ? "—" : esc(billAddr) %></pre>
                                    </div>
                                  </div>
                                </div>

                                <% if (cancellable) { %>
                                  <div class="card card-spaced">
                                    <h3 class="section-title">Azioni ordine</h3>
                                    <form method="post" action="<%=ctx%>/order/cancel" class="js-confirm"
                                      data-confirm-msg="Annullare definitivamente questo ordine? Verranno ripristinati stock/capienze.">
                                      <input type="hidden" name="id" value="<%= esc(o.get(" order_id")) %>">
                                      <% if (csrf !=null && !csrf.isEmpty()) { %>
                                        <input type="hidden" name="csrf" value="<%= esc(csrf) %>">
                                        <% } %>
                                          <button class="btn warn block" type="submit">Annulla ordine</button>
                                    </form>
                                    <p class="hint">L’ordine è annullabile finché non risulta spedito o completato.</p>
                                  </div>
                                  <% } %>
                              </div>
                            </div>

                          </div>
                        </div>

                        <jsp:include page="/views/footer.jsp" />
                        <!-- Modal conferma -->
                        <div id="confirmModal" class="modal" style="display:none;">
                          <div class="modal-backdrop"></div>
                          <div class="modal-box">
                            <p id="confirmMessage"></p>
                            <div class="modal-actions">
                              <button type="button" class="btn secondary" id="confirmCancel">Annulla</button>
                              <button type="button" class="btn" id="confirmOk">Conferma</button>
                            </div>
                          </div>
                        </div>
                        <script>
                          (function () {
                            const modal = document.getElementById('confirmModal');
                            if (!modal) return;
                            const msgEl = document.getElementById('confirmMessage');
                            const btnOk = document.getElementById('confirmOk');
                            const btnCancel = document.getElementById('confirmCancel');
                            let pendingForm = null;

                            function openModal(message, form) {
                              pendingForm = form;
                              msgEl.textContent = message || 'Confermi?';
                              modal.style.display = 'flex';
                              document.body.classList.add('no-scroll');
                            }
                            function closeModal() {
                              modal.style.display = 'none';
                              document.body.classList.remove('no-scroll');
                              pendingForm = null;
                            }

                            document.querySelectorAll('form.js-confirm').forEach(f => {
                              f.addEventListener('submit', function (e) {
                                e.preventDefault();
                                openModal(f.dataset.confirmMsg, f);
                              });
                            });

                            btnOk?.addEventListener('click', () => { if (pendingForm) pendingForm.submit(); closeModal(); });
                            btnCancel?.addEventListener('click', closeModal);
                            modal.querySelector('.modal-backdrop')?.addEventListener('click', closeModal);
                            document.addEventListener('keyup', (e) => { if (e.key === 'Escape') closeModal(); });
                          })();
                        </script>
                      </body>

                      </html>