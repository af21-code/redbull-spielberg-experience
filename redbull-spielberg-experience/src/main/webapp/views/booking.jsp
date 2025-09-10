<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.time.LocalDate, model.Product, model.TimeSlot" %>
<%@ page import="control.BookingServlet.VehicleOption" %>
<%
  String ctx = request.getContextPath();
  Product product = (Product) request.getAttribute("product");
  List<TimeSlot> slots = (List<TimeSlot>) request.getAttribute("slots");
  LocalDate selectedDate = (LocalDate) request.getAttribute("selectedDate");
  List<VehicleOption> vehicles = (List<VehicleOption>) request.getAttribute("vehicles");

  String exp = (product != null && product.getExperienceType()!=null)
               ? product.getExperienceType().name()
               : "BASE";

  // Hero texts + images (IT copy)
  String displayName, itShort, itDesc, heroImg, overlayWall = null;

  // External Red Bull hero (your choice)
  String redBullHeroImg = "https://media.formula1.com/image/upload/c_lfill,w_3392/q_auto/v1740000000/content/dam/fom-website/manual/Misc/TeamByTeam2023/red-bull-tbt-2023.webp";

  if ("PREMIUM".equalsIgnoreCase(exp)) {
      displayName = "Esperienza Red Bull Ring — Premium";
      itShort     = "Pacchetto Premium: 5 giri, analisi telemetria e tuta personalizzata.";
      itDesc      = "Porta l'esperienza al livello successivo: 5 giri, coaching avanzato con analisi dati, accesso ai box e merchandising esclusivo.";
      heroImg     = redBullHeroImg;
  } else if ("ELITE".equalsIgnoreCase(exp)) {
      displayName = "Esperienza Red Bull Ring — Elite";
      itShort     = "Pacchetto Elite: 10 giri, coaching privato e tour pit lane.";
      itDesc      = "Il massimo: 10 giri, coaching one-to-one, tour esclusivo della pit lane e pacchetto premium di merchandising.";
      heroImg     = (product!=null && product.getImageUrl()!=null && !product.getImageUrl().isBlank())
                    ? (ctx + "/" + product.getImageUrl())
                    : (ctx + "/images/experience-elite.jpg");
  } else {
      displayName = "Esperienza Red Bull Ring — Standard";
      itShort     = "Pacchetto Standard: 3 giri con istruttore, accesso circuito e kit di benvenuto.";
      itDesc      = "Vivi l'adrenalina del Red Bull Ring con il pacchetto Standard: briefing di sicurezza, 3 giri guidati con coach professionista e accesso alle aree dedicate.";
      heroImg     = redBullHeroImg;
      // If you have a custom wallpaper, set it here:
      overlayWall = ctx + "/images/wallpapers/rb-standard-wallpaper.png";
  }
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title><%= displayName %></title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/booking.css?v=13">
</head>
<body class="page-booking">
<jsp:include page="header.jsp" />

<% if (product == null) { %>
  <section class="booking-shell">
    <p>Prodotto non trovato. <a href="<%=ctx%>/shop">Torna allo shop</a></p>
  </section>
  <jsp:include page="footer.jsp" />
</body>
</html>
<% return; } %>

<section class="booking-hero"
         data-exp="<%= exp.toLowerCase() %>"
         style="--hero:url('<%= heroImg %>');<% if (overlayWall != null) { %>--overlay-wall:url('<%= overlayWall %>')<% } %>">
  <div class="booking-hero__overlay">
    <h1><%= displayName %></h1>
    <p><%= itShort %></p>
  </div>
</section>

