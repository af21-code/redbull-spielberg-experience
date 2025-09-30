<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.time.LocalDate" %>
<%@ page import="control.BookingServlet.SlotVM, control.BookingServlet.VehicleVM" %>
<%
  String ctx = request.getContextPath();

  // Attributi già pronti dalla servlet (niente logica qui)
  String cssVer        = (String) request.getAttribute("cssVersion");
  String displayName   = (String) request.getAttribute("displayName");
  String itShort       = (String) request.getAttribute("itShort");
  String itDesc        = (String) request.getAttribute("itDesc");
  String heroImg       = (String) request.getAttribute("heroImg");
  String overlayWall   = (String) request.getAttribute("overlayWall");
  String expCode       = (String) request.getAttribute("expCode");
  Integer productId    = (Integer) request.getAttribute("productId");
  LocalDate selectedDate = (LocalDate) request.getAttribute("selectedDate");
  @SuppressWarnings("unchecked")
  List<SlotVM> slotsVm = (List<SlotVM>) request.getAttribute("slotsVm");
  @SuppressWarnings("unchecked")
  List<VehicleVM> vehiclesVm = (List<VehicleVM>) request.getAttribute("vehiclesVm");
  Integer totalRemainingObj = (Integer) request.getAttribute("totalRemaining");
  int totalRemaining = (totalRemainingObj==null?0:totalRemainingObj);
%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title><%= (displayName==null?"Experience":displayName) %></title>

  <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
  <link rel="stylesheet" href="<%=ctx%>/styles/booking.css?v=<%= (cssVer==null?"1":cssVer) %>">

  <!-- Banner diagnostico se booking.css non carica -->
  <script>
    (function(){
      function checkCss(){
        var v = getComputedStyle(document.documentElement).getPropertyValue('--booking-probe').trim();
        if (v !== 'bk-loaded') document.documentElement.classList.add('no-booking-css');
      }
      if (document.readyState === 'complete') checkCss();
      else window.addEventListener('load', checkCss);
    })();
  </script>
  <style>
    .no-booking-css body::before{
      content:"Attenzione: booking.css non caricato (verifica il path)"; display:block;
      background:#b33939;color:#fff;padding:8px 12px;font-weight:800;text-align:center;
    }
    /* Piccoli stili per i chip data (per evitare stili inline) */
    .date-grid{display:flex;flex-wrap:wrap;gap:8px}
    .date-chip{background:#001e36;color:#fff;border:1px solid rgba(255,255,255,.18);border-radius:999px;padding:8px 10px;font-weight:800;cursor:pointer}
    .date-chip .cap{opacity:.9;font-weight:700;margin-left:6px}
    .date-chip.disabled{opacity:.55;cursor:not-allowed}
    .section-note{margin:6px 0 0;opacity:.85}
  </style>
</head>
<body class="page-booking">
<jsp:include page="header.jsp" />

<% if (productId == null) { %>
  <section class="booking-shell">
    <div class="card" style="padding:20px">
      <p>Prodotto non trovato. <a href="<%=ctx%>/shop" class="btn">Torna allo shop</a></p>
    </div>
  </section>
  <jsp:include page="footer.jsp" />
</body>
</html>
<% return; } %>

<section class="booking-hero"
         data-exp="<%= (expCode==null?"base":expCode) %>"
         style="--hero:url('<%= heroImg %>');<%= (overlayWall!=null? "--overlay-wall:url('"+overlayWall+"')": "") %>">
  <div class="booking-hero__overlay">
    <h1><%= displayName %></h1>
    <p><%= itShort %></p>
  </div>
</section>

<section class="booking-shell">
  <!-- Filtro data -->
  <form class="booking-filter" method="get" action="<%=ctx%>/booking" novalidate>
    <input type="hidden" name="productId" value="<%= productId %>">
    <label>Seleziona data:
      <input type="date"
             id="date-input"
             name="date"
             value="<%= (selectedDate==null? "" : selectedDate.toString()) %>"
             min="<%= java.time.LocalDate.now().toString() %>"
             required>
    </label>
    <button type="submit" class="btn primary">Cerca disponibilità</button>
  </form>

  <!-- Prossime date -->
  <div class="card" style="margin-top:10px">
    <h3 style="margin:0 0 8px">Prossime date disponibili</h3>
    <div id="avail" class="date-grid" aria-live="polite">Caricamento…</div>
    <p class="section-note">Clicca una data per impostarla nel filtro e vedere gli orari.</p>
  </div>

  <!-- FORM UNICO -->
  <form class="booking-form card" id="addToCartForm" method="post" action="<%=ctx%>/cart/add" novalidate>
    <input type="hidden" name="productId" value="<%= productId %>">
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

      <p class="section-note">
        Disponibilità totale per il <strong><%= (selectedDate==null?"—":selectedDate.toString()) %></strong>:
        <strong><%= totalRemaining %></strong> posti
      </p>

      <input class="visually-hidden" type="date" name="eventDate"
             value="<%= (selectedDate==null? "" : selectedDate.toString()) %>"
             aria-hidden="true">

      <div class="slot-grid">
        <% if (selectedDate == null) { %>
          <div class="empty">Seleziona una data per vedere gli orari disponibili.</div>
        <% } else if (slotsVm != null && !slotsVm.isEmpty()) {
             for (SlotVM s : slotsVm) { %>
              <label class="slot-pill <%= (s.isSoldOut()?"disabled":"") %>">
                <input type="radio" name="slotId"
                       value="<%= s.getSlotId() %>"
                       <%= (s.isChecked() && !s.isSoldOut()) ? "checked" : "" %>
                       <%= s.isSoldOut() ? "disabled" : "" %> >
                <span><%= s.getLabel() %></span>
              </label>
        <%   }
           } else { %>
          <div class="empty">Nessuno slot disponibile per questa data. Prova a cambiarla.</div>
        <% } %>
      </div>
    </div>

    <!-- 2) Dati pilota -->
    <div class="section">
      <h3>Dettagli pilota</h3>

      <div class="form-grid two-1">
        <label>Nome pilota*
          <input class="input-lg"
                 type="text"
                 name="driverName"
                 placeholder="Es. M. Verstappen"
                 autocomplete="name"
                 pattern="[A-Za-zÀ-ÿ .'\\-]{2,}"
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

      <div class="form-grid one">
        <label>Accompagnatore (opzionale)
          <input class="input-lg"
                 type="text"
                 name="companionName"
                 placeholder="Es. H. Marko"
                 autocomplete="name"
                 pattern="[A-Za-zÀ-ÿ .'\\-]{2,}">
        </label>
      </div>
    </div>

    <!-- 3) Selezione veicolo -->
    <div class="section">
      <h3>Seleziona il veicolo</h3>
      <div class="vehicle-grid">
        <% if (vehiclesVm != null && !vehiclesVm.isEmpty()) {
             for (VehicleVM v : vehiclesVm) { %>
          <label class="vehicle-card <%= (v.isFeatured() ? "featured" : "") %>">
            <input type="radio" name="vehicleCode" value="<%= v.getCode() %>" <%= v.isChecked() ? "checked" : "" %> >
            <div class="veh-inner">
              <% if (v.isFeatured()) { %><div class="ribbon">Consigliata</div><% } %>
              <img src="<%= v.getImg() %>" alt="<%= v.getLabel() %>"
                   onerror="this.onerror=null;this.src='<%= ctx %>/images/vehicles/placeholder-vehicle.jpg';">
              <div class="veh-body">
                <h4><%= v.getLabel() %></h4>
                <p class="veh-specs"><%= v.getSpecs() %></p>
              </div>
            </div>
          </label>
        <%   }
           } else { %>
          <div class="empty">Nessun veicolo configurato.</div>
        <% } %>
      </div>
    </div>

    <div class="submit-bar">
      <button class="btn primary" type="submit"
              <%= (selectedDate==null || slotsVm==null || slotsVm.stream().noneMatch(s -> !s.isSoldOut())) ? "disabled" : "" %>>
        Aggiungi al carrello
      </button>
      <a class="btn secondary" href="<%=ctx%>/shop">Torna allo shop</a>
    </div>
  </form>
