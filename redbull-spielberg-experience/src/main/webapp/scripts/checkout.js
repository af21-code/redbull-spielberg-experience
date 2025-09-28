(function () {
  'use strict';

  // --- helpers DOM ---
  const $  = (s, root) => (root || document).querySelector(s);
  const $$ = (s, root) => Array.from((root || document).querySelectorAll(s));

  const form       = $('#checkout-form');
  if (!form) return; // non siamo su checkout.jsp

  const same       = $('#same_as_shipping');
  const billingBox = $('#billing-fields');
  const steps      = $$('.step');
  const panels     = $$('.step-panel');
  const btnNext    = $('[data-next]');
  const btnBack    = $('[data-back]');
  const errBar     = $('#form-error');
  const cardExtra  = $('[data-card-extra]');
  const payInputs  = $$('input[name="paymentMethod"]');

  // --- stepper ---
  function gotoStep(n) {
    steps.forEach(s => s.classList.toggle('is-active', s.dataset.step === String(n)));
    panels.forEach(p => p.classList.toggle('is-visible', p.dataset.stepPanel === String(n)));
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
    const sel = $('input[name="paymentMethod"]:checked');
    cardExtra.classList.toggle('show', !!sel && sel.value === 'CARD');
  }
  payInputs.forEach(i => i.addEventListener('change', updatePayExtra));
  updatePayExtra();

  // --- navigazione step ---
  if (btnNext) btnNext.addEventListener('click', () => {
    if (validateShipping()) gotoStep(2);
  });
  if (btnBack) btnBack.addEventListener('click', () => gotoStep(1));

  // --- invio form ---
  form.addEventListener('submit', (e) => {
    setErrBar(''); // pulizia

    // 1) validazione spedizione (anche se siamo allo step 2)
    if (!validateShipping()) {
      setErrBar('Completa correttamente i dati di spedizione.');
      gotoStep(1);
      e.preventDefault();
      return;
    }

    // 2) metodo pagamento
    const paySel = $('input[name="paymentMethod"]:checked');
    if (!paySel) {
      setErrBar('Seleziona un metodo di pagamento.');
      e.preventDefault();
      return;
    }

    // 3) costruzione indirizzi per il backend
    const shippingTxt = buildAddressBlock('ship_');
    const shippingEl  = $('#shippingAddress');
    const billingEl   = $('#billingAddress');
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
    const submitBtn = form.querySelector('button[type="submit"]');
    if (submitBtn && !submitBtn.disabled) {
      submitBtn.disabled = true;
      submitBtn.dataset.originalText = submitBtn.textContent || '';
      submitBtn.textContent = 'Invio…';
      // best-effort re-enable dopo un po’ (es. errore rete)
      setTimeout(() => {
        submitBtn.disabled = false;
        submitBtn.textContent = submitBtn.dataset.originalText || 'Conferma ordine';
      }, 15000);
    }
    // NON chiamiamo preventDefault: lasciamo eseguire il submit nativo
  });

  // ---------- VALIDAZIONI ----------
  function val(id) {
    const el = document.getElementById(id);
    return (el && typeof el.value === 'string') ? el.value.trim() : '';
  }
  function setFieldError(inputId, msg) {
    const field = document.getElementById(inputId)?.closest('.field');
    const holder = field ? field.querySelector('.error-msg') : null;
    if (holder) holder.textContent = msg || '';
  }
  function requireField(id) {
    const v = val(id);
    setFieldError(id, v ? '' : 'Campo obbligatorio');
    return !!v;
  }
  function matchPattern(id, re, msg) {
    const v = val(id);
    const ok = re.test(v);
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
    let ok = true;
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
    let ok = true;
    ok = requireField('bill_name')   && ok;
    ok = requireField('bill_street') && ok;
    ok = requireField('bill_city')   && ok;
    ok = requireField('bill_prov')   && matchPattern('bill_prov', /^[A-Za-z]{2}$/, 'Usa la sigla di 2 lettere') && ok;
    ok = requireField('bill_zip')    && matchPattern('bill_zip', /^\d{5}$/, 'CAP non valido') && ok;
    ok = requireField('bill_country') && ok;
    return ok;
  }

  function buildAddressBlock(prefix) {
    const name   = val(prefix + 'name');
    const phone  = (prefix === 'ship_') ? val('ship_phone') : '';
    const street = val(prefix + 'street');
    const city   = val(prefix + 'city');
    const prov   = val(prefix + 'prov');
    const zip    = val(prefix + 'zip');
    const ctry   = val(prefix + 'country');

    const lines = [];
    if (name)   lines.push(name);
    if (street) lines.push(street);
    const line2 = [zip, city, prov].filter(Boolean).join(' ');
    if (line2)  lines.push(line2);
    if (ctry)   lines.push(ctry);
    if (phone)  lines.push('Tel: ' + phone);
    return lines.join('\n');
  }
})();