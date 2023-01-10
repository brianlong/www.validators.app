
import Chart from 'chart.js/auto';
import 'chartjs-adapter-luxon';
import '../lib/chart-financial';

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
        label: 'SOL Token Price',
        data: data,
        fill: false,
        tension: 0.1,
        borderColor: "rgb(170, 46, 184)",
        backgroundColor: "rgb(170, 46, 184)",
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