<section class="booking-shell">
  <!-- Filtro per data -->
  <form class="booking-filter" method="get" action="<%=ctx%>/booking" novalidate>
    <input type="hidden" name="productId" value="<%= product.getProductId() %>">
    <label>Seleziona data:
      <input type="date"
             name="date"
             value="<%= selectedDate==null ? "" : selectedDate.toString() %>"
             min="<%= java.time.LocalDate.now().toString() %>"
             required>
    </label>
    <button type="submit" class="btn primary">Cerca disponibilità</button>
  </form>

  <!-- FORM UNICO -->
  <form class="booking-form card" id="addToCartForm" method="post" action="<%=ctx%>/cart/add" novalidate>
    <input type="hidden" name="productId" value="<%= product.getProductId() %>">
    <input type="hidden" name="quantity" value="1">

    <div class="section section-info">
      <p class="muted"><%= itDesc %></p>
    </div>

    <!-- 1) Slot orari -->
    <div class="section">
      <div class="section-head">
        <h3>Seleziona orario</h3>
        <small class="muted"><%= (selectedDate==null?"—":selectedDate.toString()) %></small>
      </div>

      <!-- Mantieni la data evento in POST -->
      <input class="visually-hidden" type="date" name="eventDate"
             value="<%= selectedDate==null ? "" : selectedDate.toString() %>"
             aria-hidden="true">

      <div class="slot-grid">
        <%
          boolean hasAvail = false;
          if (selectedDate == null) {
        %>
            <div class="empty">Seleziona una data per vedere gli orari disponibili.</div>
        <%
          } else if (slots != null && !slots.isEmpty()) {
            for (TimeSlot t : slots) {
              int remaining = t.getMaxCapacity() - t.getBookedCapacity();
              boolean soldOut = remaining <= 0;
              String label = t.getSlotTime().toString() + " · posti " + Math.max(remaining,0);
              String checked = "";
              if (!soldOut && !hasAvail) { checked = "checked"; hasAvail = true; }
        %>
          <label class="slot-pill <%= soldOut?"disabled":"" %>">
            <input type="radio" name="slotId"
                   value="<%= t.getSlotId() %>"
                   <%= checked %> <%= soldOut?"disabled":"" %> >
            <span><%= label %></span>
          </label>
        <%
            }
          } else {
        %>
          <div class="empty">Nessuno slot disponibile per questa data. Prova a cambiarla.</div>
        <%
          }
          request.setAttribute("hasAvail", hasAvail);
        %>
      </div>
    </div>

    <!-- 2) Dati pilota (restyling pulito) -->
    <div class="section">
      <h3>Dettagli pilota</h3>

      <!-- riga: nome + numero -->
      <div class="form-grid two-1">
        <label>Nome pilota*
          <input class="input-lg"
                 type="text"
                 name="driverName"
                 placeholder="Es. M. Verstappen"
                 autocomplete="name"
                 pattern="[A-Za-zÀ-ÿ .'\-]{2,}"
                 title="Inserisci un nome valido (min 2 caratteri)"
                 required>
        </label>

        <label>Numero &#35;
          <select class="select-lg" name="driverNumber" aria-label="Numero pilota">
            <option value="">—</option>
            <% for (int n=1; n<=99; n++) { %>
              <option value="<%= n %>"><%= n %></option>
            <% } %>
          </select>
        </label>
      </div>

      <!-- riga: accompagnatore -->
      <div class="form-grid one">
        <label>Accompagnatore (opzionale)
          <input class="input-lg"
                 type="text"
                 name="companionName"
                 placeholder="Es. H. Marko"
                 autocomplete="name"
                 pattern="[A-Za-zÀ-ÿ .'\-]{2,}">
        </label>
      </div>
    </div>

    <!-- 3) Selezione veicolo (cards più grandi) -->
    <div class="section">
      <h3>Seleziona il veicolo</h3>
      <div class="vehicle-grid">
        <%
          if (vehicles != null && !vehicles.isEmpty()) {
            for (VehicleOption v : vehicles) {
              String codeRaw = (v.getCode() == null ? "" : v.getCode());
              String code = codeRaw.toUpperCase();
              String img;
              boolean isRB21 = code.contains("RB21");
              if (isRB21)                       img = ctx + "/images/vehicles/rb21.jpg";
              else if (code.contains("F2"))     img = ctx + "/images/vehicles/f2.jpg";
              else if (code.contains("NASCAR")) img = ctx + "/images/vehicles/nascar.jpg";
              else                              img = ctx + "/images/vehicles/placeholder-vehicle.jpg";
        %>
          <label class="vehicle-card <%= (isRB21?"featured":"") %>">
            <input type="radio" name="vehicleCode" value="<%= v.getCode() %>" <%= isRB21 ? "checked" : "" %> >
            <div class="veh-inner">
              <% if (isRB21) { %><div class="ribbon">Consigliata</div><% } %>
              <img src="<%= img %>" alt="<%= v.getLabel() %>"
                   loading="lazy"
                   onerror="this.onerror=null;this.src='<%= ctx %>/images/vehicles/placeholder-vehicle.jpg';">
              <div class="veh-body">
                <h4><%= v.getLabel() %></h4>
                <p class="veh-specs"><%= v.getSpecs() %></p>
              </div>
            </div>
          </label>
        <%
            }
          } else {
        %>
          <div class="empty">Nessun veicolo configurato.</div>
        <% } %>
      </div>
    </div>

    <div class="submit-bar">
      <%
        boolean hasAvailBtn = (request.getAttribute("hasAvail") instanceof Boolean)
                               ? (Boolean) request.getAttribute("hasAvail")
                               : false;
        boolean disableBtn = (selectedDate==null) || (slots==null || slots.isEmpty()) || !hasAvailBtn;
      %>
      <button class="btn primary" type="submit" <%= disableBtn ? "disabled" : "" %>>
        Aggiungi al carrello
      </button>
      <a class="btn secondary" href="<%=ctx%>/shop">Torna allo shop</a>
    </div>
  </form>
</section>

<jsp:include page="footer.jsp" />
</body>
</html>