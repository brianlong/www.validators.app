<template>
  <div>
    <section class="page-header">
      <h1>Sol Token Prices</h1>
    </section>

    <div class="card">
      <div class="card-content">
        <div class="text-center mb-4">
          <div class="btn-group">
            <button v-for="filter_by_days in filter_by_days_options"
               v-on:click="select_filter_by_days(filter_by_days)"
               :title="'Filter by ' + filter_by_days +' days'"
               class="btn btn-sm btn-secondary nav-link chartFilterButton"
               :class="{ active: is_active_filter(filter_by_days) }">
               {{ `${filter_by_days} days` }}
            </button>
          </div>
        </div>

        <div class="tab-content" id='sol-prices-tab-content'>
          <div class="tab-pane solPriceChartTab active" id="coinGeckoChartTab">
            <div id="coinGeckoChart">
              <canvas id="coinGeckoChartContent"></canvas>
            </div>
            <p class='mt-3 text-center'>
              Average price of Sol Token, powered by <a href="https://www.coingecko.com/en" target='_blank'>CoinGecko</a>.
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from 'axios';
  import Chart from 'chart.js/auto';
  import chart_variables from '../validators/charts/chart_variables';

  const filter_by_days_options = [7, 30, 60, 90];

  export default {
    data() {
      return {
        filter_by_days_options: filter_by_days_options,
        days: filter_by_days_options[0]
      }
    },

    created() {
      this.$nextTick(() => {
        this.draw_chart();
      });
    },

    methods: {
      is_active_filter(days) {
        return this.days === days;
      },

      select_filter_by_days(days) {
        this.days = days;

        this.$nextTick(() => {
          this.draw_chart();
        });
      },

      recreate_chart_skeleton() {
        const chartCoinGeckoContent = document.getElementById('coinGeckoChartContent');
        const chartCoinGecko = document.getElementById('coinGeckoChart');

        if (chartCoinGeckoContent && chartCoinGecko) {
          chartCoinGeckoContent.remove();
          chartCoinGecko.innerHTML = "<canvas id='coinGeckoChartContent'></canvas>";
        }
      },

      draw_chart() {
        const ctx = this;
        const url = "/api/v1/sol-prices";

        axios.get(url, { params: { filtering: this.days } })
          .then(response => {
            ctx.recreate_chart_skeleton();
            ctx.drawChartWithData(response.data);
          })
      },

      drawChartWithData(data) {
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
    }
  }
</script>
