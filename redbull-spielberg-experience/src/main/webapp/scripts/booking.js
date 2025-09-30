(function () {
  // Prende dati base/pid dal DOM
  var root = document.getElementById("booking-root");
  if (!root) return;

  var BASE = root.getAttribute("data-base") || "";
  var pid  = root.getAttribute("data-pid")  || "";

  // ——— Sezione “Prossime date disponibili”
  var elAvail    = document.getElementById("avail");
  var dateInput  = document.getElementById("date-input");

  function loadAvail() {
    if (!elAvail || !pid) return;
    elAvail.textContent = "Caricamento…";
    var qs = new URLSearchParams({ productId: String(pid), days: "21" });

    fetch(BASE + "/booking/availability?" + qs.toString(), {
      headers: { Accept: "application/json" },
    })
      .then(function (res) {
        if (!res.ok) throw new Error("HTTP " + res.status);
        return res.json();
      })
      .then(function (data) {
        if (!data.days || !data.days.length) {
          elAvail.textContent = "Nessuna disponibilità nei prossimi giorni.";
          return;
        }
        elAvail.innerHTML = data.days
          .map(function (d) {
            var disabled = Number(d.remaining) <= 0 ? "disabled" : "";
            var label = d.date.slice(8, 10) + "/" + d.date.slice(5, 7);
            return (
              '<button type="button" class="date-chip ' +
              disabled +
              '" data-date="' +
              d.date +
              '" ' +
              (disabled ? "disabled" : "") +
              ">" +
              label +
              ' <span class="cap">' +
              d.remaining +
              "</span>" +
              "</button>"
            );
          })
          .join("");

        // Bind click sui bottoni attivi
        Array.prototype.forEach.call(
          elAvail.querySelectorAll(".date-chip:not(.disabled)"),
          function (btn) {
            btn.addEventListener("click", function () {
              if (dateInput && dateInput.form) {
                dateInput.value = btn.getAttribute("data-date");
                dateInput.form.submit();
              }
            });
          }
        );
      })
      .catch(function () {
        elAvail.textContent = "Errore nel caricamento.";
      });
  }

  // ——— Selezione veicolo: assicurati che click su immagine/card selezioni la radio
  var grid = document.getElementById("vehicle-grid");
  if (grid) {
    grid.addEventListener("click", function (ev) {
      var inner = ev.target.closest(".veh-inner");
      if (!inner) return;
      var label = inner.closest("label.vehicle-card");
      if (!label) return;
      var input = label.querySelector('input[type="radio"][name="vehicleCode"]');
      if (!input) return;
      input.checked = true;
      // forziamo lo stato "checked" aggiornando il focus visivo
      inner.focus();
    });

    // Accessibilità: Enter/Space selezionano
    grid.addEventListener("keydown", function (ev) {
      if (ev.key !== "Enter" && ev.key !== " ") return;
      var inner = ev.target.closest(".veh-inner");
      if (!inner) return;
      ev.preventDefault();
      var label = inner.closest("label.vehicle-card");
      if (!label) return;
      var input = label.querySelector('input[type="radio"][name="vehicleCode"]');
      if (!input) return;
      input.checked = true;
    });
  }

  // Init
  loadAvail();
})();