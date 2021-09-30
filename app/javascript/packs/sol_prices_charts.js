
import Chart from 'chart.js/auto';
import { DateTime } from "luxon";
import 'chartjs-adapter-luxon';
import '../lib/chart-financial';

document.addEventListener('turbolinks:load', () => {
  var ctx = document.getElementById('myChart').getContext('2d');
  var ctx2 = document.getElementById('myChart2').getContext('2d');
  const dataset = ctx.canvas.dataset
  const dataset2 = ctx2.canvas.dataset

  var myChart = new Chart(ctx, {
    type: 'line',
    data: {
      labels: JSON.parse(dataset.labels),
      datasets: [{
        label: 'SOL Token Price',
        data: JSON.parse(dataset.data),
        fill: false,
        tension: 0.1,
        borderColor: dataset.color,
        backgroundColor: dataset.color,
        borderWidth: 1,
      }]
    },
    options: {
      plugins: {
        legend: {
          onClick: null
        }
      }
    }
  });

  var myChart2 = new Chart(ctx2, {
    type: 'candlestick',
    data: {
      datasets: [{
        label: 'SOL Token Price',
        data: JSON.parse(dataset2.data),
        fill: false,
        tension: 0.1,
      }]
    },
    options: {
      plugins: {
        legend: {
          onClick: null
        }
      }
    }
  });
})
