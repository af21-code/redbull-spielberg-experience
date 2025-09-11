// Aggiorna quantità riga carrello ospite (sessione)
async function cartUpdate(productId, slotId, qty) {
  const fd = new FormData();
  fd.append("productId", productId);
  if (slotId !== null && slotId !== undefined && slotId !== "") {
    fd.append("slotId", slotId);
  }
  fd.append("qty", qty);

  const res = await fetch(`${window.ctx || ''}/api/cart/update`, {
    method: 'POST',
    body: fd
  });
  return res.json();
}

async function cartRemove(productId, slotId) {
  const fd = new FormData();
  fd.append("productId", productId);
  if (slotId !== null && slotId !== undefined && slotId !== "") {
    fd.append("slotId", slotId);
  }

  const res = await fetch(`${window.ctx || ''}/api/cart/remove`, {
    method: 'POST',
    body: fd
  });
  return res.json();
}

// Wire UI (es: input.qty[data-product][data-slot])
document.addEventListener('input', async (e) => {
  const el = e.target;
  if (!el.matches('.js-cart-qty')) return;

  const productId = parseInt(el.dataset.product, 10);
  const slotId = el.dataset.slot ? parseInt(el.dataset.slot, 10) : null;
  const qty = parseInt(el.value, 10) || 1;

  const r = await cartUpdate(productId, slotId, qty);
  if (!r.ok) {
    el.classList.add('error');
  } else {
    el.classList.remove('error');
    // TODO: ricalcolare totale a DOM, se vuoi
  }
});

document.addEventListener('click', async (e) => {
  const btn = e.target.closest('.js-cart-remove');
  if (!btn) return;

  e.preventDefault();
  const productId = parseInt(btn.dataset.product, 10);
  const slotId = btn.dataset.slot ? parseInt(btn.dataset.slot, 10) : null;

  const r = await cartRemove(productId, slotId);
  if (r.ok) {
    const row = btn.closest('[data-row]');
    if (row) row.remove();
    // TODO: ricalcolare totale a DOM, se vuoi
  }
});