</section>

<jsp:include page="footer.jsp" />

<script>
  (function(){
    const BASE = '<%=ctx%>';
    const pid  = '<%= productId %>';
    const el   = document.getElementById('avail');
    const dateInput = document.getElementById('date-input');

    // Selezione radio al click sull'intera card veicolo
    document.querySelectorAll('.vehicle-card').forEach(card=>{
      card.addEventListener('click', ()=>{
        const input = card.querySelector('input[type=radio]');
        if (input && !input.checked) { input.checked = true; input.dispatchEvent(new Event('change',{bubbles:true})); }
      });
    });

    // Carica prossime date con posti disponibili
    async function loadAvail(){
      if (!el) return;
      el.textContent = 'Caricamento…';
      const qs = new URLSearchParams({ productId: pid, days: '21' });
      try{
        const res = await fetch(BASE + '/booking/availability?' + qs.toString(), { headers:{'Accept':'application/json'} });
        if(!res.ok){ el.textContent = 'Errore nel caricamento ('+res.status+').'; return; }
        const data = await res.json();
        if(!data.days || !data.days.length){ el.textContent = 'Nessuna disponibilità nei prossimi giorni.'; return; }
        el.innerHTML = data.days.map(d => {
          const disabled = Number(d.remaining) <= 0 ? 'disabled' : '';
          const label = d.date.slice(8,10) + '/' + d.date.slice(5,7);
          return '<button type="button" class="date-chip '+disabled+'" data-date="'+d.date+'" '+(disabled?'disabled':'')+'>' +
                   label + ' <span class="cap">' + d.remaining + '</span>' +
                 '</button>';
        }).join('');
        el.querySelectorAll('.date-chip:not(.disabled)').forEach(btn=>{
          btn.addEventListener('click', () => {
            dateInput.value = btn.getAttribute('data-date');
            dateInput.form.submit();
          });
        });
      }catch(e){
        el.textContent = 'Errore di rete.';
      }
    }
    loadAvail();
  })();
</script>
</body>
</html>