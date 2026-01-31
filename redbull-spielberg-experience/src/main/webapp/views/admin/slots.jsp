<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <% String ctx=request.getContextPath(); /* Messaggi esito operazione */ Boolean resultOk=(Boolean)
    request.getAttribute("result_ok"); String resultMsg=(String) request.getAttribute("result_msg"); /* Echo parametri
    */ Integer echoProductId=(Integer) request.getAttribute("echo_productId"); String echoStart=(String)
    request.getAttribute("echo_start"); Integer echoDays=(request.getAttribute("echo_days") instanceof Integer) ?
    (Integer) request.getAttribute("echo_days") : null; String echoTimes=(String) request.getAttribute("echo_times");
    Integer echoCapacity=(request.getAttribute("echo_capacity") instanceof Integer) ? (Integer)
    request.getAttribute("echo_capacity") : null; /* Default */ String defStart=java.time.LocalDate.now().toString();
    String defTimes="09:00,11:00,14:00,16:00" ; String defDays="90" ; String defCapacity="8" ; /* CSRF */ String
    csrfToken=(String) request.getAttribute("csrfToken"); if (csrfToken==null || csrfToken.isBlank()) {
    csrfToken=(String) session.getAttribute("csrfToken"); } %>
    <%! // Helper per escape stringhe se necessario (anche se per i toast useremo innerText in modo sicuro o JS encoded)
      private String esc(String s) { if(s==null) return "" ; return s.replace("\"", "\\\"").replace("'", "\\'");
    }
