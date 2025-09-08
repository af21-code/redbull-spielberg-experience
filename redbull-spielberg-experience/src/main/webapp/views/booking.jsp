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
  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css?v=2">
  <link rel="stylesheet" href="<%=ctx%>/styles/userLogo.css?v=2">
  <link rel="stylesheet" href="<%=ctx%>/styles/booking.css?v=3">
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

<section class="booking-hero">
  <div class="booking-hero__inner">
    <h1><%= product.getName() %></h1>
    <p><%= product.getShortDescription()==null?"":product.getShortDescription() %></p>
  </div>
</section>

<section class="booking-form__wrap">
  <!-- Filtro per data (GET) -->
  <form class="booking-filter" method="get" action="<%=ctx%>/booking">
    <input type="hidden" name="productId" value="<%= product.getProductId() %>">
    <label>Seleziona data:
      <input type="date"
             name="date"
             value="<%= selectedDate==null ? "" : selectedDate.toString() %>"
             min="<%= java.time.LocalDate.now().toString() %>"
             required>
    </label>
    <button type="submit" class="btn">Cerca disponibilità</button>
  </form>

  <div class="booking-grid">
    <!-- Form prenotazione -->
    <div class="card">
      <h3>Seleziona veicolo e orario</h3>

      <form id="addToCartForm" method="post" action="<%=ctx%>/cart/add">
        <!-- Dati base -->
        <input type="hidden" name="productId" value="<%= product.getProductId() %>">
        <input type="hidden" name="quantity" value="1">

        <!-- Data evento (in POST, visibile e required) -->
        <label>Data evento:
          <input type="date"
                 name="eventDate"
                 value="<%= selectedDate==null ? "" : selectedDate.toString() %>"
                 min="<%= java.time.LocalDate.now().toString() %>"
                 required>
        </label>

        <!-- Slot disponibili -->
        <label>Orario disponibile:
          <select name="slotId" required>
            <option value="" disabled <%= (slots==null||slots.isEmpty())?"selected":"" %> >Seleziona uno slot</option>
            <%
              if (slots != null) {
                for (TimeSlot t : slots) {
                  int remaining = (t.getMaxCapacity() - t.getBookedCapacity());
                  String label = t.getSlotDate().toString() + " " + t.getSlotTime().toString()
                               + " — posti: " + remaining;
            %>
              <option value="<%= t.getSlotId() %>"><%= label %></option>
            <%
                }
              }
            %>
          </select>
        </label>

        <% if (slots == null || slots.isEmpty()) { %>
          <p class="muted" style="margin-top:6px;">Nessuno slot disponibile per questa data. Prova un altro giorno.</p>
        <% } %>

        <!-- Veicoli -->
        <div class="vehicle-options">
          <%
            if (vehicles != null && !vehicles.isEmpty()) {
              boolean first = true;
              for (VehicleOption v : vehicles) {
          %>
            <label>
              <input type="radio" name="vehicleCode" value="<%= v.getCode() %>" <%= first?"checked":"" %> >
              <strong><%= v.getLabel() %></strong> — <%= v.getSpecs() %>
            </label>
          <%
                first = false;
              }
            } else {
          %>
            <em>Nessun veicolo configurato.</em>
          <% } %>
        </div>

        <!-- Dati anagrafici -->
        <div class="driver-box">
          <label>Nome pilota* <input type="text" name="driverName" required></label>
          <label>Accompagnatore (opzionale) <input type="text" name="companionName"></label>
        </div>

        <button class="btn primary" type="submit" <%= (slots==null||slots.isEmpty())?"disabled":"" %>>
          Aggiungi al carrello
        </button>
      </form>
    </div>

    <!-- Riepilogo -->
    <aside class="card">
      <h3>Dettagli pacchetto</h3>
      <ul class="bullets">
        <li>Tipo: <strong><%= product.getProductType() %></strong></li>
        <li>Prezzo: <strong>€ <%= product.getPrice() %></strong></li>
        <li>Esperienza: <strong><%= product.getExperienceType()==null?"—":product.getExperienceType() %></strong></li>
      </ul>
      <p><%= product.getDescription()==null?"":product.getDescription() %></p>
    </aside>
  </div>
</section>

<jsp:include page="footer.jsp" />
</body>
</html>