// Funzione per aggiornare quantità con +/- buttons
function updateQty(productId, delta) {
  var input = document.getElementById('qty-' + productId);
  if (!input) return;

  var currentVal = parseInt(input.value, 10) || 1;
  var newVal = currentVal + delta;

  // Non permettere quantità minori di 1
  if (newVal < 1) newVal = 1;

  input.value = newVal;

  // Auto-submit il form
  var form = document.getElementById('qty-form-' + productId);
  if (form) form.submit();
}

document.addEventListener('DOMContentLoaded', function() {
  // Intercetta SOLO i form di update quantità per submit async
  document.querySelectorAll('form.qty-form').forEach(function(form) {
    form.addEventListener('submit', function(e) {
      e.preventDefault();
      var done = function(){
        // Ricarica per aggiornare tabella + badge
        location.reload();
      };
      try {
        fetch(form.action, {
          method: 'POST',
          body: new FormData(form),
          credentials: 'same-origin'
        }).then(done).catch(done);
      } catch (err) {
        done();
      }
    });
  });
  // I form di "Rimuovi" e "Svuota" non vengono toccati -> submit normale
});