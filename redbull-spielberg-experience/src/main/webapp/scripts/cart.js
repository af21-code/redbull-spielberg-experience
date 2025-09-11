document.addEventListener('DOMContentLoaded', () => {
  // Intercetta SOLO i form di update quantità
  document.querySelectorAll('form.js-update-qty').forEach(form => {
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      try {
        await fetch(form.action, {
          method: 'POST',
          body: new FormData(form),
          credentials: 'same-origin'
        });
      } catch (e) {
        // ok, comunque ricarichiamo
      }
      // Ricarica per aggiornare tabella + badge
      location.reload();
    });
  });
  // I form di "Rimuovi" e "Svuota" non vengono toccati -> submit normale
});