(function(){
  const $   = (s, r=document) => r.querySelector(s);
  const $$  = (s, r=document) => Array.from(r.querySelectorAll(s));

  // ---- Helpers UI error ----
  function setErr(input, msg){
    const group = input.closest('form') ? input.parentElement : null;
    const errNode = group ? group.querySelector('.error-msg') : null;
    if (errNode) errNode.textContent = msg || '';
    input.classList.toggle('is-invalid', !!msg);
  }
  function onChangeValidate(input, fn){
    ['input','change','blur'].forEach(ev => input.addEventListener(ev, () => {
      const {ok, msg} = fn(input.value.trim());
      setErr(input, ok ? '' : msg);
    }));
  }

  // ---- Regex ----
  const reEmail   = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/i;
  const rePhone   = /^(\+?\d[\d\s\-]{5,})$/;          // semplice ma tollerante
  const reProv    = /^[A-Za-z]{2}$/;
  const reZip     = /^\d{5}$/;
  const rePass    = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/; // 8+, 1 minuscola, 1 maiuscola, 1 cifra

  // ---- LOGIN ----
  const loginForm = $('#login-form');
  if (loginForm) {
    const email = $('#login_email', loginForm);
    const pass  = $('#login_password', loginForm);

    onChangeValidate(email, v => ({ ok: reEmail.test(v), msg: 'Email non valida' }));
    onChangeValidate(pass,  v => ({ ok: v.length > 0, msg: 'Inserisci la password' }));

    loginForm.addEventListener('submit', (e) => {
      let ok = true;
      if (!reEmail.test(email.value.trim())) { setErr(email, 'Email non valida'); ok=false; }
      if (!pass.value.trim())                 { setErr(pass,  'Inserisci la password'); ok=false; }
      if (!ok) e.preventDefault();
    });
  }

  // ---- REGISTER ----
  const regForm = $('#register-form');
  if (regForm) {
    const first   = $('#reg_firstName', regForm);
    const last    = $('#reg_lastName',  regForm);
    const email   = $('#reg_email',     regForm);
    const phone   = $('#reg_phone',     regForm);
    const pass    = $('#reg_password',  regForm);
    const confirm = $('#reg_confirm',   regForm);

    onChangeValidate(first, v => ({ ok: !!v, msg: 'Campo obbligatorio' }));
    onChangeValidate(last,  v => ({ ok: !!v, msg: 'Campo obbligatorio' }));
    onChangeValidate(email, v => ({ ok: reEmail.test(v), msg: 'Email non valida' }));
    onChangeValidate(phone, v => ({ ok: !v || rePhone.test(v), msg: 'Telefono non valido' }));
    onChangeValidate(pass,  v => ({ ok: rePass.test(v), msg: 'Min 8, 1 maiuscola, 1 minuscola, 1 cifra' }));
    onChangeValidate(confirm, v => ({ ok: v === pass.value, msg: 'Le password non coincidono' }));
    pass.addEventListener('input', () => {
      if (confirm.value) setErr(confirm, pass.value === confirm.value ? '' : 'Le password non coincidono');
    });

    regForm.addEventListener('submit', (e) => {
      let ok = true;
      if (!first.value.trim())              { setErr(first, 'Campo obbligatorio'); ok=false; }
      if (!last.value.trim())               { setErr(last,  'Campo obbligatorio'); ok=false; }
      if (!reEmail.test(email.value.trim())){ setErr(email, 'Email non valida'); ok=false; }
      if (phone.value.trim() && !rePhone.test(phone.value.trim())) { setErr(phone, 'Telefono non valido'); ok=false; }
      if (!rePass.test(pass.value.trim()))  { setErr(pass,  'Min 8, 1 maiuscola, 1 minuscola, 1 cifra'); ok=false; }
      if (confirm.value !== pass.value)     { setErr(confirm,'Le password non coincidono'); ok=false; }
      if (!ok) e.preventDefault();
    });
  }

  // NOTE: se ti serve validare altri campi (provincia/CAP) puoi riusare reProv e reZip
})();