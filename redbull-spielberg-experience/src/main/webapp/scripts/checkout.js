(function () {
  'use strict';

  // --- helpers DOM ---
  var $  = function (s, root) { return (root || document).querySelector(s); };
  var $$ = function (s, root) { return Array.from((root || document).querySelectorAll(s)); };

  var form       = $('#checkout-form');
  if (!form) return; // non siamo su checkout.jsp

  var same       = $('#same_as_shipping');
  var billingBox = $('#billing-fields');
  var steps      = $$('.step');
  var panels     = $$('.step-panel');
  var btnNext    = $('[data-next]');
  var btnBack    = $('[data-back]');
  var errBar     = $('#form-error');
  var cardExtra  = $('[data-card-extra]');
  var payInputs  = $$('input[name="paymentMethod"]');

  // --- stepper ---
  function gotoStep(n) {
    steps.forEach(function(s){ s.classList.toggle('is-active', s.dataset.step === String(n)); });
    panels.forEach(function(p){ p.classList.toggle('is-visible', p.dataset.stepPanel === String(n)); });
    try { window.scrollTo({ top: 0, behavior: 'smooth' }); } catch (_) {}
  }

  // --- fatturazione uguale a spedizione ---
  function toggleBilling() {
    if (!billingBox || !same) return;
    billingBox.classList.toggle('is-hidden', !!same.checked);
  }
  if (same) {
    same.addEventListener('change', toggleBilling);
    toggleBilling();
  }

  // --- mostra/nascondi extra per carta ---
  function updatePayExtra() {
    if (!cardExtra) return;
    var sel = $('input[name="paymentMethod"]:checked');
    cardExtra.classList.toggle('show', !!sel && sel.value === 'CARD');
  }
  payInputs.forEach(function(i){ i.addEventListener('change', updatePayExtra); });
  updatePayExtra();

  // --- navigazione step ---
  if (btnNext) btnNext.addEventListener('click', function () {
    if (validateShipping()) gotoStep(2);
  });
  if (btnBack) btnBack.addEventListener('click', function () { gotoStep(1); });

  // --- invio form ---
  form.addEventListener('submit', function (e) {
    setErrBar(''); // pulizia

    // 1) validazione spedizione (anche se siamo allo step 2)
    if (!validateShipping()) {
      setErrBar('Completa correttamente i dati di spedizione.');
      gotoStep(1);
      e.preventDefault();
      return;
    }

    // 2) metodo pagamento
    var paySel = $('input[name="paymentMethod"]:checked');
    if (!paySel) {
      setErrBar('Seleziona un metodo di pagamento.');
      e.preventDefault();
      return;
    }

    // 3) costruzione indirizzi per il backend
    var shippingTxt = buildAddressBlock('ship_');
    var shippingEl  = $('#shippingAddress');
    var billingEl   = $('#billingAddress');
    if (shippingEl) shippingEl.value = shippingTxt;

    if (same && same.checked) {
      if (billingEl) billingEl.value = shippingTxt;
    } else {
      if (!validateBilling()) {
        setErrBar('Completa correttamente i dati di fatturazione.');
        gotoStep(1);
        e.preventDefault();
        return;
      }
      if (billingEl) billingEl.value = buildAddressBlock('bill_');
    }

    // 4) anti-doppio invio
    var submitBtn = form.querySelector('button[type="submit"]');
    if (submitBtn && !submitBtn.disabled) {
      submitBtn.disabled = true;
      submitBtn.dataset.originalText = submitBtn.textContent || '';
      submitBtn.textContent = 'Invio…';
      // best-effort re-enable dopo un po’ (es. errore rete)
      setTimeout(function(){
        submitBtn.disabled = false;
        submitBtn.textContent = submitBtn.dataset.originalText || 'Conferma ordine';
      }, 15000);
    }
    // NON chiamiamo preventDefault: lasciamo eseguire il submit nativo
  });

  // ---------- VALIDAZIONI ----------
  function val(id) {
    var el = document.getElementById(id);
    return (el && typeof el.value === 'string') ? el.value.trim() : '';
  }
  function setFieldError(inputId, msg) {
    var el = document.getElementById(inputId);
    var field = el ? el.closest('.field') : null;
    var holder = field ? field.querySelector('.error-msg') : null;
    if (holder) holder.textContent = msg || '';
  }
  function requireField(id) {
    var v = val(id);
    setFieldError(id, v ? '' : 'Campo obbligatorio');
    return !!v;
  }
  function matchPattern(id, re, msg) {
    var v = val(id);
    var ok = re.test(v);
    setFieldError(id, ok ? '' : (msg || 'Formato non valido'));
    return ok;
  }
  function setErrBar(msg) {
    if (!errBar) return;
    errBar.textContent = msg || '';
    // opzionale: nascondi visivamente quando vuoto (se il CSS mostra una barra vuota)
    if (!msg) {
      errBar.style.visibility = 'hidden';
    } else {
      errBar.style.visibility = 'visible';
    }
  }

  function validateShipping() {
    var ok = true;
    ok = requireField('ship_name')  && ok;
    ok = requireField('ship_phone') && matchPattern('ship_phone', /^(\+?\d[\d\s\-]{5,})$/, 'Telefono non valido') && ok;
    ok = requireField('ship_street') && ok;
    ok = requireField('ship_city')   && ok;
    ok = requireField('ship_prov')   && matchPattern('ship_prov', /^[A-Za-z]{2}$/, 'Usa la sigla di 2 lettere') && ok;
    ok = requireField('ship_zip')    && matchPattern('ship_zip', /^\d{5}$/, 'CAP non valido') && ok;
    ok = requireField('ship_country') && ok;
    return ok;
  }

  function validateBilling() {
    if (same && same.checked) return true;
    var ok = true;
    ok = requireField('bill_name')   && ok;
    ok = requireField('bill_street') && ok;
    ok = requireField('bill_city')   && ok;
    ok = requireField('bill_prov')   && matchPattern('bill_prov', /^[A-Za-z]{2}$/, 'Usa la sigla di 2 lettere') && ok;
    ok = requireField('bill_zip')    && matchPattern('bill_zip', /^\d{5}$/, 'CAP non valido') && ok;
    ok = requireField('bill_country') && ok;
    return ok;
  }

  function buildAddressBlock(prefix) {
    var name   = val(prefix + 'name');
    var phone  = (prefix === 'ship_') ? val('ship_phone') : '';
    var street = val(prefix + 'street');
    var city   = val(prefix + 'city');
    var prov   = val(prefix + 'prov');
    var zip    = val(prefix + 'zip');
    var ctry   = val(prefix + 'country');

    var lines = [];
    if (name)   lines.push(name);
    if (street) lines.push(street);
    var line2 = [zip, city, prov].filter(Boolean).join(' ');
    if (line2)  lines.push(line2);
    if (ctry)   lines.push(ctry);
    if (phone)  lines.push('Tel: ' + phone);
    return lines.join('\n');
  }
})();