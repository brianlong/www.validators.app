
import Chart from 'chart.js/auto';
import { DateTime } from "luxon";
import 'chartjs-adapter-luxon';
import '../lib/chart-financial';

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
