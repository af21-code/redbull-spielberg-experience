(function () {
  "use strict";

  var $$ = function (sel, root) { return Array.from((root || document).querySelectorAll(sel)); };

  var messages = {
    required: "Campo obbligatorio.",
    email: "Inserisci un'email valida.",
    password: "La password deve avere almeno 8 caratteri, 1 lettera e 1 numero.",
    match: "I campi non coincidono.",
    minlen: function (n) { return "Minimo " + n + " caratteri."; },
    maxlen: function (n) { return "Massimo " + n + " caratteri."; },
    number: "Inserisci un numero valido.",
    integer: "Inserisci un numero intero.",
    min: function (n) { return "Il valore minimo è " + n + "."; },
    max: function (n) { return "Il valore massimo è " + n + "."; },
    phone: "Inserisci un numero di telefono valido.",
    postal: "Inserisci un CAP valido.",
    pattern: "Formato non valido.",
    payment: "Seleziona un metodo di pagamento.",
    address: "Inserisci un indirizzo valido (min. 6 caratteri)."
  };

  var re = {
    email: /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/,
    password: /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d\S]{8,}$/,
    phone: /^[+\d]([ ()\-\d]{5,})\d$/,
    postal: /^\d{5}$/
  };

  function getErrorContainer(field) {
    var key = field.getAttribute("id") || field.getAttribute("name");
    if (!key) return null;

    var ctn = field.closest("label, .form-row, .form-group, .field") || field.parentElement;
    if (!ctn) return null;
    var el = ctn.querySelector('[data-error-for="' + key + '"]');
    if (!el) {
      el = document.createElement("div");
      el.setAttribute("data-error-for", key);
      el.style.color = "#ffb4b4";
      el.style.fontSize = "0.85rem";
      el.style.marginTop = "4px";
      ctn.appendChild(el);
    }
    return el;
  }

  function setError(field, msg) {
    var box = getErrorContainer(field);
    field.classList.add("is-invalid");
    if (box) {
      box.textContent = msg || "";
      box.style.display = msg ? "block" : "none";
      box.setAttribute("role", "alert");
      box.setAttribute("aria-live", "polite");
    }
  }

  function clearError(field) {
    var box = getErrorContainer(field);
    field.classList.remove("is-invalid");
    if (box) {
      box.textContent = "";
      box.style.display = "none";
    }
  }

  var validators = {
    required: function (f) {
      if (f.type === "checkbox" || f.type === "radio") {
        var group = document.getElementsByName(f.name);
        return Array.from(group).some(function (r) { return r.checked; })
          ? null
          : messages.required;
      }
      return f.value.trim().length ? null : messages.required;
    },
    email: function (f) {
      return (f.value.trim() && !re.email.test(f.value.trim())) ? messages.email : null;
    },
    password: function (f) {
      return (f.value.trim() && !re.password.test(f.value)) ? messages.password : null;
    },
    match: function (f) {
      var sel = f.getAttribute("data-match");
      if (!sel) return null;
      var other = document.querySelector(sel);
      if (!other) return null;
      return f.value === other.value ? null : messages.match;
    },
    minlen: function (f) {
      var n = parseInt(f.getAttribute("data-minlen"), 10);
      if (!n) return null;
      return f.value.trim().length < n ? messages.minlen(n) : null;
    },
    maxlen: function (f) {
      var n = parseInt(f.getAttribute("data-maxlen"), 10);
      if (!n) return null;
      return f.value.trim().length > n ? messages.maxlen(n) : null;
    },
    number: function (f) {
      if (!f.value.trim()) return null;
      var val = Number(f.value);
      return Number.isFinite(val) ? null : messages.number;
    },
    integer: function (f) {
      if (!f.value.trim()) return null;
      return /^-?\d+$/.test(f.value.trim()) ? null : messages.integer;
    },
    min: function (f) {
      var m = Number(f.getAttribute("data-min"));
      if (!f.value.trim() || !Number.isFinite(m)) return null;
      var v = Number(f.value);
      return v < m ? messages.min(m) : null;
    },
    max: function (f) {
      var m = Number(f.getAttribute("data-max"));
      if (!f.value.trim() || !Number.isFinite(m)) return null;
      var v = Number(f.value);
      return v > m ? messages.max(m) : null;
    },
    phone: function (f) {
      return (f.value.trim() && !re.phone.test(f.value.trim())) ? messages.phone : null;
    },
    postal: function (f) {
      return (f.value.trim() && !re.postal.test(f.value.trim())) ? messages.postal : null;
    },
    pattern: function (f) {
      var p = f.getAttribute("data-pattern");
      if (!p || !f.value.trim()) return null;
      try {
        var rx = new RegExp(p);
        return rx.test(f.value.trim()) ? null : messages.pattern;
      } catch (e) {
        // pattern non valido: non bloccare il form
        return null;
      }
    },
    payment: function (f) {
      var type = f.type;
      if (type === "select-one") {
        return f.value ? null : messages.payment;
      }
      if (type === "radio") {
        var group = document.getElementsByName(f.name);
        return Array.from(group).some(function (r) { return r.checked; })
          ? null
          : messages.payment;
      }
      return null;
    },
    address: function (f) {
      var v = f.value.trim();
      if (!v) return null;
      return v.length >= 6 ? null : messages.address;
    }
  };

  function validateField(field) {
    var ruleStr = field.getAttribute("data-validate");
    if (!ruleStr) return null;
    var rules = ruleStr.split("|").map(function (s) { return s.trim(); }).filter(Boolean);
    for (var i = 0; i < rules.length; i++) {
      var r = rules[i];
      var fn = validators[r];
      if (!fn) continue;
      var err = fn(field);
      if (err) {
        setError(field, err);
        return err;
      }
    }
    clearError(field);
    return null;
  }

  function wireForm(form) {
    // feedback in tempo reale
    $$(".need-validate [data-validate], [data-validate]", form).forEach(function (f) {
      var evt = f.tagName === "SELECT" ? "change" : "input";
      f.addEventListener(evt, function () { validateField(f); });
      f.addEventListener("blur", function () { validateField(f); });
    });

    form.addEventListener("submit", function (e) {
      var firstInvalid = null;
      var fields = $$(".need-validate [data-validate], [data-validate]", form);
      for (var i = 0; i < fields.length; i++) {
        var f = fields[i];
        var err = validateField(f);
        if (err && !firstInvalid) firstInvalid = f;
      }
      if (firstInvalid) {
        e.preventDefault();
        firstInvalid.focus({ preventScroll: false });
      }
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    $$("form.need-validate").forEach(wireForm);
  });
})();