%>
<!DOCTYPE html>
<html lang=" it">

      <head>
        <meta charset="UTF-8">
        <title>Admin · Gestione Slot</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
        <link rel="stylesheet" href="<%=ctx%>/styles/admin.css">
        <link rel="stylesheet" href="<%=ctx%>/styles/order-details.css">
      </head>

      <body>
        <jsp:include page="/views/header.jsp" />

        <div class="admin-bg">
          <div class="admin-shell">
            <aside class="admin-sidebar">
              <a href="<%=ctx%>/admin">Dashboard</a>
              <a href="<%=ctx%>/admin/products">Prodotti</a>
              <a href="<%=ctx%>/admin/categories">Categorie</a>
              <a href="<%=ctx%>/admin/orders">Ordini</a>
              <a href="<%=ctx%>/admin/users">Utenti</a>
              <a href="<%=ctx%>/admin/slots" class="active">Slot</a>
            </aside>

            <section class="admin-content">
              <div class="admin-actions-bar">
                <div>
                  <h2 class="admin-header-title">Generatore Slot</h2>
                  <div class="admin-subtitle">Strumento massivo per pianificazione Experience</div>
                </div>
              </div>

              <!-- Toast Container -->
              <div id="toast-container"></div>

              <div class="card" style="padding: 32px; max-width: 900px;">
                <form id="slotForm" method="post" action="<%= response.encodeURL(ctx + " /admin/slots/generate") %>">
                  <input type="hidden" name="csrf" value="<%= (csrfToken!=null? csrfToken : "") %>">

                  <!-- Info -->
                  <div
                    style="background: rgba(10, 132, 255, 0.1); border: 1px solid rgba(10, 132, 255, 0.2); padding: 16px; border-radius: 12px; margin-bottom: 24px; color: #fff; font-size: 0.95rem; line-height: 1.5;">
                    ℹ️ <strong>Come funziona:</strong> Questo tool genera automaticamente gli slot orari per un prodotto
                    Experience.
                    Verranno creati, per ogni giorno nell’intervallo specificato, gli slot negli orari indicati (se non
                    già presenti).
                  </div>

                  <!-- Configurazione -->
                  <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px;">
                    <div>
                      <label style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Product ID
                        (Experience) *</label>
                      <div class="input-group">
                        <span class="input-icon">🆔</span>
                        <input type="number" name="productId" min="1" required
                          value="<%= (echoProductId!=null? String.valueOf(echoProductId) : "") %>" placeholder="Es. 101"
                          style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px 10px 10px 40px;">
                      </div>
                    </div>

                    <div>
                      <label style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Data Inizio
                        *</label>
                      <div class="input-group">
                        <span class="input-icon">📅</span>
                        <input type="date" name="start" required
                          value="<%= (echoStart!=null && !echoStart.isBlank()? echoStart : defStart) %>"
                          style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px 10px 10px 40px;">
                      </div>
                    </div>
                  </div>

                  <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px;">
                    <div>
                      <label style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Numero
                        Giorni</label>
                      <div class="input-group">
                        <span class="input-icon">📆</span>
                        <input type="number" name="days" min="1"
                          value="<%= (echoDays!=null? String.valueOf(echoDays) : defDays) %>"
                          style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px 10px 10px 40px;">
                      </div>
                      <div class="notes-text" style="margin-top: 6px;">Durata dell'intervallo temporale.</div>
                    </div>

                    <div>
                      <label style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Capienza
                        Slot</label>
                      <div class="input-group">
                        <span class="input-icon">👥</span>
                        <input type="number" name="capacity" min="1"
                          value="<%= (echoCapacity!=null? String.valueOf(echoCapacity) : defCapacity) %>"
                          style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px 10px 10px 40px;">
                      </div>
                    </div>
                  </div>

                  <div style="margin-bottom: 32px;">
                    <label style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Orari (separati da
                      virgola)</label>
                    <div class="input-group">
                      <span class="input-icon">⏰</span>
                      <input type="text" name="times" placeholder="09:00,11:00,14:00,16:00"
                        value="<%= (echoTimes!=null && !echoTimes.isBlank()? echoTimes : defTimes) %>"
                        style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px 10px 10px 40px;">
                    </div>
                    <div class="notes-text" style="margin-top: 6px;">Formato HH:mm, es: 09:30, 14:00</div>
                  </div>

                  <div style="display: flex; gap: 16px;">
                    <button type="button" class="btn brand" onclick="confirmGeneration()">
                      🚀 Genera Slot Massivi
                    </button>
                  </div>
                </form>
              </div>
            </section>
          </div>
        </div>

        <!-- Custom Confirmation Modal -->
        <div id="confirmModal" class="modal-overlay">
          <div class="modal-box">
            <div class="modal-title">Conferma Generazione</div>
            <div class="modal-desc" id="modalDesc">Stai per avviare la generazione massiva degli slot. Procedere?</div>
            <div class="modal-actions">
              <button class="btn-modal-cancel" onclick="closeModal()">Annulla</button>
              <button class="btn-modal-confirm" onclick="submitForm()">Conferma</button>
            </div>
          </div>
        </div>

        <script>
          // --- Toast Logic ---
          function showToast(msg, type = 'info') {
            const container = document.getElementById('toast-container');
            const toast = document.createElement('div');
            toast.className = 'toast ' + type;

            let icon = 'ℹ️';
            if (type === 'success') icon = '✅';
            if (type === 'error') icon = '⚠️';

            toast.innerHTML = '<span class="toast-icon">' + icon + '</span><span class="toast-msg">' + msg + '</span>';
            container.appendChild(toast);

            setTimeout(() => {
              toast.style.animation = 'toastFadeOut 0.3s forwards';
              setTimeout(() => toast.remove(), 300);
            }, 4000);
          }

    // --- On Load: Check if we have server messages (from JSP) ---
    <% if (resultMsg != null) { %>
            document.addEventListener("DOMContentLoaded", () => {
              showToast("<%= esc(resultMsg) %>", "<%= (resultOk != null && resultOk) ? "success" : "error" %>");
            });
    <% } %>

            // --- Modal Logic ---
            function confirmGeneration() {
              document.getElementById('confirmModal').classList.add('active');
            }

          function closeModal() {
            document.getElementById('confirmModal').classList.remove('active');
          }

          function submitForm() {
            document.getElementById('slotForm').submit();
          }
        </script>

        <jsp:include page="/views/footer.jsp" />
      </body>

      </html>