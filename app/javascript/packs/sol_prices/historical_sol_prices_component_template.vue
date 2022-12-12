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

  axios.defaults.headers.get["Authorization"] = window.api_authorization;

  const filter_by_days_options = [7, 30, 60, 90];

  export default {
    data() {
      return {
        filter_by_days_options: filter_by_days_options,
        days: filter_by_days_options[0]
      }
    },
    created() {
      this.draw_chart();
    },
    methods: {
      is_active_filter(days) {
        return this.days === days;
      },
      select_filter_by_days(days) {
        this.days = days;

        this.draw_chart();
      },
      recreate_chart_skeleton() {
        const chartCoinGeckoContent = document.getElementById('coinGeckoChartContent');
        const chartCoinGecko = document.getElementById('coinGeckoChart');

        chartCoinGeckoContent.remove();
        chartCoinGecko.innerHTML = "<canvas id='coinGeckoChartContent'</canvas>";
      },
      draw_chart() {
        const ctx = this;
        const url = "/api/v1/sol-prices";

        axios.get(url, { params: { filtering: this.days } })
          .then(response => {
            ctx.recreate_chart_skeleton();
            drawChart(response.data);
          })
      }
    }
  }
</script>
