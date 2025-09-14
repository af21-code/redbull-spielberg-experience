(function(){
  const $ = s => document.querySelector(s);
  const $$ = s => Array.from(document.querySelectorAll(s));

  const form = $('#checkout-form');
  const same = $('#same_as_shipping');
  const billingBox = $('#billing-fields');
  const stepper = $$('.step');
  const panels  = $$('.step-panel');

  // step nav
  const gotoStep = (n) => {
    stepper.forEach(s => s.classList.toggle('is-active', s.dataset.step === String(n)));
    panels.forEach(p => p.classList.toggle('is-visible', p.dataset.stepPanel === String(n)));
    window.scrollTo({top:0, behavior:'smooth'});
  };

  // show/hide billing
  const toggleBilling = () => {
    billingBox.classList.toggle('is-hidden', same.checked);
  };
  same.addEventListener('change', toggleBilling);
  toggleBilling();

  // payment card extra fields visibility
  const cardExtra = $('[data-card-extra]');
  const paymentInputs = $$('input[name="paymentMethod"]');
  const updatePayExtra = () => {
    const val = (paymentInputs.find(i=>i.checked) || {}).value;
    cardExtra.classList.toggle('show', val === 'CARD');
  };
  paymentInputs.forEach(i => i.addEventListener('change', updatePayExtra));
  updatePayExtra();

  // step buttons
  $('[data-next]')?.addEventListener('click', () => {
    if (validateShipping()) gotoStep(2);
  });
  $('[data-back]')?.addEventListener('click', () => gotoStep(1));

  // form submit -> build hidden addresses & final validations
  form.addEventListener('submit', (e) => {
    const err = $('#form-error');
    err.textContent = '';

    if (!validateShipping()) {
      gotoStep(1);
      e.preventDefault();
      return;
    }

    if (!paymentInputs.some(i=>i.checked)) {
      err.textContent = 'Seleziona un metodo di pagamento.';
      e.preventDefault();
      return;
    }

    // Build shipping text block
    const shipping = blockAddress('ship_');
    $('#shippingAddress').value = shipping;

    // Billing: same or custom
    if ($('#same_as_shipping').checked) {
      $('#billingAddress').value = shipping;
    } else {
      const bOk = validateBilling();
      if (!bOk) {
        gotoStep(1);
        e.preventDefault();
        return;
      }
      $('#billingAddress').value = blockAddress('bill_');
    }
  });

  // ------- helpers -------
  function val(id){ return (document.getElementById(id)?.value || '').trim(); }
  function setErr(inputId, msg){
    const field = document.getElementById(inputId)?.closest('.field');
    if (!field) return;
    field.querySelector('.error-msg').textContent = msg || '';
  }

  function validateShipping(){
    let ok = true;
    ok &= req('ship_name');
    ok &= req('ship_phone') && pattern('ship_phone', /^(\+?\d[\d\s\-]{5,})$/, 'Telefono non valido');
    ok &= req('ship_street');
    ok &= req('ship_city');
    ok &= req('ship_prov') && pattern('ship_prov', /^[A-Za-z]{2}$/, 'Usa la sigla di 2 lettere');
    ok &= req('ship_zip')   && pattern('ship_zip', /^\d{5}$/, 'CAP non valido');
    ok &= req('ship_country');
    return !!ok;
  }
  function validateBilling(){
    if ($('#same_as_shipping').checked) return true;
    let ok = true;
    ok &= req('bill_name');
    ok &= req('bill_street');
    ok &= req('bill_city');
    ok &= req('bill_prov') && pattern('bill_prov', /^[A-Za-z]{2}$/, 'Usa la sigla di 2 lettere');
    ok &= req('bill_zip')  && pattern('bill_zip', /^\d{5}$/, 'CAP non valido');
    ok &= req('bill_country');
    return !!ok;
  }
  function req(id){
    const v = val(id);
    setErr(id, v ? '' : 'Campo obbligatorio');
    return !!v;
    }
  function pattern(id, re, msg){
    const v = val(id);
    const ok = re.test(v);
    setErr(id, ok ? '' : (msg || 'Formato non valido'));
    return ok;
  }
  function blockAddress(prefix){
    const name  = val(prefix+'name');
    const phone = prefix==='ship_' ? val('ship_phone') : '';
    const street= val(prefix+'street');
    const city  = val(prefix+'city');
    const prov  = val(prefix+'prov');
    const zip   = val(prefix+'zip');
    const ctry  = val(prefix+'country');

    const lines = [];
    if (name) lines.push(name);
    if (street) lines.push(street);
    const line2 = [zip, city, prov].filter(Boolean).join(' ');
    if (line2) lines.push(line2);
    if (ctry) lines.push(ctry);
    if (phone) lines.push('Tel: ' + phone);
    return lines.join('\n');
  }
})();