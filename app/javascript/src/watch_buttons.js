import axios from 'axios';

document.addEventListener("turbolinks:load", function() {
  document.querySelectorAll(".watch-button").forEach(element => {
    element.addEventListener("click", function() {
      let btn = this;

      if (!btn.disabled) {
        btn.disabled = true; // prevents from double clicks on the button

        axios.get("/current-user").then(function (response) {
          let api_token = response.data.api_token;
          let url = "/api/v1/update-watchlist/" + btn.dataset.network;
          let validator_data = { account: btn.dataset.account };

          axios.post(url, validator_data, {
            headers: {
              "Token": api_token,
              "Content-Type": "application/json"
            }
          }).then(function (response) {
            if (response.status === 200) {
              btn.classList.toggle("fa-solid");
              btn.classList.toggle("fa-regular");
              btn.title = "Add to favourites";
              btn.disabled = false;
            } else if(response.status === 201) {
              btn.classList.toggle("fa-solid");
              btn.classList.toggle("fa-regular");
              btn.title = "Remove from favourites";
              btn.disabled = false;
            }
          });
        })
      }
    })
  })
});
