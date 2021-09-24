// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
import Chart from 'chart.js/auto';
import { DateTime } from "luxon";
import 'chartjs-adapter-luxon';
import './chart-financial';

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
            var target = link.dataset.target+'-'+i;
            var row = document.getElementById('row-'+i);

            // Show selected chart, hide the rest
            var charts = row.getElementsByClassName("chart-column");
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
});

document.addEventListener('turbolinks:load', () => {
    var ctx = document.getElementById('myChart').getContext('2d');
    var ctx2 = document.getElementById('myChart2').getContext('2d');
    var myChart = new Chart(ctx, {
    type: 'line',
    data: {
      labels: JSON.parse(ctx.canvas.dataset.labels),
      datasets: [{
        label: 'SOL Token Price',
        data: JSON.parse(ctx.canvas.dataset.data),
        fill: false,
        borderColor: 'rgb(75, 192, 192)',
        tension: 0.1
      }]
    },
  });

  const data2 = JSON.parse(ctx2.canvas.dataset.data)
  // Converts string timestamp to Int for luxon
  data2.forEach(el => el['x'] = parseInt(el['x']));

  var myChart2 = new Chart(ctx2, {
    type: 'candlestick',
    data: {
      datasets: [{
        label: 'SOL Token Price',
        data: data2,
        fill: false,
        borderColor: 'rgb(75, 192, 192)',
        tension: 0.1
      }]
    },
  });
})
