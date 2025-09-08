<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.time.LocalDate, model.Product, model.TimeSlot" %>
<%@ page import="control.BookingServlet.VehicleOption" %>
<%
  String ctx = request.getContextPath();
  Product product = (Product) request.getAttribute("product");
  List<TimeSlot> slots = (List<TimeSlot>) request.getAttribute("slots");
  LocalDate selectedDate = (LocalDate) request.getAttribute("selectedDate");
  List<VehicleOption> vehicles = (List<VehicleOption>) request.getAttribute("vehicles");
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Prenotazione - <%= (product!=null?product.getName():"") %></title>
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/booking.css?v=4">
</head>
<body class="page-booking">
<jsp:include page="header.jsp" />

<% if (product == null) { %>
  <section class="booking-form__wrap">
    <p>Prodotto non trovato. <a href="<%=ctx%>/shop">Torna allo shop</a></p>
  </section>
  <jsp:include page="footer.jsp" />
</body>
</html>
<% return; } %>

<section class="booking-hero" style="--hero:url('<%= (product.getImageUrl()!=null && !product.getImageUrl().isBlank()) ? (ctx + "/" + product.getImageUrl()) : (ctx + "/images/experience-elite.jpg") %>')">
  <div class="booking-hero__overlay">
    <h1><%= product.getName() %></h1>
    <p><%= product.getShortDescription()==null?"":product.getShortDescription() %></p>
  </div>
</section>

<section class="booking-shell">
  <!-- Filtro per data -->
  <form class="booking-filter" method="get" action="<%=ctx%>/booking">
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

  <div class="booking-grid">
    <!-- Colonna sinistra: form prenotazione -->
    <form class="booking-form card" id="addToCartForm" method="post" action="<%=ctx%>/cart/add">
      <!-- Dati base -->
      <input type="hidden" name="productId" value="<%= product.getProductId() %>">
      <input type="hidden" name="quantity" value="1">

      <!-- 1) Slot orari -->
      <div class="section">
        <div class="section-head">
          <h3>Seleziona orario</h3>
          <small class="muted"><%= (selectedDate==null?"—":selectedDate.toString()) %></small>
        </div>

        <!-- mantieni la data evento in POST -->
        <label class="sr-only">Data evento</label>
        <input class="visually-hidden" type="date" name="eventDate"
               value="<%= selectedDate==null ? "" : selectedDate.toString() %>"
               aria-hidden="true">

        <div class="slot-grid">
          <%
            if (slots != null && !slots.isEmpty()) {
              boolean first = true;
              for (TimeSlot t : slots) {
                int remaining = t.getMaxCapacity() - t.getBookedCapacity();
                boolean soldOut = remaining <= 0;
                String label = t.getSlotTime().toString() + " · posti " + Math.max(remaining,0);
          %>
            <label class="slot-pill <%= soldOut?"disabled":"" %>">
              <input type="radio" name="slotId" value="<%= t.getSlotId() %>" <%= (first && !soldOut)?"checked":"" %> <%= soldOut?"disabled":"" %> >
              <span><%= label %></span>
            </label>
          <%
                if (!soldOut) first = false;
              }
            } else {
          %>
            <div class="empty">Nessuno slot disponibile per questa data. Prova a cambiarla.</div>
          <%
            }
          %>
        </div>
      </div>

      <!-- 2) Dati pilota -->
      <div class="section">
        <h3>Dati pilota</h3>
        <div class="fields two">
          <label>Nome pilota*<input type="text" name="driverName" required></label>
          <label>Accompagnatore (opzionale)<input type="text" name="companionName"></input></label>
        </div>
      </div>

      <!-- 3) Selezione veicolo -->
      <div class="section">
        <h3>Seleziona il veicolo</h3>
        <div class="vehicle-grid">
          <%
            if (vehicles != null && !vehicles.isEmpty()) {
              boolean firstV = true;
              for (VehicleOption v : vehicles) {
                String img;
                String code = v.getCode().toUpperCase();
                if (code.contains("RB21"))           img = ctx + "/images/vehicles/rb21.jpg";
                else if (code.contains("F2"))        img = ctx + "/images/vehicles/f2.jpg";
                else if (code.contains("NASCAR"))    img = ctx + "/images/vehicles/nascar.jpg";
                else                                  img = ctx + "/images/vehicles/placeholder-vehicle.jpg";
          %>
            <label class="vehicle-card">
              <input type="radio" name="vehicleCode" value="<%= v.getCode() %>" <%= firstV?"checked":"" %> >
              <div class="veh-inner">
                <img src="<%= img %>" alt="<%= v.getLabel() %>">
                <div class="veh-body">
                  <h4><%= v.getLabel() %></h4>
                  <p class="veh-specs"><%= v.getSpecs() %></p>
                </div>
              </div>
            </label>
          <%
                firstV = false;
              }
            } else {
          %>
            <div class="empty">Nessun veicolo configurato.</div>
          <% } %>
        </div>
      </div>

      <!-- CTA -->
      <div class="submit-bar">
        <button class="btn primary" type="submit" <%= (slots==null||slots.isEmpty())?"disabled":"" %>>
          Aggiungi al carrello
        </button>
        <a class="btn secondary" href="<%=ctx%>/shop">Torna allo shop</a>
      </div>
    </form>

    <!-- Colonna destra: riepilogo -->
    <aside class="card booking-aside">
      <h3>Dettagli pacchetto</h3>
      <ul class="bullets">
        <li>Tipo: <strong><%= product.getProductType() %></strong></li>
        <li>Esperienza: <strong><%= product.getExperienceType()==null?"—":product.getExperienceType() %></strong></li>
        <li>Prezzo: <strong>€ <%= product.getPrice() %></strong></li>
      </ul>
      <p><%= product.getDescription()==null?"":product.getDescription() %></p>
    </aside>
  </div>
</section>

<jsp:include page="footer.jsp" />
</body>
</html>