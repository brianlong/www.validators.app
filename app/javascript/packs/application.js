// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
var moment = require('moment');

import '../src/sol_prices_charts'
import '../src/watch_buttons'
// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

document.addEventListener("turbolinks:load", function() {
    var links = document.getElementsByClassName("chart-link");
    Array.prototype.forEach.call(links, link => {
        link.addEventListener('click', event => {
            event.preventDefault();
            var i = link.dataset.iterator
            var target = link.dataset.bsTarget+'-'+i;
            var row = document.getElementById('row-'+i);

            // Show selected chart, hide the rest
            var charts = row.getElementsByClassName("column-chart");
            Array.prototype.forEach.call(charts, chart => {
                chart.classList.add('d-none');
            })
            document.getElementById(target).classList.remove('d-none');

            // Set active link
            var ls = row.getElementsByClassName("chart-link");
            Array.prototype.forEach.call(ls, l => {
                l.classList.remove('active')
            });
            link.classList.add('active');
        })
    })

    $('.modal-trigger').on('click', function (e) {
        let account = $(this).data()["account"]
        window.scores_modal.$children[0].update_account(account)
      })
})
