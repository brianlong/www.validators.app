document.addEventListener('turbolinks:load', () => {
  $(".watch-button").on('click', function() {
    var btn = this
    $.get("/current-user", function(resp){
      $.ajax({
        url: "/api/v1/add-to-watchlist/" + $(btn).data()['network'],
        type: "post",
        data: {
          account: $(btn).data()['account']
        },
        headers: {
          Token: resp["api_token"]
        },
        dataType: 'json'
      }).done(function (data) {
        $(btn).toggleClass("fas far")
        if(data["status"] == "created") {
          $(btn).prop("title", "Remove from favourites")
        } else {
          $(btn).prop("title", "Add to favourites")
        }
      })
    })
  })
})
