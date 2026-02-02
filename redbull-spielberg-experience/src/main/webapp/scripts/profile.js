(function () {
  "use strict";

  var modal = document.getElementById("confirmModal");
  var btnOpen = document.getElementById("deactivateBtn");
  var btnCancel = document.getElementById("cancelDeactivate");
  var btnConfirm = document.getElementById("confirmDeactivate");
  var form = document.getElementById("deactivateForm");

  function openModal() {
    if (!modal) return;
    modal.hidden = false;
    document.body.classList.add("no-scroll");
  }

  function closeModal() {
    if (!modal) return;
    modal.hidden = true;
    document.body.classList.remove("no-scroll");
  }

  if (btnOpen) {
    btnOpen.addEventListener("click", function () {
      openModal();
    });
  }
  if (btnCancel) btnCancel.addEventListener("click", closeModal);
  if (btnConfirm) {
    btnConfirm.addEventListener("click", function () {
      if (form) {
        if (typeof form.requestSubmit === "function") {
          form.requestSubmit();
        } else {
          form.submit();
        }
      }
    });
  }

  if (modal) {
    var backdrop = modal.querySelector(".modal-backdrop");
    if (backdrop) backdrop.addEventListener("click", closeModal);
  }

  document.addEventListener("keyup", function (e) {
    if (e.key === "Escape") closeModal();
  });
})();
