
import Chart from 'chart.js/auto';
import { DateTime } from "luxon";
import 'chartjs-adapter-luxon';
import '../lib/chart-financial';

document.addEventListener('turbolinks:load', () => {
  drawChart();
})

function drawChart() {
  const chartCoinGecko = document.getElementById('myChart')
  const chartFtx = document.getElementById('myChart2')

  if (chartCoinGecko == null && chartFtx == null) {
    return null;
  }

  const ctx = chartCoinGecko.getContext('2d');
  const ctx2 = chartFtx.getContext('2d');
  const dataset = ctx.canvas.dataset
  const dataset2 = ctx2.canvas.dataset

  const myChart = new Chart(ctx, {
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

  const myChart2 = new Chart(ctx2, {
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
};
