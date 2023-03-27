import Chart from 'chart.js/auto';
import chart_variables from '../packs/validators/charts/chart_variables'


document.addEventListener('turbolinks:load', () => {
  window.drawChart = drawChart;

  drawChart();

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

function drawChart(data) {
  const chartCoinGecko = document.getElementById('coinGeckoChartContent');

  if (chartCoinGecko == null) {
    return null;
  }

  const ctx = chartCoinGecko.getContext('2d');

  new Chart(ctx, {
    type: 'line',
    data: {
      datasets: [{
        data: data,
        fill: false,
        tension: 0.1,
        borderColor: chart_variables.chart_purple_3,
        backgroundColor: chart_variables.chart_purple_3,
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
          },
          grid: { display: false },
        },
        y: {
          display: true,
          ticks: {
            padding: 10,
            callback: function(value) {
              return value.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
            }
          },
          grid: { display: false },
          title: { display: false },
        },
      },
      plugins: {
        legend: { display: false },
        tooltip: {
          intersect: false,
          mode: 'index',
          displayColors: false,
          padding: 8,
          callbacks: {
            label(tooltipItem) {
              let price = tooltipItem.raw.y.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
              return `SOL Price: ` + price;
            },
          }
        }
      }
    },
  });
}

