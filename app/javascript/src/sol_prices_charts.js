
import Chart from 'chart.js/auto';
import { DateTime } from "luxon";
import 'chartjs-adapter-luxon';
import '../lib/chart-financial';

const coinGeckoString = 'exchange=coin_gecko'
const ftxString = 'exchange=ftx'

document.addEventListener('turbolinks:load', () => {
  window.drawChart = drawChart;

  drawChart();
  
  // Add event listeners to tab buttons.
  const chartTabButtons = document.getElementsByClassName('solPricesChartTabButton');
  
  for (const chartTabButton of chartTabButtons) {
    chartTabButton.addEventListener('click', function() {
      changeUrlBasedOnActiveTab(chartTabButton);
      updateFilterUrl();
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
  window.history.replaceState(href, href, href);
}

function updateFilterUrl() {
  const chartFilterButtons = document.getElementsByClassName('chartFilterButton')
  for (const chartFilterButton of chartFilterButtons) {
    const url = window.location.href
    const href = chartFilterButton.href
    const hrefExchange = findExchangeInUrl(href)
    const currentUrlExchange = findExchangeInUrl(url)
    const newUrl = replaceExchangeInUrl(href, hrefExchange, currentUrlExchange) 

    chartFilterButton.href = newUrl
  }
}

function changeUrlBasedOnActiveTab(button) {
  const url = window.location.href
  const textContent = button.textContent.trim();
  const exchangeToReplace = findExchangeInUrl(url)
  let exchange = '';

  exchange = findExchange(textContent)
  const replacedUrl = replaceExchangeInUrl(url, exchangeToReplace, exchange)

  window.history.replaceState(exchange, exchange, replacedUrl);
}

function findExchange(string) {
  if (string === 'CoinGecko') {
    return coinGeckoString
  } else if (string === 'FTX') {
    return ftxString
  }
}

function replaceExchangeInUrl(url, exchangeToReplace, exchange) {
  return url.replace(exchangeToReplace, exchange)
}

function findExchangeInUrl(url) {
  if (url.indexOf(coinGeckoString) != -1) {
    return coinGeckoString
  } else if (url.indexOf(ftxString) != -1) {
    return ftxString
  }
}

function drawChart() {
  const chartCoinGecko = document.getElementById('coinGeckoChart')
  const chartFtx = document.getElementById('ftxChart')

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
          display: false,
          onClick: null
        }
      },
      scales: {
        x: {
          
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
          display: false,
          onClick: null
        }
      },
      scales: {
        x: {
          time: {
            unit: 'day'
          },
        }
      }
    }
  });
};

