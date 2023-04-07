document.addEventListener("turbolinks:load", function() {
  document.querySelectorAll(".modal-trigger").forEach(modal_trigger => {
    modal_trigger.addEventListener("click", function(event) {
      event.preventDefault();
      let account = modal_trigger.dataset.account;
      window.scores_modal.$children[0].update_account(account);
    })
  })
});
