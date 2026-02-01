<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.time.LocalDate" %>
<%@ page import="control.BookingServlet.SlotVM, control.BookingServlet.VehicleVM" %>
<% String ctx = request.getContextPath();
    String cssVer = (String) request.getAttribute("cssVersion");
    String
            displayName = (String) request.getAttribute("displayName");
    String itShort = (String)
            request.getAttribute("itShort");
    String itDesc = (String) request.getAttribute("itDesc");
    String heroImg = (String)
            request.getAttribute("heroImg");
    String overlayWall = (String) request.getAttribute("overlayWall");
    String
            expCode = (String) request.getAttribute("expCode");
    Integer productId = (Integer) request.getAttribute("productId");
    LocalDate selectedDate = (LocalDate) request.getAttribute("selectedDate");
    @SuppressWarnings("unchecked")
    List<SlotVM> slotsVm = (List<SlotVM>) request.getAttribute("slotsVm");
    @SuppressWarnings("unchecked")
    List<VehicleVM> vehiclesVm = (List<VehicleVM>) request.getAttribute("vehiclesVm");

    Integer totalRemainingObj = (Integer) request.getAttribute("totalRemaining");
    int totalRemaining = (totalRemainingObj == null ? 0 : totalRemainingObj);

    if (cssVer == null) cssVer = "1";
    if (displayName == null) displayName = "Experience";
    if (itShort == null) itShort = "";
    if (itDesc == null) itDesc = "";
    if (expCode == null) expCode = "base";
    if (heroImg == null || heroImg.isBlank()) heroImg = ctx + "/images/experience-hero-fallback.jpg";

    boolean hasSellableSlot = false;
    if (slotsVm != null) {
        for (SlotVM s : slotsVm) {
            if (!s.isSoldOut()) {
                hasSellableSlot = true;
                break;
            }
        }
    }
    boolean disableAddToCart = (selectedDate == null) || (slotsVm == null) || !hasSellableSlot;

    String defaultVehicleCode = "";
    if (vehiclesVm != null) {
        for (VehicleVM v : vehiclesVm) {
            if (v.isChecked()) {
                defaultVehicleCode = v.getCode();
                break;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="it">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>
        <%= displayName %>
    </title>

    <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
    <link rel="stylesheet" href="<%=ctx%>/styles/booking.css?v=6">

    <script>
        (function () {
            function checkCss() {
                var v = getComputedStyle(document.documentElement).getPropertyValue('--booking-probe').trim();
                if (v !== 'bk-loaded') document.documentElement.classList.add('no-booking-css');
            }

            if (document.readyState === 'complete') checkCss();
            else window.addEventListener('load', checkCss);
        })();
    </script>
    <style>
        .no-booking-css body::before {
            content: "Attenzione: booking.css non caricato (verifica il path)";
            display: block;
            background: #b33939;
            color: #fff;
            padding: 8px 12px;
            font-weight: 800;
            text-align: center;
        }
    </style>
</head>

<body class="page-booking">
<jsp:include page="header.jsp"/>

<% if (productId == null) { %>
<section class="booking-shell">
    <div class="card" style="padding:20px">
        <p>Prodotto non trovato. <a href="<%=ctx%>/shop" class="btn">Torna allo shop</a></p>
    </div>
</section>
<jsp:include page="footer.jsp"/>
<% } else { %>

<section class="booking-hero" data-exp="<%= expCode %>"
         style="--hero:url('<%= heroImg %>');<%= (overlayWall!=null? "--overlay-wall:url('"+overlayWall+"')": "" ) %>">
    <div class="booking-hero__overlay">
        <h1>
            <%= displayName %>
        </h1>
        <p>
            <%= itShort %>
        </p>
    </div>
</section>

<section class="booking-shell">
    <div class="booking-grid">

        <!-- COLONNA SINISTRA -->
        <div class="col-left">

            <!-- STEP 1: filtro data + orari (NON è un form per evitare annidamenti) -->
            <div class="booking-step card" data-step="1">
                <header class="card-header">
                    <span class="step-num">1</span>
                    <h3 class="card-title">Seleziona data e orario <span style="color:#e74c3c">*</span></h3>
                    <small class="muted" style="margin-left:auto;font-size:0.8rem">* Obbligatorio</small>
                </header>

                <div class="card-body">
                    <p class="muted section-info">
                        <%= itDesc %>
                    </p>

                    <!-- era un <form id="dateForm">: ora è un DIV -->
                    <div id="dateForm" class="booking-filter">
                        <input type="hidden" name="productId" value="<%= productId %>">
                        <label class="date-label">Scegli dal calendario (opzionale)
                            <input type="date" id="date-input" name="date"
                                   value="<%= (selectedDate==null? "" : selectedDate.toString()) %>"
                                   min="<%= java.time.LocalDate.now().toString() %>">
                        </label>
                    </div>

                    <div class="date-section">
                        <h4 class="section-subtitle">Prossime date disponibili</h4>
                        <p class="section-note">Tocca una data qui sotto o scegli dal calendario: aggiorniamo
                            gli
                            orari in automatico.</p>
                        <div id="avail" class="date-grid" aria-live="polite">Caricamento…</div>
                    </div>

                    <fieldset class="section">
                        <legend class="sr-only">Seleziona orario</legend>
                        <div class="section-head">
                            <h3>Orari disponibili per il <span id="selected-date-display">
                                      <%= (selectedDate == null ? "—" : selectedDate.toString()) %>
                                    </span></h3>
                            <small class="muted" id="total-remaining-note">
                                Totale posti: <strong>
                                <%= totalRemaining %>
                            </strong>
                            </small>
                        </div>

                        <div class="slot-grid">
                            <% if (selectedDate == null) { %>
                            <div class="empty">Seleziona una data per vedere gli orari disponibili.</div>
                            <% } else if (slotsVm != null && !slotsVm.isEmpty()) {
                                boolean
                                        firstRequiredSet = false;
                                for (SlotVM s : slotsVm) {
                                    boolean
                                            isDisabled = s.isSoldOut();
                                    boolean setRequired = !isDisabled && !firstRequiredSet;
                                    if
                                    (setRequired) firstRequiredSet = true;
                                    String lbl = s.getLabel() == null ? "" :
                                            s.getLabel();
                                    String timePart = lbl, remPart = "";
                                    int dotIdx = lbl.indexOf("·");
                                    if
                                    (dotIdx > 0) timePart = lbl.substring(0,
                                            dotIdx).trim();
                                    int postiIdx = lbl.lastIndexOf("posti");
                                    if (postiIdx >= 0) {
                                        String after = lbl.substring(postiIdx + "posti".length()).trim();
                                        StringBuilder num = new StringBuilder();
                                        for (int i = 0; i < after.length(); i++) {
                                            char c = after.charAt(i);
                                            if
                                            (Character.isDigit(c)) num.append(c);
                                            else break;
                                        }
                                        remPart = num.toString();
                                    } %>
                            <label class="slot-pill <%= (isDisabled?" disabled":"") %>"
                                   data-time="<%= timePart %>" data-rem="<%= remPart %>">
                                <input type="radio" name="slotId" value="<%= s.getSlotId() %>"
                                    <%=(s.isChecked() && !isDisabled) ? "checked" : "" %>
                                    <%= isDisabled ? "disabled" : "" %>
                                    <%= setRequired ? "required" : "" %> >
                                <span>
                                                    <%= lbl %>
                                                  </span>
                            </label>
                            <% }
                            } else { %>
                            <div class="empty">Nessuno slot disponibile per questa data. Prova a
                                cambiarla.
                            </div>
                            <% } %>
                        </div>
                    </fieldset>
                </div>
            </div>

            <!-- STEP 2: veicolo -->
            <div class="booking-step card" data-step="2">
                <header class="card-header">
                    <span class="step-num">2</span>
                    <h3 class="card-title">Scegli il veicolo</h3>
                </header>

                <div class="card-body">
                    <fieldset class="section">
                        <legend class="sr-only">Seleziona il veicolo</legend>
                        <div class="vehicle-grid">
                            <% if (vehiclesVm != null && !vehiclesVm.isEmpty()) {
                                for (VehicleVM v : vehiclesVm) {
                            %>
                            <label class="vehicle-card <%= (v.isFeatured() ? " featured" : "" ) %>">
                                <input type="radio" name="vehicleChoice" value="<%= v.getCode() %>"
                                    <%=v.isChecked() ? "checked" : "" %> >
                                <span class="veh-inner" style="display:block">
                                        <% if (v.isFeatured()) { %>
                                          <div class="ribbon">Consigliata</div>
                                          <% } %>
                                            <img src="<%= v.getImg() %>" alt="<%= v.getLabel() %>"
                                                 onerror="this.onerror=null;this.src='<%= ctx %>/images/vehicles/placeholder-vehicle.jpg';">
                                            <div class="veh-body">
                                              <h4>
                                                <%= v.getLabel() %>
                                              </h4>
                                              <p class="veh-specs">
                                                <%= v.getSpecs() %>
                                              </p>
                                            </div>
                                      </span>
                            </label>
                            <% }
                            } else { %>
                            <div class="empty">Nessun veicolo configurato.</div>
                            <% } %>
                        </div>
                    </fieldset>
                </div>
            </div>

            <!-- STEP 3 + FORM PRINCIPALE -->
            <form class="booking-form" id="addToCartForm" method="post" action="<%=ctx%>/cart/add"
                  novalidate>
                <input type="hidden" name="productId" value="<%= productId %>">
                <input type="hidden" name="quantity" value="1">
                <input type="hidden" name="slotId" id="slotId-hidden" value="">
                <input type="hidden" name="eventDate"
                       value="<%= (selectedDate==null? "" : selectedDate.toString()) %>">
                <input type="hidden" name="vehicleCode" id="veh-hidden" value="<%= defaultVehicleCode %>">

                <div class="booking-step card" data-step="3">
                    <header class="card-header">
                        <span class="step-num">3</span>
                        <h3 class="card-title">Dettagli pilota</h3>
                    </header>

                    <div class="card-body">
                        <div class="form-grid two-1">
                            <label>Nome pilota*
                                <input class="input-lg" type="text" name="driverName"
                                       placeholder="Es. Max Verstappen" autocomplete="name"
                                       pattern="[A-Za-zÀ-ÿ .'\\-]{2,}"
                                       title="Inserisci un nome valido (min 2 caratteri)"
                                       required>
                            </label>

                            <label>Numero #
                                <select class="select-lg" name="driverNumber" aria-label="Numero pilota">
                                    <option value="">—</option>
                                    <% for (int n = 1; n <= 99; n++) { %>
                                    <option value="<%= n %>">
                                        <%= n %>
                                    </option>
                                    <% } %>
                                </select>
                            </label>
                        </div>

                        <div class="form-grid one">
                            <label>Accompagnatore (opzionale)
                                <input class="input-lg" type="text" name="companionName"
                                       placeholder="Es. Helmut Marko" autocomplete="name"
                                       pattern="[A-Za-zÀ-ÿ .'\\-]{2,}">
                            </label>
                        </div>
                    </div>
                </div>
            </form>

        </div><!-- /col-left -->

        <!-- COLONNA DESTRA (sidebar) -->
        <div class="col-right">
            <div class="booking-sidebar">
                <div class="card sidebar-card">
                    <h3 class="card-title">Riepilogo prenotazione</h3>
                    <div class="sidebar-body">
                        <p class="sidebar-item">
                            <span class="label">Esperienza:</span>
                            <span class="value">
                                    <%= displayName %>
                                  </span>
                        </p>
                        <p class="sidebar-item">
                            <span class="label">Data:</span>
                            <span class="value" id="summary-date">
                                    <%= (selectedDate == null ? "—" : selectedDate.toString()) %>
                                  </span>
                        </p>
                        <p class="sidebar-item">
                            <span class="label">Orario:</span>
                            <span class="value" id="summary-slot">—</span>
                        </p>
                        <p class="sidebar-item">
                            <span class="label">Veicolo:</span>
                            <span class="value" id="summary-vehicle">
                                    <% if (vehiclesVm != null) {
                                        String vLbl = "—";
                                        for (VehicleVM v : vehiclesVm) {
                                            if
                                            (v.isChecked()) {
                                                vLbl = v.getLabel();
                                                break;
                                            }
                                        }
                                        out.print(vLbl);
                                    } else {
                                        out.print("—");
                                    } %>
                                  </span>
                        </p>

                        <div class="sidebar-cta">
                            <button id="finalSubmitBtn" class="btn primary btn-lg" type="submit"
                                    form="addToCartForm" <%=disableAddToCart ? "disabled" : "" %>>
                                Aggiungi al carrello
                            </button>
                            <a class="btn secondary btn-sm" href="<%=ctx%>/shop">Torna allo shop</a>
                        </div>
                    </div>
                </div>
            </div>
        </div><!-- /col-right -->

    </div><!-- /booking-grid -->
</section>

<jsp:include page="footer.jsp"/>

<script>
    (function () {
        var BASE = '<%= ctx %>';
        var pid = '<%= String.valueOf(productId) %>';

        var els = {
            avail: document.getElementById('avail'),
            dateInput: document.getElementById('date-input'),
            slotGrid: document.querySelector('.slot-grid'),
            dateDisplay: document.getElementById('selected-date-display'),
            totalNote: document.getElementById('total-remaining-note'),
            eventDateHidden: document.querySelector('input[name="eventDate"]'),
            submitBtn: document.getElementById('finalSubmitBtn'),
            summaryDate: document.getElementById('summary-date'),
            summarySlot: document.getElementById('summary-slot'),
            summaryVehicle: document.getElementById('summary-vehicle'),
            vehHidden: document.getElementById('veh-hidden'),
            slotHidden: document.getElementById('slotId-hidden'),
            form: document.getElementById('addToCartForm')
        };

        // Riepilogo veicolo iniziale
        var initialVehicle = document.querySelector('.vehicle-card input:checked');
        if (initialVehicle && els.summaryVehicle) {
            var h4 = initialVehicle.closest('.vehicle-card').querySelector('h4');
            if (h4) els.summaryVehicle.textContent = h4.textContent;
        }

        function setDate(iso) {
            if (els.eventDateHidden) els.eventDateHidden.value = iso || '';
            if (els.dateInput) els.dateInput.value = iso || '';
            if (els.dateDisplay) els.dateDisplay.textContent = iso || '—';
            if (els.summaryDate) els.summaryDate.textContent = iso || '—';
        }

        function updateSlotSummary(label) {
            if (els.summarySlot) els.summarySlot.textContent = label || '—';
        }

        function toggleSubmit(enabled) {
            if (els.submitBtn) els.submitBtn.disabled = !enabled;
        }

        function updateTotals(total) {
            if (!els.totalNote) return;
            var tot = Number(total);
            if (isNaN(tot)) tot = 0;
            els.totalNote.innerHTML = 'Totale posti: <strong>' + tot + '</strong>';
        }

        function markSelectedDate(iso) {
            var chips = document.querySelectorAll('.date-chip');
            for (var i = 0; i < chips.length; i++) {
                chips[i].classList.remove('is-selected');
            }
            if (!iso) return;
            var btn = document.querySelector('.date-chip[data-date="' + iso + '"]');
            if (btn) btn.classList.add('is-selected');
        }

        function buildFetchInit() {
            return {
                method: 'GET',
                credentials: 'same-origin',
                headers: {'Accept': 'application/json'},
                cache: 'no-store'
            };
        }

        function parseMaybeJson(res) {
            var ct = (res.headers.get('content-type') || '').toLowerCase();
            if (ct.indexOf('application/json') >= 0) {
                return res.json();
            }
            return res.text().then(function (txt) {
                return {__html: txt || '', __url: res.url, __status: res.status, __redirected: !!res.redirected};
            });
        }

        function attachSlotListeners() {
            if (!els.slotGrid) return;
            Array.prototype.forEach.call(els.slotGrid.querySelectorAll('input[type=radio]'), function (r) {
                r.addEventListener('change', function () {
                    var labelEl = r.closest('label');
                    var labelText = (labelEl && (labelEl.getAttribute('data-time') || (labelEl.querySelector('span') || {}).textContent)) || '';
                    updateSlotSummary(labelText);
                    // Sincronizza slotId hidden
                    if (els.slotHidden) els.slotHidden.value = r.value;
                });
            });
            var checkedSlot = els.slotGrid.querySelector('input[type=radio]:checked');
            if (checkedSlot) {
                var labelEl = checkedSlot.closest('label');
                var labelText = (labelEl && (labelEl.getAttribute('data-time') || (labelEl.querySelector('span') || {}).textContent)) || '';
                updateSlotSummary(labelText);
                // Sincronizza slotId hidden
                if (els.slotHidden) els.slotHidden.value = checkedSlot.value;
            } else {
                updateSlotSummary('—');
                if (els.slotHidden) els.slotHidden.value = '';
            }
        }

        function loadDates() {
            if (!els.avail) return;
            els.avail.textContent = 'Caricamento…';
            try {
                var qs = new URLSearchParams({productId: pid, days: '21'});
                var url = BASE + '/booking/availability?' + qs.toString();

                fetch(url, buildFetchInit())
                    .then(function (res) {
                        if (!res.ok) {
                            els.avail.textContent = 'Errore nel caricamento (' + res.status + ').';
                            return null;
                        }
                        return parseMaybeJson(res);
                    })
                    .then(function (data) {
                        if (!data) return;

                        if (data.__html !== undefined) {
                            var snippet = String(data.__html).replace(/<[^>]+>/g, ' ').trim().slice(0, 160);
                            els.avail.innerHTML =
                                '<div class="empty">La risposta non è JSON.' +
                                (data.__redirected ? ' Reindirizzato a: ' + data.__url : '') +
                                (snippet ? '<br><small>Estratto: ' + snippet + '…</small>' : '') +
                                '</div>';
                            return;
                        }

                        if (!Array.isArray(data.days)) {
                            els.avail.textContent = 'Nessun dato ricevuto.';
                            return;
                        }

                        var days = data.days.slice();
                        if (!days.length) {
                            els.avail.textContent = 'Nessuna disponibilità nei prossimi giorni.';
                            return;
                        }

                        var frag = document.createDocumentFragment();
                        var firstAvailableDate = null;

                        days.forEach(function (d) {
                            var rem = Number(d.remaining) || 0;
                            var btn = document.createElement('button');
                            btn.type = 'button';
                            btn.className = 'date-chip' + (rem <= 0 ? ' disabled' : '');
                            btn.setAttribute('data-date', d.date);

                            var parts = String(d.date).split('-');
                            var y = parseInt(parts[0], 10), m = parseInt(parts[1], 10), dd = parseInt(parts[2], 10);
                            var dt = new Date(Date.UTC(y, m - 1, dd));
                            var lbl = dt.toLocaleDateString('it-IT', {
                                weekday: 'short',
                                day: '2-digit',
                                month: '2-digit'
                            });

                            btn.innerHTML = '<span>' + lbl + '</span><span class="cap">' + rem + '</span>';

                            if (rem > 0) {
                                if (!firstAvailableDate) firstAvailableDate = d.date;
                                btn.addEventListener('click', function () {
                                    setDate(d.date);
                                    markSelectedDate(d.date);
                                    loadSlots(d.date);
                                    var sg = document.querySelector('.slot-grid');
                                    if (sg) sg.scrollIntoView({behavior: 'smooth', block: 'start'});
                                });
                            } else {
                                btn.title = 'Nessun posto disponibile';
                                btn.setAttribute('aria-disabled', 'true');
                            }

                            frag.appendChild(btn);
                        });
                        els.avail.innerHTML = '';
                        els.avail.appendChild(frag);

                        var preselected = els.dateInput && els.dateInput.value ? els.dateInput.value : '';
                        var dateToLoad = preselected || firstAvailableDate;
                        if (dateToLoad) {
                            setDate(dateToLoad);
                            markSelectedDate(dateToLoad);
                            loadSlots(dateToLoad);
                        }
                    })
                    .catch(function () {
                        els.avail.textContent = 'Errore di rete.';
                    });
            } catch (e) {
                els.avail.textContent = 'Errore di rete.';
            }
        }

        function loadSlots(iso) {
            if (!els.slotGrid) {
                return;
            }
            els.slotGrid.innerHTML = '<div class="empty">Caricamento orari…</div>';
            toggleSubmit(false);
            updateSlotSummary('—');

            try {
                var qs = new URLSearchParams({productId: pid, date: iso});
                var url = BASE + '/booking/slots?' + qs.toString();

                fetch(url, buildFetchInit())
                    .then(function (res) {
                        if (!res.ok) {
                            els.slotGrid.innerHTML = '<div class="empty">Errore nel caricamento (' + res.status + ').</div>';
                            return null;
                        }
                        return parseMaybeJson(res);
                    })
                    .then(function (data) {
                        if (!data) return;

                        if (data.__html !== undefined) {
                            var snippet = String(data.__html).replace(/<[^>]+>/g, ' ').trim().slice(0, 160);
                            els.slotGrid.innerHTML =
                                '<div class="empty">La risposta non è JSON.' +
                                (data.__redirected ? ' Reindirizzato a: ' + data.__url : '') +
                                (snippet ? '<br><small>Estratto: ' + snippet + '…</small>' : '') +
                                '</div>';
                            updateTotals(0);
                            return;
                        }

                        var slots = Array.isArray(data.slots) ? data.slots : [];
                        if (!slots.length) {
                            els.slotGrid.innerHTML = '<div class="empty">Nessuno slot disponibile per questa data.</div>';
                            updateTotals(0);
                            return;
                        }

                        var frag = document.createDocumentFragment();
                        var firstEnabled = true;
                        slots.forEach(function (s) {
                            var label = document.createElement('label');
                            label.className = 'slot-pill' + (s.soldOut ? ' disabled' : '');
                            if (s.time) label.setAttribute('data-time', String(s.time));
                            if (s.remaining !== undefined) label.setAttribute('data-rem', String(s.remaining));
                            label.setAttribute('data-id', String(s.id));

                            var input = document.createElement('input');
                            input.type = 'radio';
                            input.name = 'slotId';
                            input.value = s.id;
                            if (s.soldOut) input.disabled = true;
                            if (firstEnabled && !s.soldOut) {
                                input.required = true;
                                input.checked = true; // seleziona primo slot disponibile
                                firstEnabled = false;
                            }

                            var span = document.createElement('span');
                            span.textContent = (s.label && String(s.label).trim().length > 0)
                                ? s.label
                                : (String(s.time) + ' · posti ' + String(s.remaining));

                            label.appendChild(input);
                            label.appendChild(span);
                            frag.appendChild(label);
                        });

                        els.slotGrid.innerHTML = '';
                        els.slotGrid.appendChild(frag);

                        updateTotals(data.totalRemaining || 0);
                        toggleSubmit(true);
                        attachSlotListeners();
                    })
                    .catch(function () {
                        els.slotGrid.innerHTML = '<div class="empty">Errore di rete.</div>';
                    });
            } catch (e) {
                els.slotGrid.innerHTML = '<div class="empty">Errore di rete.</div>';
            }
        }

        // Bottone "Cerca" (usa il valore del datepicker nascosto, se compilato)
        if (els.findBtn) {
            els.findBtn.addEventListener('click', function () {
                var iso = els.dateInput && els.dateInput.value || '';
                if (iso) {
                    setDate(iso);
                    markSelectedDate(iso);
                    loadSlots(iso);
                } else {
                    // se non c'è una data nel picker, porta l'utente ai chip
                    var avail = document.getElementById('avail');
                    if (avail) avail.scrollIntoView({behavior: 'smooth', block: 'start'});
                }
            });
        }

        // Sync veicolo -> hidden + riepilogo
        Array.prototype.forEach.call(document.querySelectorAll('.vehicle-card input[type=radio]'), function (r) {
            r.addEventListener('change', function () {
                if (els.vehHidden) els.vehHidden.value = r.value;
                var h4 = r.closest('.vehicle-card').querySelector('h4');
                if (h4 && els.summaryVehicle) els.summaryVehicle.textContent = h4.textContent;
            });
        });
        Array.prototype.forEach.call(document.querySelectorAll('.vehicle-card'), function (card) {
            card.addEventListener('click', function () {
                var input = card.querySelector('input[type=radio]');
                if (input && !input.checked) {
                    input.checked = true;
                    input.dispatchEvent(new Event('change', {bubbles: true}));
                }
            });
        });

        // Aggiorna slot quando cambia il date picker
        if (els.dateInput) {
            els.dateInput.addEventListener('change', function () {
                var iso = els.dateInput.value || '';
                setDate(iso);
                markSelectedDate(iso);
                if (iso) loadSlots(iso);
            });
        }

        // Validazione form prima dell'invio
        if (els.form) {
            els.form.addEventListener('submit', function (e) {
                // Verifica che sia stato selezionato uno slot
                if (!els.slotHidden || !els.slotHidden.value) {
                    e.preventDefault();
                    alert('Per favore seleziona una data e un orario prima di procedere.');
                    var slotGrid = document.querySelector('.slot-grid');
                    if (slotGrid) slotGrid.scrollIntoView({behavior: 'smooth', block: 'center'});
                    return false;
                }
                // Verifica che sia stata selezionata una data
                if (!els.eventDateHidden || !els.eventDateHidden.value) {
                    e.preventDefault();
                    alert('Per favore seleziona una data prima di procedere.');
                    var avail = document.getElementById('avail');
                    if (avail) avail.scrollIntoView({behavior: 'smooth', block: 'center'});
                    return false;
                }
            });
        }

        // Avvio
        setDate(els.dateInput && els.dateInput.value ? els.dateInput.value : '');
        loadDates();
        attachSlotListeners(); // per eventuale SSR

    })();
</script>

<% } /* fine else productId !=null */ %>
</body>

</html>