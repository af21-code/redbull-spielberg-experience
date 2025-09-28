
(function () {
  "use strict";

  const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));

  const messages = {
    required: "Campo obbligatorio.",
    email: "Inserisci un'email valida.",
    password:
      "La password deve avere almeno 8 caratteri, 1 lettera e 1 numero.",
    match: "I campi non coincidono.",
    minlen: (n) => `Minimo ${n} caratteri.`,
    maxlen: (n) => `Massimo ${n} caratteri.`,
    number: "Inserisci un numero valido.",
    integer: "Inserisci un numero intero.",
    min: (n) => `Il valore minimo è ${n}.`,
    max: (n) => `Il valore massimo è ${n}.`,
    phone: "Inserisci un numero di telefono valido.",
    postal: "Inserisci un CAP valido.",
    pattern: "Formato non valido.",
    payment: "Seleziona un metodo di pagamento.",
    address: "Inserisci un indirizzo valido (min. 6 caratteri)."
  };

  const re = {
    email:
      /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/,
    password:
      /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d\S]{8,}$/,
    phone:
      /^[+\d]([ ()\-\d]{5,})\d$/,
    postal:
      /^\d{5}$/
  };

  function getErrorContainer(field) {
    // 1) data-error-for (id o name)
    const key =
      field.getAttribute("id") || field.getAttribute("name");
    if (!key) return null;

    // cerca <small|div> con data-error-for="fieldId"
    const ctn =
      field.closest("label, .form-row, .form-group, .field") || field.parentElement;
    if (!ctn) return null;
    let el = ctn.querySelector(`[data-error-for="${key}"]`);
    if (!el) {
      // crea al volo un contenitore standard
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
    const box = getErrorContainer(field);
    field.classList.add("is-invalid");
    if (box) {
      box.textContent = msg || "";
      box.style.display = msg ? "block" : "none";
      box.setAttribute("role", "alert");
      box.setAttribute("aria-live", "polite");
    }
  }

  function clearError(field) {
    const box = getErrorContainer(field);
    field.classList.remove("is-invalid");
    if (box) {
      box.textContent = "";
      box.style.display = "none";
    }
  }

  const validators = {
    required: (f) => {
      if (f.type === "checkbox" || f.type === "radio") {
        const group = document.getElementsByName(f.name);
        return Array.from(group).some((r) => r.checked)
          ? null
          : messages.required;
      }
      return f.value.trim().length ? null : messages.required;
    },
    email: (f) =>
      f.value.trim() && !re.email.test(f.value.trim())
        ? messages.email
        : null,
    password: (f) =>
      f.value.trim() && !re.password.test(f.value)
        ? messages.password
        : null,
    match: (f) => {
      const sel = f.getAttribute("data-match");
      if (!sel) return null;
      const other = document.querySelector(sel);
      if (!other) return null;
      return f.value === other.value ? null : messages.match;
    },
    minlen: (f) => {
      const n = parseInt(f.getAttribute("data-minlen"), 10);
      if (!n) return null;
      return f.value.trim().length < n ? messages.minlen(n) : null;
    },
    maxlen: (f) => {
      const n = parseInt(f.getAttribute("data-maxlen"), 10);
      if (!n) return null;
      return f.value.trim().length > n ? messages.maxlen(n) : null;
    },
    number: (f) => {
      if (!f.value.trim()) return null;
      const val = Number(f.value);
      return Number.isFinite(val) ? null : messages.number;
    },
    integer: (f) => {
      if (!f.value.trim()) return null;
      return /^-?\d+$/.test(f.value.trim()) ? null : messages.integer;
    },
    min: (f) => {
      const m = Number(f.getAttribute("data-min"));
      if (!f.value.trim() || !Number.isFinite(m)) return null;
      const v = Number(f.value);
      return v < m ? messages.min(m) : null;
    },
    max: (f) => {
      const m = Number(f.getAttribute("data-max"));
      if (!f.value.trim() || !Number.isFinite(m)) return null;
      const v = Number(f.value);
      return v > m ? messages.max(m) : null;
    },
    phone: (f) =>
      f.value.trim() && !re.phone.test(f.value.trim())
        ? messages.phone
        : null,
    postal: (f) =>
      f.value.trim() && !re.postal.test(f.value.trim())
        ? messages.postal
        : null,
    pattern: (f) => {
      const p = f.getAttribute("data-pattern");
      if (!p || !f.value.trim()) return null;
      try {
        const rx = new RegExp(p);
        return rx.test(f.value.trim()) ? null : messages.pattern;
      } catch {
        // pattern non valido: non bloccare il form
        return null;
      }
    },
    payment: (f) => {
      // Select o radio per metodo pagamento
      const type = f.type;
      if (type === "select-one") {
        return f.value ? null : messages.payment;
      }
      if (type === "radio") {
        const group = document.getElementsByName(f.name);
        return Array.from(group).some((r) => r.checked)
          ? null
          : messages.payment;
      }
      return null;
    },
    address: (f) => {
      const v = f.value.trim();
      if (!v) return null;
      return v.length >= 6 ? null : messages.address;
    }
  };

  function validateField(field) {
    const ruleStr = field.getAttribute("data-validate");
    if (!ruleStr) return null;
    const rules = ruleStr.split("|").map((s) => s.trim()).filter(Boolean);
    for (const r of rules) {
      const fn = validators[r];
      if (!fn) continue;
      const err = fn(field);
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
    $$(".need-validate [data-validate], [data-validate]", form).forEach((f) => {
      const evt = f.tagName === "SELECT" ? "change" : "input";
      f.addEventListener(evt, () => validateField(f));
      f.addEventListener("blur", () => validateField(f));
    });

    form.addEventListener("submit", (e) => {
      let firstInvalid = null;
      const fields = $$(".need-validate [data-validate], [data-validate]", form);
      for (const f of fields) {
        const err = validateField(f);
        if (err && !firstInvalid) firstInvalid = f;
      }
      if (firstInvalid) {
        e.preventDefault();
        firstInvalid.focus({ preventScroll: false });
      }
    });
  }

  document.addEventListener("DOMContentLoaded", () => {
    $$("form.need-validate").forEach(wireForm);
  });
})();