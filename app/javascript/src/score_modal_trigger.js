document.addEventListener("turbolinks:load", function() {
  $('.modal-trigger').on('click', function (e) {
    let account = $(this).data()["account"]
    window.scores_modal.$children[0].update_account(account)
  })
});
