<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%!
  private static String esc(Object o) {
    if (o == null) return "";
    String s = String.valueOf(o);
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
            .replace("\"", "&quot;").replace("'", "&#39;");
  }
%>
<%
  String ctx = request.getContextPath();
  User u = (User) session.getAttribute("authUser");
  String success = (String) request.getAttribute("profileSuccess");
  String error = (String) request.getAttribute("profileError");
  String csrf = (String) session.getAttribute("csrfToken");
  String userInitial = (u != null && u.getFirstName() != null && !u.getFirstName().isBlank())
      ? u.getFirstName().substring(0,1).toUpperCase() : "U";
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Profilo - Red Bull Spielberg</title>
  <link rel="icon" type="image/jpeg" href="https://cdn-3.motorsport.com/images/mgl/Y99JQRbY/s8/red-bull-racing-logo-1.jpg" />
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css" />
  <link rel="stylesheet" href="<%=ctx%>/styles/profile.css?v=2" />
</head>
<body class="page-profile">
  <jsp:include page="/views/header.jsp" />

  <div class="profile-wrap">
    <div class="profile-container">

      <!-- Profile Header with Avatar -->
      <div class="profile-header">
        <div class="profile-avatar"><%= userInitial %></div>
        <div class="profile-header-info">
          <h1><%= u == null ? "Profilo" : esc(u.getFirstName()) + " " + esc(u.getLastName()) %></h1>
          <p class="subtitle"><%= u == null ? "" : esc(u.getEmail()) %></p>
        </div>
      </div>

      <% if (success != null) { %>
        <div class="alert success"><%= esc(success) %></div>
      <% } %>
      <% if (error != null) { %>
        <div class="alert error"><%= esc(error) %></div>
      <% } %>

      <div class="grid">
        <!-- Account Info Card -->
        <div class="card">
          <h2>Informazioni personali</h2>
          <div class="info-row">
            <div class="info-item">
              <span class="info-icon">✉️</span>
              <div class="info-content">
                <span class="info-label">Email</span>
                <span class="info-value"><%= u == null ? "—" : esc(u.getEmail()) %></span>
              </div>
            </div>
            <div class="info-item">
              <span class="info-icon">👤</span>
              <div class="info-content">
                <span class="info-label">Tipo account</span>
                <span class="info-value badge-type"><%= u == null ? "—" : esc(u.getUserType()) %></span>
              </div>
            </div>
          </div>

          <div class="divider"></div>

          <form class="need-validate profile-form" method="post" action="<%=ctx%>/profile" novalidate>
            <input type="hidden" name="action" value="updateProfile" />
            <% if (csrf != null && !csrf.isBlank()) { %>
              <input type="hidden" name="csrf" value="<%= esc(csrf) %>" />
            <% } %>
            <div class="row">
              <div class="field">
                <label for="firstName">Nome</label>
                <input id="firstName" name="firstName" type="text" autocomplete="given-name"
                       placeholder="Il tuo nome"
                       value="<%= u == null ? "" : esc(u.getFirstName()) %>" data-validate="required" />
                <div class="error-msg"></div>
              </div>
              <div class="field">
                <label for="lastName">Cognome</label>
                <input id="lastName" name="lastName" type="text" autocomplete="family-name"
                       placeholder="Il tuo cognome"
                       value="<%= u == null ? "" : esc(u.getLastName()) %>" data-validate="required" />
                <div class="error-msg"></div>
              </div>
            </div>
            <div class="row single">
              <div class="field">
                <label for="phoneNumber">Telefono</label>
                <input id="phoneNumber" name="phoneNumber" type="tel" autocomplete="tel"
                       placeholder="+39 123 456 7890"
                       value="<%= u == null ? "" : esc(u.getPhoneNumber()) %>" />
                <div class="error-msg"></div>
              </div>
            </div>
            <div class="actions">
              <button class="btn primary" type="submit">
                <span>Salva modifiche</span>
              </button>
            </div>
          </form>
        </div>

        <!-- Password Card -->
        <div class="card">
          <h2>Sicurezza</h2>
          <p class="card-desc muted">Aggiorna la tua password per mantenere l'account sicuro.</p>

          <form class="need-validate profile-form" method="post" action="<%=ctx%>/profile" novalidate>
            <input type="hidden" name="action" value="changePassword" />
            <% if (csrf != null && !csrf.isBlank()) { %>
              <input type="hidden" name="csrf" value="<%= esc(csrf) %>" />
            <% } %>
            <div class="row single">
              <div class="field">
                <label for="currentPassword">Password attuale</label>
                <input id="currentPassword" name="currentPassword" type="password" autocomplete="current-password"
                       placeholder="••••••••" data-validate="required" />
                <div class="error-msg"></div>
              </div>
            </div>
            <div class="row">
              <div class="field">
                <label for="newPassword">Nuova password</label>
                <input id="newPassword" name="newPassword" type="password" autocomplete="new-password"
                       placeholder="Min. 8 caratteri" data-validate="required|password" />
                <div class="error-msg"></div>
              </div>
              <div class="field">
                <label for="confirmPassword">Conferma password</label>
                <input id="confirmPassword" name="confirmPassword" type="password" autocomplete="new-password"
                       placeholder="Ripeti password" data-validate="required|match" data-match="#newPassword" />
                <div class="error-msg"></div>
              </div>
            </div>
            <div class="password-hint">
              <span class="hint-icon">💡</span>
              <span>Usa almeno 8 caratteri con lettere e numeri</span>
            </div>
            <div class="actions">
              <button class="btn primary" type="submit">
                <span>Aggiorna password</span>
              </button>
            </div>
          </form>
        </div>

        <!-- Danger Zone Card -->
        <div class="card danger full-width">
          <h2>Zona pericolosa</h2>
          <div class="danger-content">
            <div class="danger-info">
              <p class="danger-title">Disattiva account</p>
              <p class="muted">Una volta disattivato, non potrai più accedere al tuo account. Contatta l'assistenza per riattivarlo.</p>
            </div>
            <form id="deactivateForm" method="post" action="<%=ctx%>/profile">
              <input type="hidden" name="action" value="deactivate" />
              <% if (csrf != null && !csrf.isBlank()) { %>
                <input type="hidden" name="csrf" value="<%= esc(csrf) %>" />
              <% } %>
              <button class="btn warn" type="button" id="deactivateBtn">
                <span>Elimina account</span>
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Confirmation Modal -->
  <div id="confirmModal" class="modal" hidden="hidden">
    <div class="modal-backdrop"></div>
    <div class="modal-box">
      <div class="modal-icon">⚠️</div>
      <h3>Sei sicuro?</h3>
      <p>Stai per disattivare il tuo account. Questa azione non può essere annullata immediatamente.</p>
      <div class="modal-actions">
        <button type="button" class="btn outline" id="cancelDeactivate">Annulla</button>
        <button type="button" class="btn warn" id="confirmDeactivate">Sì, elimina</button>
      </div>
    </div>
  </div>

  <jsp:include page="/views/footer.jsp" />
  <script src="<%=ctx%>/scripts/validate.js?v=1"></script>
  <script src="<%=ctx%>/scripts/profile.js?v=2"></script>
</body>
</html>
