
import Chart from 'chart.js/auto';
import 'chartjs-adapter-luxon';
import '../lib/chart-financial';

const coinGeckoString = 'exchange=coin_gecko'

document.addEventListener('turbolinks:load', () => {
  window.drawChart = drawChart;

  drawChart();

  // Add event listeners to tab buttons.
  const chartTabButtons = document.getElementsByClassName('solPricesChartTabButton');

  for (const chartTabButton of chartTabButtons) {
    chartTabButton.addEventListener('click', function() {
      changeUrlBasedOnActiveTab();
    })
  }

  // Add event listeners to filter buttons.
  const chartFilterButtons = document.getElementsByClassName('chartFilterButton');

  for (const chartFilterButton of chartFilterButtons) {

    chartFilterButton.addEventListener('click', function(e) {
      changeUrlBasedOnActiveFilter(chartFilterButton);
      removeActiveClass(chartFilterButtons);
      addActiveClass(chartFilterButton)
    })
  }
})

function removeActiveClass(chartFilterButtons) {
  for (const chartFilterButton of chartFilterButtons) {
    chartFilterButton.classList.remove('active')
  } 
}

function addActiveClass(button) {
  button.classList.add('active')
}

function changeUrlBasedOnActiveFilter(chartFilterButton) {
  const href = chartFilterButton.href
  window.history.replaceState(null, '', href);
}

function changeUrlBasedOnActiveTab() {
  const url = window.location.href
  const exchangeToReplace = coinGeckoString
  let exchange = '';

  exchange = coinGeckoString
  const replacedUrl = replaceExchangeInUrl(url, exchangeToReplace, exchange)

  window.history.replaceState(exchange, exchange, replacedUrl);
}

function replaceExchangeInUrl(url, exchangeToReplace, exchange) {
  return url.replace(exchangeToReplace, exchange)
}

function drawChart() {
  const chartCoinGecko = document.getElementById('coinGeckoChart')

  if (chartCoinGecko == null) {
    return null;
  }

  const ctx = chartCoinGecko.getContext('2d');
  const dataset = ctx.canvas.dataset

  new Chart(ctx, {
    type: 'line',
    data: {
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
      scales: {
        x: {
          ticks: {
            minRotation: 0,
            maxRotation: 0,
            autoSkip: true,
            autoSkipPadding: 50
          }
        }
      },
      plugins: {
        legend: {
          display: false,
          onClick: null
        },
        tooltip: {
          intersect: false,
          mode: 'index',
          displayColors: false,
          padding: 8,
          callbacks: {
            label(tooltipItem) {
              return `SOL Price: ` + tooltipItem.formattedValue;
            },
          }
        }
      }
    },
  });
}

