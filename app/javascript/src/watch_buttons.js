document.addEventListener('turbolinks:load', () => {
  $(".watch-button").on('click', function() {
    var btn = this

    if( !($(btn).attr("disabled") == 'disabled') ) {
      $(btn).attr('disabled', true);

      $.get("/current-user", function(resp) {
        $.ajax({
          url: "/api/v1/update-watchlist/" + $(btn).data()['network'],
          type: "post",
          data: {
            account: $(btn).data()['account']
          },
          headers: {
            Token: resp["api_token"]
          },
          dataType: 'json'
        }).done(function (data) {
          $(btn).attr('disabled', false);
          $(btn).toggleClass("fa-solid fa-regular")

          if(data["status"] == "created") {
            $(btn).prop("title", "Remove from favourites")
          } else {
            $(btn).prop("title", "Add to favourites")
          }
        })
      })
    }
  })
})
